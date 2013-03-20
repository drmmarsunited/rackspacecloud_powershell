## Info ##
## Author: Mitch Robins (mitch.robins) ##
## Description: PSv3 module for NextGen Rackspace Cloud API interaction ##
## Version 1.7 ##
## Contact Info: 210-312-5868 / mitch.robins@rackspace.com ##

## Define Global Variables Needed for API Comms ##

Set-Variable -Name CloudUsername -Value "" -Scope Global
Set-Variable -Name CloudAPIKey -Value "" -Scope Global
Set-Variable -Name CloudDDI -Value "" -Scope Global
## THIS VARIABLE WILL NOT BE USED IN V1 - Set-Variable -Name GlobalServerRegion -Value "ORD" -Scope Global

## Define Custom tables for Result Sets
$ImageListTable = @{Expression={$_.id};Label="Image ID";width=38}, 
@{Expression={$_.Name};Label="Image Name";width=40}, 
@{Expression={$_.status};Label="Image Status";width=38},
@{Expression={$_.updated};Label="Image Last Updated";width=19}

$ServerListTable = @{Expression={$_.id};Label="Server ID";width=38}, 
@{Expression={$_.Name};Label="Server Name";width=40}, 
@{Expression={$_.Status};Label="Server Status";width=15}, 
@{Expression={$_.addresses.network.ip.addr};Label="Server IP Addresses";width=200}

$NetworkListTable = @{Expression={$_.label};Label="Network Name";width=25}, 
@{Expression={$_.cidr};Label="Assigned Block";width=30}, 
@{Expression={$_.id};Label="Network ID";width=33}

$LBListTable = @{Expression={$_.id};Label="CLB ID";width=15}, 
@{Expression={$_.Name};Label="CLB Name";width=40}, 
@{Expression={$_.Status};Label="CLB Status";width=15}, 
@{Expression={$_.Algorithm};Label="CLB Algorithm";width=40}, 
@{Expression={$_.Port};Label="CLB Port";width=8}, 
@{Expression={$_.nodeCount};Label="CLB Node Count";width=8}

$LBDetailListTable = @{Expression={$_.id};Label="CLB ID";width=15}, 
@{Expression={$_.Name};Label="CLB Name";width=40}, 
@{Expression={$_.Status};Label="CLB Status";width=15}, 
@{Expression={$_.Algorithm};Label="CLB Algorithm";width=40}, 
@{Expression={$_.Port};Label="CLB Port";width=8}, 
@{Expression={$_.nodes.node.address};Label="Node IP";width=50},
@{Expression={$_.nodes.node.port};Label="Node Port";width=8},
@{Expression={$_.nodes.node.condition};Label="Node Condition";width=10},
@{Expression={$_.nodes.node.status};Label="Node Status";width=10}

$FlavorListTable = @{Expression={$_.id};Label="Flavor ID";width=3}, 
@{Expression={$_.Name};Label="Flavor Name";width=40}, 
@{Expression={$_.ram};Label="RAM (in MB)";width=38},
@{Expression={$_.disk};Label="Disk Size";width=19},
@{Expression={$_.swap};Label="Swap Size";width=19},
@{Expression={$_.vcpus};Label="vCPUs";width=19},
@{Expression={$_.rxtx_factor};Label="Rx/Tx Factor";width=19}

$VolListTable = @{Expression={$_.id};Label="Vol ID";width=35}, 
@{Expression={$_.display_name};Label="Vol Name";width=40}, 
@{Expression={$_.status};Label="Vol Status";width=15},
@{Expression={$_.volume_type};Label="Vol Type";width=6},
@{Expression={$_.size};Label="Vol Size";width=6},
@{Expression={$_.display_description};Label="Vol Desc.";width=19},
@{Expression={$_.created_at};Label="Vol Created";width=19}

$VolTable = @{Expression={$_.id};Label="ID";width=35}, 
@{Expression={$_.display_name};Label="Name";width=40}, 
@{Expression={$_.status};Label="Status";width=15},
@{Expression={$_.attachments.attachment.server_id};Label="Attached To";width=15},
@{Expression={$_.volume_type};Label="Type";width=6},
@{Expression={$_.size};Label="Size";width=6},
@{Expression={$_.display_description};Label="Desc.";width=19},
@{Expression={$_.created_at};Label="Created";width=19}

$VolSnapTable = @{Expression={$_.id};Label="Snap ID";width=35}, 
@{Expression={$_.display_name};Label="Name";width=40}, 
@{Expression={$_.status};Label="Status";width=15},
@{Expression={$_.progress};Label="Progress";width=19},
@{Expression={$_.volume_id};Label="Vol. ID";width=6},
@{Expression={$_.size};Label="Size";width=6},
@{Expression={$_.display_description};Label="Desc.";width=19},
@{Expression={$_.created_at};Label="Created";width=19}

$VolTypeTable = @{Expression={$_.id};Label="ID";width=5}, 
@{Expression={$_.name};Label="Name";width=6}

$NewServerTable = @{Expression={$_.id};Label="Server ID";width=38}, 
@{Expression={$_.adminpass};Label="Server Password";width=40}

$RegionListTable = @{Expression={$_.region};Label="Region";width=10}, 
@{Expression={$_.publicURL};Label="Region URL";width=40}

$ServerBandwidthTable = @{Expression={$_.interface};Label="Interface";width=38}, 
@{Expression={$_.bandwidth_outbound};Label="Outbound Bandwidth";width=40},
@{Expression={$_.bandwidth_inbound};Label="Inbound Bandwidth";width=40},
@{Expression={$_.audit_period_start};Label="Start Date";width=40},
@{Expression={$_.audit_period_end};Label="End Date";width=40}

$EndPointTable = @{Expression={$service.name};Label="Name"},
@{Expression={$service.endpoint.region};Label="Region"},
@{Expression={$service.endpoint.publicURL};Label="URL"}

## Define Functions

## Region mismatch function
function Send-RegionError {
    
    ## This is simply writing an error to the console.
    Write-Host "You have entered an invalid region identifier.  Valid region identifiers for this tool are ORD and DFW." -ForegroundColor Red
}


## Global Authentication Cmdlets

function Get-AuthToken {
    ## Check for current authentication token and retrieves a new one if needed
        if ((Get-Date) -ge $token.access.token.expires) {
                Pop-AuthToken
            }

        else {}
}

function Pop-AuthToken() {
    
    ## Setting variables needed for function execution
    Set-Variable -Name AuthURI -Value "https://identity.api.rackspacecloud.com/v2.0/tokens.xml"
    Set-Variable -Name AuthBody -Value ('{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'+$CloudUsername+'", "apiKey":"'+$CloudAPIKey+'"}}}')

    ## Making the call to the token authentication API and saving it's output as a global variable for reference in every other function.
    Set-Variable -Name token -Value (Invoke-RestMethod -Uri $AuthURI -Body $AuthBody -ContentType application/json -Method Post) -Scope Global
    
    Set-Variable -Name CloudServerRegionListStep0 -Value ($token.access.serviceCatalog.service | Where-Object {$_.type -eq "compute"})
    Set-Variable -Name CloudServerRegionList -Value ($CloudServerRegionListStep0.endpoint)

    
    $FinalToken = $token.access.token.id
    
    

    ## Headers in powershell need to be defined as a dictionary object, so here I'm creating a dictionary object with the newly granted token. It's global, as it's needed in every future request.
    Set-Variable -Name HeaderDictionary -Value (new-object "System.Collections.Generic.Dictionary``2[[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]") -Scope Global
    $HeaderDictionary.Add("X-Auth-Token", $finaltoken)
}


## Cloud Server API Cmdlets

function Get-CloudServerImages {
    
    Param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWImageURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/images/detail.xml"
    Set-Variable -Name ORDImageURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/images/detail.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW"){
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Making the call to the API for a list of available server images and storing data into a variable
    [xml]$ServerImageListDFWStep0 = (Invoke-RestMethod -Uri $DFWImageURI  -Headers $HeaderDictionary)
    [xml]$ServerImageListDFWFinal = ($ServerImageListDFWStep0.innerxml)

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $ServerImageListDFWFinal.Images.Image | Sort-Object Name | ft $ImageListTable -AutoSize
    }

## See first "if" block for notes on each line##
elseif ($Region -eq "ORD"){

    Get-AuthToken

    [xml]$ServerImageListORDStep0 = (Invoke-RestMethod -Uri $ORDImageURI  -Headers $HeaderDictionary)
    [xml]$ServerImageListORDFinal = ($ServerImageListORDStep0.innerxml)

    $ServerImageListORDFinal.Images.Image | Sort-Object Name | ft $ImageListTable -AutoSize
    }

else {
    
    ## Sending a text error if the region has been misspelled
    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudServerImages cmdlet will pull down a list of all Rackspace Cloud Server image snapshots on your account, including Rackspace's base OS images.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages -Region DFW
 This example shows how to get a list of all available images in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages ORD
 This example shows how to get a list of all available images in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.
#>
}

function Get-CloudServers{

    Param(
        [Parameter (Position=0, Mandatory=$false)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWServerURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/detail.xml"
    Set-Variable -Name ORDServerURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/detail.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available servers and storing data into a variable
    [xml]$ServerListStep0 = (Invoke-RestMethod -Uri $DFWServerURI  -Headers $HeaderDictionary)
    [xml]$ServerListFinal = ($ServerListStep0.innerxml)

    ## Handling empty response bodies indicating that no servers exist in the queried data center
    if ($ServerListFinal.Servers.Server -eq $null) {

        Write-Host "You do not currently have any Cloud Servers provisioned in the DFW region."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $ServerListFinal.Servers.Server | Sort-Object Name | ft $ServerListTable -AutoSize

    }

}

elseif ($Region -eq "ORD") {  
    
    Get-AuthToken

    [xml]$ServerListStep0 = (Invoke-RestMethod -Uri $ORDServerURI  -Headers $HeaderDictionary)
    [xml]$ServerListFinal = ($ServerListStep0.innerxml)

    if ($ServerListFinal.Servers.Server -eq $null) {

        Write-Host "You do not currently have any Cloud Servers provisioned in the ORD region."

    }
    
    else {
    
        $ServerListFinal.Servers.Server | Sort-Object Name | ft $ServerListTable -AutoSize

    }

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudServers cmdlet will pull down a list of all Rackspace Cloud Servers on your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers -Region DFW
 This example shows how to get a list of all servers currently deployed in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers ORD
 This example shows how to get a list of all servers deployed in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.
#>
}

function Get-CloudServerDetails {

    Param(
        [Parameter(Position=0,Mandatory=$false)]
        [switch]$Bandwidth,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWServerDetailURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID.xml"
        Set-Variable -Name ORDServerDetailURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID.xml"

if ($Bandwidth) {

    if ($Region -eq "DFW") {

    Get-AuthToken

    [xml]$ServerDetailStep0 = (Invoke-RestMethod -Uri $DFWServerDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$ServerDetailFinal = ($ServerDetailStep0.innerxml)

    $ServerDetailFinal.server.bandwidth.interface | ft $ServerBandwidthTable -AutoSize

    }

    elseif ($Region -eq "ORD") {

    Get-AuthToken

    [xml]$ServerDetailStep0 = (Invoke-RestMethod -Uri $ORDServerDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$ServerDetailFinal = ($ServerDetailStep0.innerxml)

    $ServerDetailFinal.server.bandwidth.interface | ft $ServerBandwidthTable -AutoSize

    }

    else {

    Send-RegionError

    }

}

else {

    if ($Region -eq "DFW") {

    Get-AuthToken

    [xml]$ServerDetailStep0 = (Invoke-RestMethod -Uri $DFWServerDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$ServerDetailFinal = ($ServerDetailStep0.innerxml)
    
    $ServerDetailOut = @{"Server Name"=($ServerDetailFinal.server.name);"Server ID"=($ServerDetailFinal.server.id);"Server Image ID"=($ServerDetailFinal.server.image.id);"Server Flavor ID"=($ServerDetailFinal.server.flavor.id);"Server Last Updated"=($ServerDetailFinal.server.updated)}

    $ServerDetailOut

    }

    elseif ($Region -eq "ORD") {

    Get-AuthToken

    [xml]$ServerDetailStep0 = (Invoke-RestMethod -Uri $ORDServerDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$ServerDetailFinal = ($ServerDetailStep0.innerxml)

    Write-Host ` '
    Server Name: '($ServerDetailFinal.server.name)'
    Server ID: '($ServerDetailFinal.server.id)'
    Server Image ID: '($ServerDetailFinal.server.image.id)'
    Server Flavor ID: '($ServerDetailFinal.server.flavor.id)'
    Server Last Updated: '($ServerDetailFinal.server.updated)''

    }

    else {

    Send-RegionError

    }

}
<#
 .SYNOPSIS
 The Get-CloudServerDetails cmdlet will pull down a list of detailed information for a specific Rackspace Cloud Server.

 .DESCRIPTION
 This command is executed against one given cloud server ID, which in turn will return explicit details about that server without any other server data.

 .PARAMETER Bandwidth
 Use this parameter to indicate that you'd like to see bandwidth statistics of the server ID passed to powershell.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want explicit details. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW
 This example shows how to get explicit data about one cloud server from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Bandwidth -Region ORD
 This example shows how to get explicit data about one cloud server from the ORD region, including bandwidth statistics.
#>
}

function Get-CloudServerFlavors() {
    param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWFlavorURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/flavors/detail.xml"
    Set-Variable -Name ORDFlavorURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/flavors/detail.xml"

if ($Region -eq "DFW") {

    Get-AuthToken

    [xml]$ServerFlavorListStep0 = (Invoke-RestMethod -Uri $DFWFlavorURI  -Headers $HeaderDictionary)
    [xml]$ServerFlavorListFinal = ($ServerFlavorListStep0.innerxml)
    
    $ServerFlavorListFinal.Flavors.Flavor | Sort-Object id | ft $FlavorListTable -AutoSize
    }

elseif ($Region -eq "ORD") {

    Get-AuthToken

    [xml]$ServerFlavorListStep0 = (Invoke-RestMethod -Uri $DFWFlavorURI  -Headers $HeaderDictionary)
    [xml]$ServerFlavorListFinal = ($ServerFlavorListStep0.innerxml)
    
    $ServerFlavorListFinal.Flavors.Flavor | Sort-Object id | ft $FlavorListTable -AutoSize

    }

else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudServerFlavors cmdlet will pull down a list of Rackspace Cloud flavors. Flavors are the predefined resource templates in Openstack.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerFlavors -Region DFW
 This example shows how to get flavor data from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails ORD
 This example shows how to get flavor data from the ORD region, without specifying the parameter name itself.
#>
}

function Add-CloudServer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerName,
        [Parameter(Position=1,Mandatory=$true)]
        [int]$CloudServerFlavorID,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$CloudServerImageID,
        [Parameter(Position=3,Mandatory=$false)]
        [string]$CloudServerNetwork1ID,
        [Parameter(Position=4,Mandatory=$false)]
        [string]$CloudServerNetwork2ID,
        [Parameter(Position=5,Mandatory=$false)]
        [string]$CloudServerNetwork3ID,
        [Parameter(Position=6,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=7,Mandatory=$false)]
        [switch]$Isolated
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNewServerURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers.xml"
        Set-Variable -Name ORDNewServerURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers.xml"

        Get-AuthToken

    if ($CloudServerNetwork1ID) {


        if ($Isolated) {
            [xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <server xmlns="http://docs.openstack.org/compute/api/v1.1" 
                imageRef="'+$CloudServerImageID+'"
                flavorRef="'+$CloudServerFlavorID+'"
                name="'+$CloudServerName+'">
                <networks>
                    <uuid>'+$CloudServerNetwork1ID+'</uuid>
                </networks>
            </server>'
            }

            else {
            [xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<server xmlns="http://docs.openstack.org/compute/api/v1.1" 
	imageRef="'+$CloudServerImageID+'" 
	flavorRef="'+$CloudServerFlavorID+'" 
	name="'+$CloudServerName+'">
	<networks>
		<uuid>00000000-0000-0000-0000-000000000000</uuid>
		<uuid>11111111-1111-1111-1111-111111111111</uuid>
		<uuid>'+$CloudServerNetwork1ID+'</uuid>
	</networks>
</server>'
            }
    }

    elseif ($CloudServerNetwork2ID) {

            if ($Isolated) {
            [xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <server xmlns="http://docs.openstack.org/compute/api/v1.1" 
                imageRef="'+$CloudServerImageID+'"
                flavorRef="'+$CloudServerFlavorID+'"
                name="'+$CloudServerName+'">
                <networks>
                    <uuid>'+$CloudServerNetwork1ID+'</uuid>
                    <uuid>'+$CloudServerNetwork2ID+'</uuid>
                </networks>
            </server>'
            }

            else {
            [xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <server xmlns="http://docs.openstack.org/compute/api/v1.1" 
                imageRef="'+$CloudServerImageID+'"
                flavorRef="'+$CloudServerFlavorID+'"
                name="'+$CloudServerName+'">
                <networks>
                    <uuid>'+$CloudServerNetwork1ID+'</uuid>
                    <uuid>'+$CloudServerNetwork2ID+'</uuid>
                    <uuid>00000000-0000-0000-0000-000000000000</uuid>
                    <uuid>11111111-1111-1111-1111-111111111111</uuid>
                </networks>
            </server>'
            }

    }

    elseif ($CloudServerNetwork3ID) {

            if ($Isolated) {
            [xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <server xmlns="http://docs.openstack.org/compute/api/v1.1" 
                imageRef="'+$CloudServerImageID+'"
                flavorRef="'+$CloudServerFlavorID+'"
                name="'+$CloudServerName+'">
                <networks>
                    <uuid>'+$CloudServerNetwork1ID+'</uuid>
                    <uuid>'+$CloudServerNetwork2ID+'</uuid>
                    <uuid>'+$CloudServerNetwork3ID+'</uuid>
                </networks>
            </server>'
            }

            else {
            [xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <server xmlns="http://docs.openstack.org/compute/api/v1.1" 
                imageRef="'+$CloudServerImageID+'"
                flavorRef="'+$CloudServerFlavorID+'"
                name="'+$CloudServerName+'">
                <networks>
                    <uuid>'+$CloudServerNetwork1ID+'</uuid>
                    <uuid>'+$CloudServerNetwork2ID+'</uuid>
                    <uuid>'+$CloudServerNetwork3ID+'</uuid>
                    <uuid>00000000-0000-0000-0000-000000000000</uuid>
                    <uuid>11111111-1111-1111-1111-111111111111</uuid>
                </networks>
            </server>'
            }
    }

    else {
    [xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <server xmlns="http://docs.openstack.org/compute/api/v1.1" 
                imageRef="'+$CloudServerImageID+'"
                flavorRef="'+$CloudServerFlavorID+'"
                name="'+$CloudServerName+'">
            </server>'
            }
 
 if ($Region -eq "DFW") {
        
        $NewCloudServer = Invoke-RestMethod -Uri $DFWNewServerURI -Headers $HeaderDictionary -Body $NewCloudServerXMLBody -ContentType application/xml -Method Post
        $NewCloudServerInfo = $NewCloudServer.innerxml

        Write-Host "The following is the ID and password of your new server. Please wait 10 seconds for a refreshed Cloud Server list."

        $NewCloudServer.Server | ft $newservertable

        Sleep 10

        Get-CloudServers DFW
                                   }

elseif ($Region -eq "ORD") {
        
        $NewCloudServer = Invoke-RestMethod -Uri $ORDNewServerURI -Headers $HeaderDictionary -Body $NewCloudServerXMLBody -ContentType application/xml -Method Post
        $NewCloudServerInfo = $NewCloudServer.innerxml

        Write-Host "The following is the ID and password of your new server. Please wait 10 seconds for a refreshed Cloud Server list."

        $NewCloudServer.Server | ft $newservertable

        Sleep 10

        Get-CloudServers ORD
                                   }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-CloudServer cmdlet will create a new Rackspace cloud server in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerName
 Use this parameter to define the name of the server you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER CloudServerFlavorID
 Use this parameter to define the ID of the flavor that you would like applied to your new server.  If you are unsure of which flavor to use, run the "Get-CloudServerFlavors" command.

 .PARAMETER CloudServerImageID
 Use this parameter to define the ID of the image that you would like to build your new server from.  This can be a Rackspace provided base image, or an existing custom image snapshot that you've previously taken.  If you are unsure of which image to use, run the "Get-CloudServerImages" command.

 .PARAMETER CloudServerNetwork1ID
 Use this parameter to define the UUID of the first custom network you would like this server attached to.  If you do not later use the -Isolated switch, this server will be connected to this network and Rackspace default networks.

 .PARAMETER CloudServerNetwork2ID
 Use this parameter to define the UUID of the second custom network you would like this server attached to.  If you do not later use the -Isolated switch, this server will be connected to this network and Rackspace default networks. If you have not defined -CloudServerNetowrk1ID, please do NOT use this field.

 .PARAMETER CloudServerNetwork3ID
 Use this parameter to define the UUID of the second custom network you would like this server attached to.  If you do not later use the -Isolated switch, this server will be connected to this network and Rackspace default networks. If you have not defined -CloudServerNetowrk1ID & -CloudServerNetwork2ID please do NOT use this field.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .PARAMETER Isolated
 Use this parameter to indiacte that you'd like this server to be in an isolated network.  Using this switch will render this server ONLY connected to the UUIDs of the custom networks you define.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer -CloudServerName NewlyCreatedTestServer -CloudServerFlavorID 3 -CloudServerImageID 26fec9f2-2fb5-4e5e-a19f-0d12540ec639 -Region DFW
 This example shows how to spin up a new Windows Server 2012 cloud server called "NewlyCreatedTestServer" , with 1GB RAM, 1 vCPU, and 40GB of local storage, in the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer NewlyCreatedTestServer1 4 c195ef3b-9195-4474-b6f7-16e5bd86acd0 ORD
 This example shows how to spin up a new CentOS 6.3 cloud server called "NewlyCreatedTestServer1", with 2GB RAM, 2 vCPU, and 80GB of lcoal storage, in the ORD region. Notice how parameter names were not needed in the command to save time.
#>
}

function Add-CloudServerImage {

    Param(
        [string]$CloudServerID,
        [string]$NewImageName,
        [string]$Region
        )
    
    ## Setting variables needed to execute this function
    $NewImageXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<createImage
    xmlns="http://docs.openstack.org/compute/api/v1.1"
    name="'+$NewImageName+'">
</createImage>'

if ($Region -eq "DFW") {

    Get-AuthToken
    
    Set-Variable -Name ServerImageURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerImageURI -Headers $HeaderDictionary -Body $NewImageXMLBody -ContentType application/xml -Method Post

    Write-Host "Your new Rackspace Cloud Server image is being created."

    }

elseif ($Region -eq "ORD") {

    Get-AuthToken
    
    Set-Variable -Name ServerImageURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerImageURI -Headers $HeaderDictionary -Body $NewImageXMLBody -ContentType application/xml -Method Post

    Write-Host "Your new Rackspace Cloud Server image is being created."

    }

else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Add-CloudServerImage cmdlet will create a new Rackspace cloud server image snapshot for the provided server id.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want explicit details. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER NewImageName
 Use this parameter to define the name of the image snapshot that is about to be taken.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServerImage  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -NewImageName SnapshotCopy1 -Region DFW
 This example shows how to create a new server image snapshot of a serve, UUID of "abc123ef-9876-abcd-1234-123456abcdef", and the snapshot being titled "SnapshotCopy1" in the DFW region.
#>
}

function Update-CloudServer {

    Param(
        [Parameter(Mandatory=$false)]
        [switch]$UpdateName,
        [Parameter(Mandatory=$false)]
        [switch]$UpdateIPv4Address, 
        [Parameter(Mandatory=$false)]
        [switch]$UpdateIPv6Address,
        [Parameter(Mandatory=$false)]
        [switch]$UpdateAdminPassword,
        [Parameter(Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Mandatory=$true)]
        [string]$Region,
        [Parameter(Mandatory=$true)]
        [string]$NewNameOrAddressOrPasswordValue
        )

if ($Region -eq "DFW") {

    if ($UpdateName) {

    ## Setting variables needed to execute this function
    [xml]$UpdateCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <server
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        name="'+$NewNameOrAddressOrPasswordValue+'"/>'
                
    Get-AuthToken
    
    Set-Variable -Name ServerUpdateURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Put | Out-Null
                
    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region
                
                }

    elseif ($UpdateIPv4Address) {

    [xml]$UpdateCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <server
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        accessIPv4="'+$NewNameOrAddressOrPasswordValue+'"
        accessIPv6="'+$IPv6+'"
    />'
    
    Get-AuthToken
    
    Set-Variable -Name ServerUpdateURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post | Out-Null

    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region
                    
                    }

    elseif ($UpdateIPv6Address) {

    ## Setting variables needed to execute this function
    [xml]$UpdateCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <server
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        accessIPv6="'+$NewNameOrAddressOrPasswordValue+'"
    />'
    
    Get-AuthToken
    
    Set-Variable -Name ServerUpdateURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post | Out-Null

    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region
                    
                    }

    elseif ($UpdateAdminPassword) {
    
    ## Setting variables needed to execute this function
    [xml]$UpdateAdminPasswordXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <changePassword
    xmlns="http://docs.openstack.org/compute/api/v1.1"
    adminPass="'+$NewNameOrAddressOrPasswordValue+'"/>'

    Get-AuthToken
    
    Set-Variable -Name ServerPasswordUpdateURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerPasswordUpdateURI -Headers $HeaderDictionary -Body $UpdateAdminPasswordXMLBody -ContentType application/xml -Method Post

    Write-Host "Your Cloud Server has been updated."
                        }
    }

elseif ($Region -eq "ORD") {

    if ($UpdateName) {

    ## Setting variables needed to execute this function
    [xml]$UpdateCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <server
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        name="'+$NewNameOrAddressOrPasswordValue+'"/>'
                
    Get-AuthToken
    
    Set-Variable -Name ServerUpdateURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Put | Out-Null
                
    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region
                
                }

    elseif ($UpdateIPv4Address) {

    [xml]$UpdateCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <server
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        accessIPv4="'+$NewNameOrAddressOrPasswordValue+'"
        accessIPv6="'+$IPv6+'"
    />'
    
    Get-AuthToken
    
    Set-Variable -Name ServerUpdateURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post | Out-Null

    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region
                    
                    }

    elseif ($UpdateIPv6Address) {

    [xml]$UpdateCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <server
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        accessIPv6="'+$NewNameOrAddressOrPasswordValue+'"
    />'
    
    Get-AuthToken
    
    Set-Variable -Name ServerUpdateURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post | Out-Null

    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region
                    
                    }

    elseif ($UpdateAdminPassword) {
    [xml]$UpdateAdminPasswordXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <changePassword
    xmlns="http://docs.openstack.org/compute/api/v1.1"
    adminPass="'+$NewNameOrAddressOrPasswordValue+'"/>'

    Get-AuthToken
    
    Set-Variable -Name ServerPasswordUpdateURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerPasswordUpdateURI -Headers $HeaderDictionary -Body $UpdateAdminPasswordXMLBody -ContentType application/xml -Method Post

    Write-Host "Your Cloud Server has been updated."
                        }
    }

else {

    Send-RegionError
    }


<#
 .SYNOPSIS
 This command will update the name, IPv4/IPv6 address, and/or the administrative/root password of your Rackspace Cloud Server.

 .DESCRIPTION
 Using this command, you will be able to update: 
 
 1) The name of the Cloud Server
 2) The IPv4/IPv6 address
 3) The administrative/root password
 
 The usage of the command would look like this "Update-CloudServer -Switch NewValue".

 .PARAMETER UpdateName
 Using this switch would indicate that you would like to change the name of your Rackspace Cloud server.

 .PARAMETER UpdateIPv4Address
 Using this switch would indicate that you would like to change the IPv4 address of your Rackspace Cloud server.

 .PARAMETER UpdateIPv6Address
 Using this switch would indicate that you would like to change the IPv6 address of your Rackspace Cloud server.

 .PARAMETER UpdateAdminPassword
 Using this switch would indicate that you would like to change the adminitrative/root password within your Rackspace Cloud Server.

 .PARAMETER CloudServerID
 This field is meant to be the 32 character identifier of your Rackspace Cloud Server.  If you need to figure out the ID, run the "Get-CloudServers" command to retrieve a full list of servers and their IDs from your account.

 .PARAMETER NewNameOrAddressOrPasswordValue
 This field is where you would enter the *new* value of whatever you are trying to change.  If you are changing the name of the Rackspace Cloud Server, this is where you would enter the new name.

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -UpdateName abc123ef-9876-abcd-1234-123456abcdef  New-Windows-Web-Server
 This example shows the command to rename a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new name of "New-Windows-Web-Server".

  .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -UpdateAdminPassword abc123ef-9876-abcd-1234-123456abcdef  NewC0mplexPassw0rd!
 This example shows the command to update the adminsitrative password of a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new password of "NewC0mplexPassw0rd!".
#>
}

function Restart-CloudServer {

    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$True)]
        [string]$Region,
        [Parameter(Position=2,Mandatory=$False)]
        [switch]$Hard
        )

## Setting variables needed to execute this function
$RestartServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<reboot
    xmlns="http://docs.openstack.org/compute/api/v1.1"
    type="SOFT"/>'

if ($Region -eq "DFW") {

    Get-AuthToken

    Set-Variable -Name ServerRestartURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post

    Write-Host "Your Cloud Server will be soft rebooted based on your input."

    

        if ($hard) {
        $RestartServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <reboot
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        type="HARD"/>'

        Set-Variable -Name ServerRestartURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action" -Scope Global

        Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post

        Write-Host "Your Cloud Server will be hard rebooted based on your input."
                }

    }

elseif ($Region -eq "ORD") {

    Get-AuthToken

    Set-Variable -Name ServerRestartURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post

    Write-Host "Your Cloud Server will be soft rebooted based on your input."

        if ($hard) {
        $RestartServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <reboot
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        type="HARD"/>'

        Set-Variable -Name ServerRestartURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action" -Scope Global

        Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post

        Write-Host "Your Cloud Server will be hard rebooted based on your input."
                }
    
    
    }

<#
 .SYNOPSIS
 The Restart-CloudServer cmdlet will carry out a soft reboot of the specified cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want explicit details. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

  .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .PARAMETER Hard
 Use this switch to indicate that you would like the server be hard rebooted, as opposed to the default of a soft reboot.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW
 This example shows how to request a soft reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW -Hard
 This example shows how to request a hard reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the DFW region.
#>    
 }

function Optimize-CloudServer {

    Param(
        [Parameter(Mandatory=$False)]
        [switch]$Confirm,
        [Parameter(Mandatory=$False)]
        [switch]$Revert,
        [Parameter(Mandatory=$True)]
        [string]$CloudServerID,
        [Parameter(Mandatory=$True)]
        [string]$Region,
        [Parameter(Mandatory=$False)]
        [int]$CloudServerFlavorID
        )

if ($Region -eq "DFW") {    
    
    if ($Confirm) {
      
      ## Setting variables needed to execute this function
      $ConfirmServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
      <confirmResize
      xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

      Set-Variable -Name ServerConfirmURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

      Invoke-RestMethod -Uri $ServerConfirmURI -Headers $HeaderDictionary -Body $ConfirmServerXMLBody -ContentType application/xml -Method Post

      Write-Host "Your resized server has been confirmed."

            }
    
    elseif ($Revert) {
      
      ## Setting variables needed to execute this function
      $ConfirmServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
      <revertResize
      xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

      Set-Variable -Name ServerConfirmURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

      Invoke-RestMethod -Uri $ServerConfirmURI -Headers $HeaderDictionary -Body $ConfirmServerXMLBody -ContentType application/xml -Method Post

      Write-Host "Your resized server has been confirmed."

            }
    
    else {
    
    ## Setting variables needed to execute this function
    $OptimizeServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <resize xmlns="http://docs.openstack.org/compute/api/v1.1"
    flavorRef="'+$CloudServerFlavorID+'"/>'

    Get-AuthToken
    
    Set-Variable -Name ServerOptimizeURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerOptimizeURI -Headers $HeaderDictionary -Body $OptimizeServerXMLBody -ContentType application/xml -Method Post

    Write-Host "Your Cloud Server will be resized based on your input. Run Get-CloudServers to check on the status of the build and be sure to confirm the resized server after rebuild."

    }
}

elseif ($Region -eq "ORD") {    
    
    if ($Confirm) {
      
      ## Setting variables needed to execute this function
      $ConfirmServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
      <confirmResize
      xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

      Set-Variable -Name ServerConfirmURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

      Invoke-RestMethod -Uri $ServerConfirmURI -Headers $HeaderDictionary -Body $ConfirmServerXMLBody -ContentType application/xml -Method Post

      Write-Host "Your resized server has been confirmed."

            }

    else {
    
    ## Setting variables needed to execute this function
    $OptimizeServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <resize xmlns="http://docs.openstack.org/compute/api/v1.1"
    flavorRef="'+$CloudServerFlavorID+'"/>'

    Get-AuthToken
    
    Set-Variable -Name ServerOptimizeURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerOptimizeURI -Headers $HeaderDictionary -Body $OptimizeServerXMLBody -ContentType application/xml -Method Post

    Write-Host "Your Cloud Server will be resized based on your input. Run Get-CloudServers to check on the status of the build and be sure to confirm the resized server after rebuild."
    }
}
<#
 .SYNOPSIS
 The Optimize-CloudServer cmdlet will resize the specified cloud server to a new flavor.  After the original request, you can also use this command to either REVERT your changes, or CONFIRM them.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want explicit details. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .PARAMETER CloudServerFlavorID
 Use this parameter to define the ID of the flavor that you would like to resize to for the server specified.  If you are unsure of which flavor to use, run the "Get-CloudServerFlavors" command.

 .PARAMETER Confirm
 Use this switch to indicate that you would like to confirm the requested resize be fully applied after testing your cloud server.  You should only use the confirm switch after the original request to resize the server and have verified everything is working as expected.

 .PARAMETER Revert
 Use this switch to indicate that you would like to revert the newly resized server to its previous state.  This will permanently undo the original resize operation.

 .EXAMPLE
 PS C:\Users\Administrator> Optimize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW -CloudServerFlavorID 3
 This example shows how to resize a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the DFW region, to a new size of 1GB RAM, 1 vCPU, 40GB storage.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Confirm
 This example shows how to confirm the resizing of a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the ORD region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Revert
 This example shows how to revert the resizing of a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the ORD region, back to its previous size.
#>
}

function Remove-CloudServer { 

    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$True)]
        [string]$Region
        )

if ($Region -eq "DFW") {

    Get-AuthToken
    
    ## Setting variables needed to execute this function
    Set-Variable -Name ServerDeleteURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"
    
    Invoke-RestMethod -Uri $ServerDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your server has been scheduled for deletion. This action will take up to a minute to complete."

    }

elseif ($Region -eq "ORD") {

    Get-AuthToken
    
    ## Setting variables needed to execute this function
    Set-Variable -Name ServerDeleteURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"
    
    Invoke-RestMethod -Uri $ServerDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your server has been scheduled for deletion. This action will take up to a minute to complete."

    }
<#
 .SYNOPSIS
 The Remove-CloudServer cmdlet will permanently delete a cloud server from your account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want explicit details. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW 
 This example shows how to delete a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  abc123ef-9876-abcd-1234-123456abcdef ORD
 This example shows how to delete a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the ORD region, without using the parameter names.
#>
}

function Remove-CloudServerImage {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerImageID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )


if ($Region -eq "DFW") {
    
    Get-AuthToken
    
    ## Setting variables needed to execute this function
    Set-Variable -Name DFWImageDeleteURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/images/$CloudServerImageID"

    Invoke-RestMethod -Uri $DFWImageDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your Rackspace Cloud Server Image has been deleted."

    }

elseif ($Region -eq "ORD") {
    
    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name ordImageDeleteURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/images/$CloudServerImageID"

    Invoke-RestMethod -Uri $ORDImageDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your Rackspace Cloud Server Image has been deleted."

    }

else {
    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-CloudServerImage cmdlet will permanently delete a cloud server image snapshot from your account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerImageID
 Use this parameter to define the ID of the image that you would like to delete. If you are unsure of the image ID, run the "Get-CloudServerImages" command.

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServerImage  -CloudServerImageID abc123ef-9876-abcd-1234-123456abcdef -Region DFW 
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServerImage  abc123ef-9876-abcd-1234-123456abcdef ORD
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the ORD region, without using the parameter names.
#>
}

function Set-CloudServerRescueMode {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )
    
    ## Setting variables needed to execute this function
    [xml]$RescueModeXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <rescue xmlns="http://docs.openstack.org/compute/ext/rescue/api/v1.1" />'


if ($Region -eq "DFW") {

    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name RescueModeDFWURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    $RescueMode = Invoke-RestMethod -Uri $RescueModeDFWURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post
    $RescueModePass = $RescueMode.adminPass

    Write-Host "Rescue Mode takes 5 - 10 minutes to enable. Please do not interact with this server again until it's status is RESCUE.
    Your temporary password in rescue mode is:

    $RescueModePass
    "

}

elseif ($Region -eq "ORD") {

    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name RescueModeORDURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    $RescueMode = Invoke-RestMethod -Uri $RescueModeORDURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post
    $RescueModePass = $RescueMode.adminPass

    Write-Host "Rescue Mode takes 5 - 10 minutes to enable. Please do not interact with this server again until it's status is RESCUE.
    Your temporary password in rescue mode is:

    $RescueModePass
    "

}

else {
    
    Send-RegionError

    }

}

function Remove-CloudServerRescueMode {

    Param(
        [string]$CloudServerID,
        [string]$Region
        )
    
    ## Setting variables needed to execute this function
    [xml]$RescueModeXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<unrescue xmlns="http://docs.rackspacecloud.com/servers/api/v1.1" />'

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name RescueModeDFWURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    $RescueMode = Invoke-RestMethod -Uri $RescueModeDFWURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post

    Write-Host "Your server is being restored to normal service.  Please wait for the status of the server to show ACTIVE before carrying out any further commands against it."

}

elseif ($Region -eq "ORD") {

    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name RescueModeORDURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    $RescueMode = Invoke-RestMethod -Uri $RescueModeORDURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post

    Write-Host "Your server is being restored to normal service.  Please wait for the status of the server to show ACTIVE before carrying out any further commands against it."

}

else {
    
    Send-RegionError

    }

}


## Cloud Block Storage Cmdlets

function Get-CloudBlockStorageTypes {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/types.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/types.xml"

        if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolTypeStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary)
    [xml]$VolTypeFinal = ($VolTypeStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolTypeFinal.volume_types.volume_type | ft $VolTypeTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolTypeStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary)
    [xml]$VolTypeFinal = ($VolTypeStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolTypeFinal.volume_types.volume_type | ft $VolTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudBlockStorageVol cmdlet will retrieve a list of all attributes for a provided cloud block storage volume.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudBlockStorageVolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to query.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol -Region DFW 
 This example shows how to list all cloud block storage volumes in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol ORD
 This example shows how to list all cloud block storage volumes in the ORD region, without parameter names.
#>
}


function Get-CloudBlockStorageVolList {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes.xml"

    if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolListStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary)
    [xml]$VolListFinal = ($VolListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolListFinal.volumes.volume | ft $VolListTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolListStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary)
    [xml]$VolListFinal = ($VolListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolListFinal.volumes.volume | ft $VolListTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudBlockStorageVols cmdlet will retrieve a list of all cloud block storage volumes for the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVols -Region DFW 
 This example shows how to list all cloud block storage volumes in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVols ORD
 This example shows how to list all cloud block storage volumes in the ORD region, without parameter names.
#>
}

function Get-CloudBlockStorageVol {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudBlockStorageVolID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes/$CloudBlockStorageVolID.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes/$CloudBlockStorageVolID.xml"

    if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolListStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary)
    [xml]$VolListFinal = ($VolListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolListFinal.volume | ft $VolTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolListStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary)
    [xml]$VolListFinal = ($VolListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolListFinal.volume | ft $VolTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudBlockStorageVol cmdlet will retrieve a list of all attributes for a provided cloud block storage volume.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudBlockStorageVolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to query.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol -Region DFW 
 This example shows how to list details for a cloud block storage volume in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol ORD
 This example shows how to list details for a cloud block storage volume in the DFW region, without parameter names.
#>
}

function Add-CloudBlockStorageVol {

    Param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $CloudBlockStorageVolName,
        [Parameter (Position=2, Mandatory=$false)]
        [string] $CloudBlockStorageVolDesc,
        [Parameter (Position=2, Mandatory=$true)]
        [int] $CloudBlockStorageVolSize,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $CloudBlockStorageVolType,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $Region
    )

    ## Force switch variable setting
    if ($CloudBlockStorageVolSize -lt 100) {
        Write-Host "You must enter a volume size of greater than 100GB." -ForegroundColor Red
        break
    }

    elseif ($CloudBlockStorageVolSize -gt 1024) {
        Write-Host "You must enter a volume size of less than 1024GB." -ForegroundColor Red
        Break
    }

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes.xml"

    ## Create XML request
    [xml]$NewVolXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<volume xmlns="http://docs.rackspace.com/volume/api/v1"
        display_name="'+$CloudBlockStorageVolName+'"
        display_description="'+$CloudBlockStorageVolDesc+'"
        size="'+$CloudBlockStorageVolSize+'"
        volume_type="'+$CloudBlockStorageVolType+'">
 
</volume>'

    if ($Region -eq "DFW") {
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Body $NewVolXMLBody -ContentType application/xml -Method Post)
    [xml]$VolFinal = ($VolStep0.innerxml)

        $VolFinal.volume | ft $VolTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Body $NewVolXMLBody -Method Post)
    [xml]$VolFinal = ($VolSnapStep0.innerxml)

        $VolFinal.volume | ft $VolTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Add-CloudBlockStorageVol cmdlet will add a cloud block storage volume.

 .DESCRIPTION
 See synopsis.

  .PARAMETER CloudBlockStorageVolName
 Use this parameter to define the name of the volume you are about to make.

 .PARAMETER CloudBlockStorageVolDesc
 Use this parameter to define the description of the volume you are about to make.

 .PARAMETER CloudBlockStorageVolSize
 Use this parameter to define the size of the volume you are about to make. This must be between 100 and 1024.

 .PARAMETER CloudBlockStorageVolType
 Use this parameter to define the type of the volume you are about to make. If you are unsure of what to enter, please run the Get-CloudBlockStorageTypes cmdlet to get valid parameter entries.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudBlockStorageVol -CloudBlockStorageVolName Test2 -CloudBlockStorageVolDesc "another backupt test" -CloudBlockStorageVolSize 150 -CloudBlockStorageVolType SATA -Region dfw
 This example shows how to add a cloud block storage volume in the DFW region.
#>
}

function Remove-CloudBlockStorageVol {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudBlockStorageVolID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes/$CloudBlockStorageVolID.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes/$CloudBlockStorageVolID.xml"

    if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Method Delete)
    [xml]$VolFinal = ($VolStep0.innerxml)

        Write-Host "The volume has been deleted."
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Method Delete)
    [xml]$VolFinal = ($VolStep0.innerxml)

        Write-Host "The volume has been deleted."
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Remove-CloudBlockStorageVol cmdlet will remove a cloud block storage volume.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudBlockStorageVolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to remove.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageVol  -CloudBlockStorageVolID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Region dfw
 This example shows how to remove a cloud block storage volume from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageVol 5ea333b3-cdf7-40ee-af60-9caf871b15fa ORD
 This example shows how to list details for a cloud block storage volume in the DFW region, without parameter names.
#>
}


function Get-CloudBlockStorageSnapList {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots.xml"

        if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolSnapFinal.snapshots.snapshot | ft $VolSnapTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolSnapFinal.snapshots.snapshot | ft $VolSnapTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudBlockStorageSnapList cmdlet will retrieve a list of all snapshots for a provided cloud account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnapList -Region DFW 
 This example shows how to list all cloud block storage snapshots in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol ORD
 This example shows how to list all cloud block storage snapshots in the ORD region, without parameter names.
#>
}

function Get-CloudBlockStorageSnap {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudBlockStorageSnapID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots/$CloudBlockStorageSnapID.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots/$CloudBlockStorageSnapID.xml"

    if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolSnapFinal.snapshot | ft $VolSnapTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $VolSnapFinal.snapshot | ft $VolSnapTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudBlockStorageSnap cmdlet will retrieve a list of all attributes for a provided cloud block storage snapshot.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudBlockStorageSnapID
 Use this parameter to define the ID of the cloud block storage snapshot that you would like to query.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnap -Region DFW 
 This example shows how to list details for a cloud block storage snapshot in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol ORD
 This example shows how to list details for a cloud block storage snapshot in the DFW region, without parameter names.
#>
}

function Add-CloudBlockStorageSnap {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudBlockStorageVolID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $CloudBlockStorageSnapName,
        [Parameter (Position=2, Mandatory=$false)]
        [string] $CloudBlockStorageSnapDesc,
        [Parameter (Position=3, Mandatory=$true)]
        [string] $Region,
        [Parameter (Position=4, Mandatory=$false)]
        [switch] $Force
    )

    ## Force switch variable setting
    if ($force) {
        $ForceOut = "true"
    }

    else {
        $ForceOut = "false"
    }

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots.xml"

    ## Create XML request
    [xml]$NewSnapXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<snapshot xmlns="http://docs.rackspace.com/volume/api/v1"
          name="'+$CloudBlockStorageSnapName+'"
          display_name="'+$CloudBlockStorageSnapName+'"
          display_description="'+$CloudBlockStorageSnapDesc+'"
          volume_id="'+$CloudBlockStorageVolID+'"
          force="'+$ForceOut+'" />'

    if ($Region -eq "DFW") {
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Body $NewSnapXMLBody -ContentType application/xml -Method Post)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        $VolSnapFinal.snapshot | ft $VolSnapTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Body $NewSnapXMLBody -Method Post)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        $VolSnapFinal.snapshot | ft $VolSnapTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Add-CloudBlockStorageSnap cmdlet will add a cloud block storage snapshot.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudBlockStorageVolID
 Use this parameter to define the ID of the cloud block storage volume that you would like to snapshot.

 .PARAMETER CloudBlockStorageSnapName
 Use this parameter to define the name of the snapshot you are about to take.

 .PARAMETER CloudBlockStorageSnapDesc
 Use this parameter to define the description of the snapshot you are about to take.

 .PARAMETER Force
 Use this switch to indicate whether to snapshot the volume, even if the volume is attached and in use.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudBlockStorageSnap -CloudBlockStorageVolID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -CloudBlockStorageSnapName Snapshot-Test -CloudBlockStorageSnapDesc This is a test snapshot -Region DFW -Force
 This example shows how to add a cloud block storage snapshot in the DFW region.
#>
}

function Remove-CloudBlockStorageSnap {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudBlockStorageSnapID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWCBSURI -Value "https://dfw.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots/$CloudBlockStorageSnapID.xml"
    Set-Variable -Name ORDCBSURI -Value "https://ord.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots/$CloudBlockStorageSnapID.xml"

    if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Method Delete)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        Write-Host "The snapshot has been deleted."
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Method Delete)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        Write-Host "The snapshot has been deleted."
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Remove-CloudBlockStorageSnap cmdlet will remove a cloud block storage snapshot.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudBlockStorageSnapID
 Use this parameter to define the ID of the cloud block storage snapshot that you would like to query.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageSnap  -CloudBlockStorageSnapID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Region dfw
 This example shows how to remove a cloud block storage snapshot from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageSnap 5ea333b3-cdf7-40ee-af60-9caf871b15fa ORD
 This example shows how to list details for a cloud block storage snapshot in the DFW region, without parameter names.
#>
}






## Cloud Network API Cmdlets

function Get-CloudNetworks{

    Param(
        [Parameter (Position=0, Mandatory=$false)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWNetworksURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/os-networksv2.xml"
    Set-Variable -Name ORDNetworksURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/os-networksv2.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available networks and storing data into a variable
    [xml]$NetworkListStep0 = (Invoke-RestMethod -Uri $DFWNetworksURI  -Headers $HeaderDictionary)
    [xml]$NetworkListFinal = ($NetworkListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $NetworkListFinal.networks.network | Sort-Object label | ft $NetworkListTable -AutoSize

}

elseif ($Region -eq "ORD") {  
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available networks and storing data into a variable
    [xml]$NetworkListStep0 = (Invoke-RestMethod -Uri $ORDNetworksURI  -Headers $HeaderDictionary)
    [xml]$NetworkListFinal = ($NetworkListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $NetworkListFinal.networks.network | Sort-Object label | ft $NetworkListTable -AutoSize

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudNetworks cmdlet will pull down a list of all Rackspace Cloud Networks on your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudNetworks -Region DFW
 This example shows how to get a list of all networks currently deployed in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudNetworks ORD
 This example shows how to get a list of all networks deployed in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.
#>
}

function Add-CloudNetwork {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudNetworkLabel,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudNetworkCIDR,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNewNetURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/os-networksv2.xml"
        Set-Variable -Name ORDNewNetURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/os-networksv2.xml"

        Get-AuthToken

[xml]$NewCloudNetXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<network
  cidr="'+$CloudNetworkCIDR+'"
  label="'+$CloudNetworkLabel+'"
/>'
 
 if ($Region -eq "DFW") {
        
        $NewCloudNet = Invoke-RestMethod -Uri $DFWNewNetURI -Headers $HeaderDictionary -Body $NewCloudNetXMLBody -ContentType application/xml -Method Post
        [xml]$NewCloudNetInfo = $NewCloudNet.innerxml

        Write-Host "You have just created the following cloud network:"

        $NewCloudNetInfo.network

        }

elseif ($Region -eq "ORD") {

        $NewCloudNet = Invoke-RestMethod -Uri $ORDNewNetURI -Headers $HeaderDictionary -Body $NewCloudNetXMLBody -ContentType application/xml -Method Post
        [xml]$NewCloudNetInfo = $NewCloudNet.innerxml

        Write-Host "You have just created the following cloud network:"

        $NewCloudNetInfo.network

        }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-CloudNetwork cmdlet will create a new Rackspace cloud network in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudNetworkLabel
 Use this parameter to define the name/label of the cloud network you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER CloudNetworkCIDR
 Use this parameter to define the IP block that is going to be used for this cloud network.  This must be written in CIDR notation, for example, "172.16.0.0/24" without the quotes.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudNetwork -CloudNetworkLabel DBServers -CloudNetworkCIDR 192.168.101.0/24 -Region DFW
 This example shows how to spin up a new cloud network called DBServers, which will service IP block 192.168.101.0/24, in the DFW region.

.EXAMPLE
 PS C:\Users\Administrator> Add-CloudNetwork PaymentServers 192.168.101.0/24 ORD
 This example shows how to spin up a new cloud network called PaymentServers, which will service IP block 192.168.101.0/24 in the ORD region, without using the parameter names.
#>
}

function Remove-CloudNetwork {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudNetworkID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWDelNetURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/os-networksv2/$CloudNetworkID.xml"
        Set-Variable -Name ORDDelNetURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/os-networksv2/$CloudNetworkID.xml"

        Get-AuthToken

 if ($Region -eq "DFW") {
        
        $DelCloudNet = Invoke-RestMethod -Uri $DFWDelNetURI -Headers $HeaderDictionary -Method DELETE

        Write-Host "The cloud network has been deleted."

        }

elseif ($Region -eq "ORD") {

        $DelCloudNet = Invoke-RestMethod -Uri $ORDDelNetURI -Headers $HeaderDictionary -Method DELETE

        Write-Host "The cloud network has been deleted."

        }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-CloudNetwork cmdlet will delete Rackspace cloud network in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudNetworkID
 Use this parameter to define the name/label of the cloud network you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudNetwork -CloudNetworkID 88e316b1-8e69-4591-ba92-bea8bb1837f5 -Region ord
 This example shows how to delete a cloud network with an ID of 88e316b1-8e69-4591-ba92-bea8bb1837f5 from the ORD region.

.EXAMPLE
 PS C:\Users\Administrator> Remove-CloudNetwork 88e316b1-8e69-4591-ba92-bea8bb1837f5 DFW
 This example shows how to delete a cloud network with an ID of 88e316b1-8e69-4591-ba92-bea8bb1837f5 from the DFW region, without the parameter names.
#>
}


## Cloud Load Balancer API Cmdlets

function Get-CloudLoadBalancers{

    Param(
        [Parameter (Position=0, Mandatory=$false)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    [xml]$LBListStep0 = (Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary)
    [xml]$LBListFinal = ($LBListStep0.innerxml)

    ## Handling empty response bodies indicating that no load balancers exist in the queried data center
    if ($LBListFinal.loadBalancers.loadBalancer -eq $null) {

        Write-Host "You do not currently have any Cloud Load Balancers provisioned in the DFW region."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $LBListFinal.loadBalancers.loadBalancer | Sort-Object Name | ft $LBListTable -AutoSize

    }

}

elseif ($Region -eq "ORD") {  
    
    Get-AuthToken

    [xml]$LBListStep0 = (Invoke-RestMethod -Uri $ORDLBURI  -Headers $HeaderDictionary)
    [xml]$LBListFinal = ($LBListStep0.innerxml)

    if ($LBListFinal.loadBalancers.loadBalancer -eq $null) {

        Write-Host "You do not currently have any Cloud Load Balancers provisioned in the ORD region."

    }
    
    else {

        $LBListFinal.loadBalancers.loadBalancer | Sort-Object Name | ft $LBListTable -AutoSize

    }

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudLoadBalancers cmdlet will pull down a list of all Rackspace Cloud Load Balancers on your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancers -Region DFW
 This example shows how to get a list of all load balancers currently deployed in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancers ORD
 This example shows how to get a list of all load balancers deployed in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.
#>
}

function Get-CloudLoadBalancerDetails {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWLBDetailURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"
        Set-Variable -Name ORDLBDetailURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"

    if ($Region -eq "DFW") {

    Get-AuthToken

    [xml]$LBDetailStep0 = (Invoke-RestMethod -Uri $DFWLBDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$LBDetailFinal = ($LBDetailStep0.innerxml)

    ## Handling empty response bodies indicating that no servers exist in the queried data center
    if ($LBDetailFinal.loadBalancer -eq $null) {

        Write-Host "You have entered an incorrect Cloud Load Balancer ID."

    }

        $lbip0 = $LBDetailFinal.loadBalancer.virtualIps.virtualIp
        $nodeip0 = $LBDetailFinal.loadBalancer.nodes.node
        
        $lbipfinal = ForEach ($ip in $lbip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

        $nodeipfinal = ForEach ($ip in $nodeip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

    $LBDetailOut = @{"CLB Name"=($LBDetailFinal.loadbalancer.name);"CLB ID"=($LBDetailFinal.loadbalancer.id);"CLB Algorithm"=($LBDetailFinal.loadbalancer.algorithm);"CLB Timeout"=($LBDetailFinal.loadbalancer.timeout);"CLB Protocol"=($LBDetailFinal.loadbalancer.protocol);"CLB Port"=($LBDetailFinal.loadbalancer.port);"CLB Status"=($LBDetailFinal.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($LBDetailFinal.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($LBDetailFinal.loadbalancer.created.time);"CLB Updated"=($LBDetailFinal.loadbalancer.updated.time);"- CLB Node IDs"=($LBDetailFinal.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($LBDetailFinal.loadbalancer.nodes.node.port);"- CLB Node Condition"=($LBDetailFinal.loadbalancer.nodes.node.condition);"- CLB Node Status"=($LBDetailFinal.loadbalancer.nodes.node.status)}

    $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

    }

    elseif ($Region -eq "ORD") {

    Get-AuthToken

    [xml]$LBDetailStep0 = (Invoke-RestMethod -Uri $ORDLBDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$LBDetailFinal = ($LBDetailStep0.innerxml)

    ## Handling empty response bodies indicating that no servers exist in the queried data center
    if ($LBDetailFinal.loadBalancer -eq $null) {

        Write-Host "You have entered an incorrect Cloud Load Balancer ID."

    }
    
    $lbip0 = $LBDetailFinal.loadBalancer.virtualIps.virtualIp
        $nodeip0 = $LBDetailFinal.loadBalancer.nodes.node
        
        $lbipfinal = ForEach ($ip in $lbip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

        $nodeipfinal = ForEach ($ip in $nodeip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

    $LBDetailOut = @{"CLB Name"=($LBDetailFinal.loadbalancer.name);"CLB ID"=($LBDetailFinal.loadbalancer.id);"CLB Algorithm"=($LBDetailFinal.loadbalancer.algorithm);"CLB Timeout"=($LBDetailFinal.loadbalancer.timeout);"CLB Protocol"=($LBDetailFinal.loadbalancer.protocol);"CLB Port"=($LBDetailFinal.loadbalancer.port);"CLB Status"=($LBDetailFinal.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($LBDetailFinal.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($LBDetailFinal.loadbalancer.created.time);"CLB Updated"=($LBDetailFinal.loadbalancer.updated.time);"- CLB Node IDs"=($LBDetailFinal.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($LBDetailFinal.loadbalancer.nodes.node.port);"- CLB Node Condition"=($LBDetailFinal.loadbalancer.nodes.node.condition);"- CLB Node Status"=($LBDetailFinal.loadbalancer.nodes.node.status)}

    $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerDetails cmdlet will pull down a list of detailed information for a specific Rackspace Cloud Load Balancer.

 .DESCRIPTION
See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerDetails -CloudLBID 12345 -Region DFW
 This example shows how to get explicit data about one cloud load balancer from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerDetails 12345 ORD
 This example shows how to get explicit data about one cloud load balancer from the ORD region, without using the parameter names.
#>
}

function Get-CloudLoadBalancerProtocols{

    ## Setting variables needed to execute this function
    Set-Variable -Name PROTOCOLURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/protocols.xml"

    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    [xml]$LBProtocolListStep0 = (Invoke-RestMethod -Uri $PROTOCOLURI  -Headers $HeaderDictionary)
    [xml]$LBProtocolListFinal = ($LBProtocolListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $LBProtocolListFinal.Protocols.protocol | Sort-Object Name | ft -AutoSize

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerProtocols cmdlet will pull down a list of all available Rackspace Cloud Load Balancer protocols.

 .DESCRIPTION
 See the synopsis field.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerProtocols
 This example shows how to get a list of all load balancer protocols available for use.
#>
}

function Get-CloudLoadBalancerAlgorithms{

    ## Setting variables needed to execute this function
    Set-Variable -Name ALGORITHMURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/algorithms.xml"

    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    [xml]$LBAlgorithmListStep0 = (Invoke-RestMethod -Uri $ALGORITHMURI  -Headers $HeaderDictionary)
    [xml]$LBAlgorithmListFinal = ($LBAlgorithmListStep0.innerxml)

        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $LBAlgorithmListFinal.algorithms.algorithm | Sort-Object Name | ft -AutoSize

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerAlgorithms cmdlet will pull down a list of all available Rackspace Cloud Load Balancer algorithms.

 .DESCRIPTION
 See the synopsis field.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerAlgorithms
 This example shows how to get a list of all load balancer algorithms available for use.
#>
}

function Add-CloudLoadBalancer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBName,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudLBPort,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$CloudLBProtocol,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$CloudLBAlgorithm,
        [Parameter(Position=4,Mandatory=$true)]
        [string]$CloudLBNodeIP,
        [Parameter(Position=5,Mandatory=$true)]
        [string]$CloudLBNodePort,
        [Parameter(Position=6,Mandatory=$true)]
        [string]$CloudLBNodeCondition,
        [Parameter(Position=7,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNewLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"
        Set-Variable -Name ORDNewLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"

        Get-AuthToken

[xml]$NewCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
	name="'+$CloudLBName+'" 
	port="'+$CloudLBPort+'"
	protocol="'+$CloudLBProtocol.ToUpper()+'"
    algorithm="'+$CloudLBAlgorithm.ToUpper()+'">
	<virtualIps>
		<virtualIp type="PUBLIC"/>
	</virtualIps>
	<nodes>
		<node address="'+$CloudLBNodeIP+'" port="'+$CloudLBNodePort+'" condition="'+$CloudLBNodeCondition.ToUpper()+'"/>
	</nodes>
</loadBalancer>'
 
 if ($Region -eq "DFW") {
        
        $NewCloudLB = Invoke-RestMethod -Uri $DFWNewLBURI -Headers $HeaderDictionary -Body $NewCloudLBXMLBody -ContentType application/xml -Method Post
        [xml]$NewCloudLBInfo = $NewCloudLB.innerxml

        Write-Host "The following is the information for your new CLB. A refreshed CLB list will appear in 10 seconds."

        $lbip0 = $NewCloudLB.loadBalancer.virtualIps.virtualIp
        $nodeip0 = $NewCloudLB.loadBalancer.nodes.node
        
        $lbipfinal = ForEach ($ip in $lbip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

        $nodeipfinal = ForEach ($ip in $nodeip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

        $LBDetailOut = @{"CLB Name"=($NewCloudLB.loadbalancer.name);"CLB ID"=($NewCloudLB.loadbalancer.id);"CLB Algorithm"=($NewCloudLB.loadbalancer.algorithm);"CLB Protocol"=($NewCloudLB.loadbalancer.protocol);"CLB Port"=($NewCloudLB.loadbalancer.port);"CLB Status"=($NewCloudLB.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($NewCloudLB.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($NewCloudLB.loadbalancer.created.time);"CLB Updated"=($NewCloudLB.loadbalancer.updated.time);"- CLB Node ID(s)"=($NewCloudLB.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($NewCloudLB.loadbalancer.nodes.node.port);"- CLB Node Condition"=($NewCloudLB.loadbalancer.nodes.node.condition);"- CLB Node Status"=($NewCloudLB.loadbalancer.nodes.node.status)}

        $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

        Sleep 10

        Get-CloudLoadBalancers DFW
                                   }

elseif ($Region -eq "ORD") {

        $NewCloudLB = Invoke-RestMethod -Uri $ORDNewLBURI -Headers $HeaderDictionary -Body $NewCloudLBXMLBody -ContentType application/xml -Method Post
        [xml]$NewCloudLBInfo = $NewCloudLB.innerxml

        Write-Host "The following is the information for your new CLB. A refreshed CLB list will appear in 10 seconds."

        $lbip0 = $NewCloudLBInfo.loadBalancer.virtualIps.virtualIp
        $nodeip0 = $NewCloudLBInfo.loadBalancer.nodes.node
        
        $lbipfinal = ForEach ($ip in $lbip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

        $nodeipfinal = ForEach ($ip in $nodeip0)
	    {
        New-Object psobject -Property @{
            IP = $ip.address
	    }}

        $LBDetailOut = @{"CLB Name"=($NewCloudLB.loadbalancer.name);"CLB ID"=($NewCloudLB.loadbalancer.id);"CLB Algorithm"=($NewCloudLB.loadbalancer.algorithm);"CLB Protocol"=($NewCloudLB.loadbalancer.protocol);"CLB Port"=($NewCloudLB.loadbalancer.port);"CLB Status"=($NewCloudLB.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($NewCloudLB.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($NewCloudLB.loadbalancer.created.time);"CLB Updated"=($NewCloudLB.loadbalancer.updated.time);"- CLB Node ID(s)"=($NewCloudLB.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($NewCloudLB.loadbalancer.nodes.node.port);"- CLB Node Condition"=($NewCloudLB.loadbalancer.nodes.node.condition);"- CLB Node Status"=($NewCloudLB.loadbalancer.nodes.node.status)}

        $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

        Sleep 10

        Get-CloudLoadBalancers ORD
                                   }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-CloudLoadBalancer cmdlet will create a new Rackspace cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBName
 Use this parameter to define the name of the load balancer you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER CloudLBPort
 Use this parameter to define the TCP/UDP port number of the load balancer you are creating.

.PARAMETER CloudLBProtocol
 Use this parameter to define the protocol that will bind to this load balancer.  If you are unsure, you can get a list of supported protocols and ports by running the "Get-LoadBalancerProtocols" cmdlet.

 .PARAMETER CloudLBAlgorithm
 Use this parameter to define the load balancing algorithm you'd like to use with your new load balancer.  If you are unsure, you can get a list of supported algorithms by running the "Get-LoadBalancerAlgorithms" cmdlet.

 .PARAMETER CloudLBNodeIP
 Use this parameter to define the private IP address of the first node you wish to have served by this load balancer. This must be a functional and legitimate IP, or this command will fail run properly.

 .PARAMETER CloudLBNodePort
 Use this parameter to define the port number of the first node you wish to have served by this load balancer.

 .PARAMETER CloudLBNodeCondition
 Use this parameter to define the condition of the first node you wish to have served by this load balancer. Accepted values in this field are:

 "ENABLED"  - Node is permitted to accept new connections
 "DISABLED" - Node is nor permitted to accept any new connections. Existing connections are forcibly terminated.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancer -CloudLBName TestLB -CloudLBPort 80 -CloudLBProtocol HTTP -CloudLBAlgorithm RANDOM -CloudLBNodeIP 10.1.1.10 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED  -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.
#>
}

function Get-CloudLoadBalancerNodes{

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    [xml]$NodeListStep0 = (Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary)
    [xml]$NodeListFinal = ($NodeListStep0.innerxml)

    ## Handling empty response bodies indicating that no load balancers exist in the queried data center
    if ($NodeListFinal.nodes.node -eq $null) {

        Write-Host "You do not currently have any nodes provisioned to this Cloud Load Balancer."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        $NodeListFinal.nodes.node

    }

}

elseif ($Region -eq "ORD") {  
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    [xml]$NodeListStep0 = (Invoke-RestMethod -Uri $ORDLBURI  -Headers $HeaderDictionary)
    [xml]$NodeListFinal = ($NodeListStep0.innerxml)

    ## Handling empty response bodies indicating that no load balancers exist in the queried data center
    if ($NodeListFinal.nodes.node -eq $null) {

        Write-Host "You do not currently have any nodes provisioned to this Cloud Load Balancer."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        $NodeListFinal.nodes.node

    }
 }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerNodes cmdlet will pull down a list of all nodes that are currently provisioned behind the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodes -CloudLBID 12345 -Region DFW
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodes 12345 ORD
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the ORD region, without using the parameter names.
#>
}

function Add-CloudLoadBalancerNode {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudLBNodeIP,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$CloudLBNodePort,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$CloudLBNodeCondition,
        [Parameter(Position=4,Mandatory=$true)]
        [string]$CloudLBNodeType,
        [Parameter(Position=5,Mandatory=$false)]
        [string]$CloudLBNodeWeight,
        [Parameter(Position=6,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNewNodeURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes.xml"
        Set-Variable -Name ORDNewNodeURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes.xml"

        Get-AuthToken
	
		if (!$CloudLBNodeWeight) {
		
		[xml]$NewCloudLBNodeXMLBody = '<nodes xmlns="http://docs.openstack.org/loadbalancers/api/v1.0">
		<node address="'+$CloudLBNodeIP+'" port="'+$CloudLBNodePort+'" condition="'+$CloudLBNodeCondition.ToUpper()+'" type="'+$CloudLBNodeType.ToUpper()+'"/>
		</nodes>'}
	 
	 	elseif ($CloudLBNodeWeight) {
	 	
	 	[xml]$NewCloudLBNodeXMLBody = '<nodes xmlns="http://docs.openstack.org/loadbalancers/api/v1.0">
		<node address="'+$CloudLBNodeIP+'" port="'+$CloudLBNodePort+'" condition="'+$CloudLBNodeCondition+'" type="'+$CloudLBNodeType+'" weight="'+$CloudLBNodeWeight+'"/>
		</nodes>'}
 
 if ($Region -eq "DFW") {
        
        $NewCloudLBNode = Invoke-RestMethod -Uri $DFWNewNodeURI -Headers $HeaderDictionary -Body $NewCloudLBNodeXMLBody -ContentType application/xml -Method Post
        [xml]$NewCloudLBNodeInfo = $NewCloudLBNode.innerxml
	
    Write-Host "The node has been added as follows:"

	$NewCloudLBNodeInfo.nodes.node
	}

elseif ($Region -eq "ORD") {

        $NewCloudLBNode = Invoke-RestMethod -Uri $ORDNewNodeURI -Headers $HeaderDictionary -Body $NewCloudLBNodeXMLBody -ContentType application/xml -Method Post
        [xml]$NewCloudLBNodeInfo = $NewCloudLBNode.innerxml
	
	    Write-Host "The node has been added as follows:"

        $NewCloudLBNodeInfo.nodes.node
	}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-CloudLoadBalancerNode cmdlet will add a new node to a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the name of the load balancer you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER CloudLBNodeIP
 Use this parameter to define the private IP address of the first node you wish to have served by this load balancer. This MUST be a functional and legitimate IP, or this command will fail run properly.

 .PARAMETER CloudLBNodePort
 Use this parameter to define the port number of the first node you wish to have served by this load balancer.

 .PARAMETER CloudLBNodeCondition
 Use this parameter to define the condition of the first node you wish to have served by this load balancer. Accepted values in this field are:

 "ENABLED"  - Node is permitted to accept new connections
 "DISABLED" - Node is not permitted to accept any new connections. Existing connections are forcibly terminated.

 .Parameter CloudLBNodeType
 Use this parameter to define the type of node you are adding to the load balancer.  Allowable node types are:
 
 "PRIMARY"   â€“ Nodes defined as PRIMARY are in the normal rotation to receive traffic from the load balancer.
 "SECONDARY" â€“ Nodes defined as SECONDARY are only in the rotation to receive traffic from the load balancer when all the primary nodes fail.
 
 .Parameter CloudLBNodeWeight
 Use this parameter to definte the weight of the node you are adding to the load balancer.  This parameter is only required if you are adding a node to a load balancer that is utilizing a weighted load balancing algorithm.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancer -CloudLBName TestLB -CloudLBPort 80 -CloudLBProtocol HTTP -CloudLBAlgorithm RANDOM -CloudLBNodeIP 10.1.1.10 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED  -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.
#>
}

function Remove-CloudLoadBalancerNode {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudLBNodeID,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNodeURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes/$CloudLBNodeID.xml"
        Set-Variable -Name ORDNodeURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes/$CloudLBNodeID.xml"

        Get-AuthToken

     if ($Region -eq "DFW") {
        
        $DelCloudLBNode = Invoke-RestMethod -Uri $DFWNodeURI -Headers $HeaderDictionary -Method Delete
	
    Write-Host "The node has been deleted."
	}

elseif ($Region -eq "ORD") {

        $DelCloudLBNode = Invoke-RestMethod -Uri $ORDNodeURI -Headers $HeaderDictionary -Method Delete
	
    Write-Host "The node has been deleted."
	}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerNode cmdlet will remove a node from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the name of the load balancer you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER CloudLBNodeID
 Use this parameter to define the ID of the node you wish to remove from the load balancer configuration.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerNode -CloudLBID 123456 -CloudLBNodeID 5 -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.
#>
}

function Remove-CloudLoadBalancer {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNodeURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"
        Set-Variable -Name ORDNodeURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"

        Get-AuthToken

     if ($Region -eq "DFW") {
        
        $DelCloudLBNode = Invoke-RestMethod -Uri $DFWNodeURI -Headers $HeaderDictionary -Method Delete
	
    Write-Host "The load balancer has been deleted."
	}

elseif ($Region -eq "ORD") {

        $DelCloudLBNode = Invoke-RestMethod -Uri $ORDNodeURI -Headers $HeaderDictionary -Method Delete
	
    Write-Host "The load balancer has been deleted."
	}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancer cmdlet will remove a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the name of the load balancer you are about to remove.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancer -CloudLBID 123456 -Region DFW
 This example shows how to remove a load balancer with an ID of 12345 in the DFW region.
#>
}

<#  THIS CODE IS NOT READY YET
function Update-CloudLoadBalancer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$false)]
        [string]$CloudLBName,
        [Parameter(Position=2,Mandatory=$false)]
        [string]$CloudLBPort,
        [Parameter(Position=3,Mandatory=$false)]
        [string]$CloudLBProtocol,
        [Parameter(Position=4,Mandatory=$false)]
        [string]$CloudLBAlgorithm,
        [Parameter(Position=5,Mandatory=$false)]
        [string]$CloudLBTimeout,
        [Parameter(Position=6,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"
        Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"

        Get-AuthToken

        if ($CloudLBName) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            name="'+$CloudLBName+'"/>'
        }

        elseif ($CloudLBPort) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            port="'+$CloudLBPort+'"/>'
        }

        elseif ($CloudLBProtocol) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            protocol="'+$CloudLBProtocol+'"/>'
        }

        elseif ($CloudLBAlgorithm) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            algorithm="'+$CloudLBAlgorithm+'"/>'
        }

        [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            name="'+$CloudLBName+'"
            algorithm="'+$CloudLBAlgorithm+'"
            protocol="'+$CloudLBProtocol+'"
            port="'+$CloudLBPort+'"
            timeout="'+$CloudLBTimeout+'"/>'

 if ($Region -eq "DFW") {
        
        $UpdateCloudLB = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $UpdateCloudLBXMLBody -ContentType application/xml -Method Put

        Write-Host "Your load balancer has been updated. Updated information will be shown in 10 seconds:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID DFW
}

elseif ($Region -eq "ORD") {

        $UpdateCloudLB = Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $UpdateCloudLBXMLBody -ContentType application/xml -Method Put

        Write-Host "Your load balancer has been updated. Updated information will be shown in 10 seconds:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID ORD
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-CloudLoadBalancer cmdlet will create a new Rackspace cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBName
 Use this parameter to define the name of the load balancer you are about to create. Whatever you enter here will be exactly what is displayed as the server name in further API requests and/or the Rackspace Cloud Control Panel.

 .PARAMETER CloudLBPort
 Use this parameter to define the TCP/UDP port number of the load balancer you are creating.

.PARAMETER CloudLBProtocol
 Use this parameter to define the protocol that will bind to this load balancer.  If you are unsure, you can get a list of supported protocols and ports by running the "Get-LoadBalancerProtocols" cmdlet.

 .PARAMETER CloudLBAlgorithm
 Use this parameter to define the load balancing algorithm you'd like to use with your new load balancer.  If you are unsure, you can get a list of supported algorithms by running the "Get-LoadBalancerAlgorithms" cmdlet.

 .PARAMETER CloudLBNodeIP
 Use this parameter to define the private IP address of the first node you wish to have served by this load balancer. This must be a functional and legitimate IP, or this command will fail run properly.
 
 .PARAMETER CloudLBNodePort
 Use this parameter to define the port number of the first node you wish to have served by this load balancer.

 .PARAMETER CloudLBNodeCondition
 Use this parameter to define the condition of the first node you wish to have served by this load balancer. Accepted values in this field are:

 "ENABLED"  - Node is permitted to accept new connections
 "DISABLED" - Node is nor permitted to accept any new connections. Existing connections are forcibly terminated.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancer -CloudLBName TestLB -CloudLBPort 80 -CloudLBProtocol HTTP -CloudLBAlgorithm RANDOM -CloudLBNodeIP 10.1.1.10 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED  -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.
}
#>
