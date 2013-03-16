## Info ##
## Author: Mitch Robins (mitch.robins) ##
## Description: PSv3 module for NextGen Rackspace Cloud API interaction ##
## Version 1.2 ##
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
        [string] $CloudServerRegion
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWImageURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/images/detail.xml"
    Set-Variable -Name ORDImageURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/images/detail.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($CloudServerRegion -eq "DFW"){
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Making the call to the API for a list of available server images and storing data into a variable
    [xml]$ServerImageListDFWStep0 = (Invoke-RestMethod -Uri $DFWImageURI  -Headers $HeaderDictionary)
    [xml]$ServerImageListDFWFinal = ($ServerImageListDFWStep0.innerxml)

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $ServerImageListDFWFinal.Images.Image | Sort-Object Name | ft $ImageListTable -AutoSize
    }

## See first "if" block for notes on each line##
elseif ($CloudServerRegion -eq "ORD"){

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
 PS C:\Users\Administrator> Get-CloudServerImages -CloudServerRegion DFW
 This example shows how to get a list of all available images in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages ORD
 This example shows how to get a list of all available images in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.
#>
}

function Get-CloudServers{

    Param(
        [Parameter (Position=0, Mandatory=$false)]
        [string] $CloudServerRegion
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWServerURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/detail.xml"
    Set-Variable -Name ORDServerURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/detail.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($CloudServerRegion -eq "DFW") {    
    
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

elseif ($CloudServerRegion -eq "ORD") {  
    
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
 PS C:\Users\Administrator> Get-CloudServers -CloudServerRegion DFW
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
        [string]$CloudServerRegion
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWServerDetailURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID.xml"
        Set-Variable -Name ORDServerDetailURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID.xml"

if ($Bandwidth) {

    if ($CloudServerRegion -eq "DFW") {

    Get-AuthToken

    [xml]$ServerDetailStep0 = (Invoke-RestMethod -Uri $DFWServerDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$ServerDetailFinal = ($ServerDetailStep0.innerxml)

    $ServerDetailFinal.server.bandwidth.interface | ft $ServerBandwidthTable -AutoSize

    }

    elseif ($CloudServerRegion -eq "ORD") {

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

    if ($CloudServerRegion -eq "DFW") {

    Get-AuthToken

    [xml]$ServerDetailStep0 = (Invoke-RestMethod -Uri $DFWServerDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$ServerDetailFinal = ($ServerDetailStep0.innerxml)
    
    $ServerDetailOut = @{"Server Name"=($ServerDetailFinal.server.name);"Server ID"=($ServerDetailFinal.server.id);"Server Image ID"=($ServerDetailFinal.server.image.id);"Server Flavor ID"=($ServerDetailFinal.server.flavor.id);"Server Last Updated"=($ServerDetailFinal.server.updated)}

    $ServerDetailOut

    }

    elseif ($CloudServerRegion -eq "ORD") {

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
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -CloudServerRegion DFW
 This example shows how to get explicit data about one cloud server from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Bandwidth -CloudServerRegion ORD
 This example shows how to get explicit data about one cloud server from the ORD region, including bandwidth statistics.
#>
}

function Get-CloudServerFlavors() {
    param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $CloudServerRegion
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWFlavorURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/flavors/detail.xml"
    Set-Variable -Name ORDFlavorURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/flavors/detail.xml"

if ($CloudServerRegion -eq "DFW") {

    Get-AuthToken

    [xml]$ServerFlavorListStep0 = (Invoke-RestMethod -Uri $DFWFlavorURI  -Headers $HeaderDictionary)
    [xml]$ServerFlavorListFinal = ($ServerFlavorListStep0.innerxml)
    
    $ServerFlavorListFinal.Flavors.Flavor | Sort-Object id | ft $FlavorListTable -AutoSize
    }

elseif ($CloudServerRegion -eq "ORD") {

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
 PS C:\Users\Administrator> Get-CloudServerFlavors -CloudServerRegion DFW
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
        [Parameter(Position=3,Mandatory=$true)]
        [string]$CloudServerRegion
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNewServerURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers.xml"
        Set-Variable -Name ORDNewServerURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers.xml"

        Get-AuthToken

[xml]$NewCloudServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
            <server xmlns="http://docs.openstack.org/compute/api/v1.1" 
                imageRef="'+$CloudServerImageID+'"
                flavorRef="'+$CloudServerFlavorID+'"
                name="'+$CloudServerName+'">
           </server>'
 
 if ($CloudServerRegion -eq "DFW") {
        
        $NewCloudServer = Invoke-RestMethod -Uri $DFWNewServerURI -Headers $HeaderDictionary -Body $NewCloudServerXMLBody -ContentType application/xml -Method Post
        $NewCloudServerInfo = $NewCloudServer.innerxml

        Write-Host "The following is the ID and password of your new server. Please wait 10 seconds for a refreshed Cloud Server list."

        $NewCloudServer.Server | ft $newservertable

        Sleep 10

        Get-CloudServers DFW
                                   }

elseif ($CloudServerRegion -eq "ORD") {

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

 .PARAMETER CloudServerRegion
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer -CloudServerName NewlyCreatedTestServer -CloudServerFlavorID 3 -CloudServerImageID 26fec9f2-2fb5-4e5e-a19f-0d12540ec639 -CloudServerRegion DFW
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
        [string]$CloudServerRegion
        )
    
    ## Setting variables needed to execute this function
    $NewImageXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<createImage
    xmlns="http://docs.openstack.org/compute/api/v1.1"
    name="'+$NewImageName+'">
</createImage>'

if ($CloudServerRegion -eq "DFW") {

    Get-AuthToken
    
    Set-Variable -Name ServerImageURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerImageURI -Headers $HeaderDictionary -Body $NewImageXMLBody -ContentType application/xml -Method Post

    Write-Host "Your new Rackspace Cloud Server image is being created."

    }

elseif ($CloudServerRegion -eq "ORD") {

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
 PS C:\Users\Administrator> Add-CloudServerImage  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -NewImageName SnapshotCopy1 -CloudServerRegion DFW
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
        [string]$CloudServerRegion,
        [Parameter(Mandatory=$true)]
        [string]$NewNameOrAddressOrPasswordValue
        )

if ($CloudServerRegion -eq "DFW") {

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

    Get-CloudServers $CloudServerRegion
                
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

    Get-CloudServers $CloudServerRegion
                    
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

    Get-CloudServers $CloudServerRegion
                    
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

elseif ($CloudServerRegion -eq "ORD") {

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

    Get-CloudServers $CloudServerRegion
                
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

    Get-CloudServers $CloudServerRegion
                    
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

    Get-CloudServers $CloudServerRegion
                    
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
        [string]$CloudServerRegion,
        [Parameter(Position=2,Mandatory=$False)]
        [switch]$Hard
        )

## Setting variables needed to execute this function
$RestartServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<reboot
    xmlns="http://docs.openstack.org/compute/api/v1.1"
    type="SOFT"/>'

if ($CloudServerRegion -eq "DFW") {

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

elseif ($CloudServerRegion -eq "ORD") {

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
        [string]$CloudServerRegion,
        [Parameter(Mandatory=$False)]
        [int]$CloudServerFlavorID
        )

if ($CloudServerRegion -eq "DFW") {    
    
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

elseif ($CloudServerRegion -eq "ORD") {    
    
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

}

function Remove-CloudServer { 

    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$True)]
        [string]$CloudServerRegion
        )

if ($CloudServerRegion -eq "DFW") {

    Get-AuthToken
    
    ## Setting variables needed to execute this function
    Set-Variable -Name ServerDeleteURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"
    
    Invoke-RestMethod -Uri $ServerDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your server has been scheduled for deletion. This action will take up to a minute to complete."

    }

elseif ($CloudServerRegion -eq "ORD") {

    Get-AuthToken
    
    ## Setting variables needed to execute this function
    Set-Variable -Name ServerDeleteURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"
    
    Invoke-RestMethod -Uri $ServerDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your server has been scheduled for deletion. This action will take up to a minute to complete."

    }

}

function Remove-CloudServerImage {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerImageID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudServerRegion
        )


if ($CloudServerRegion -eq "DFW") {
    
    Get-AuthToken
    
    ## Setting variables needed to execute this function
    Set-Variable -Name DFWImageDeleteURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/images/$CloudServerImageID"

    Invoke-RestMethod -Uri $DFWImageDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your Rackspace Cloud Server Image has been deleted."

    }

elseif ($CloudServerRegion -eq "ORD") {
    
    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name ordImageDeleteURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/images/$CloudServerImageID"

    Invoke-RestMethod -Uri $ORDImageDeleteURI -Headers $HeaderDictionary -Method Delete

    Write-Host "Your Rackspace Cloud Server Image has been deleted."

    }

else {
    Send-RegionError
    }
}

function Set-CloudServerRescueMode {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudServerRegion
        )
    
    ## Setting variables needed to execute this function
    [xml]$RescueModeXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
    <rescue xmlns="http://docs.openstack.org/compute/ext/rescue/api/v1.1" />'


if ($CloudServerRegion -eq "DFW") {

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

elseif ($CloudServerRegion -eq "ORD") {

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
        [string]$CloudServerRegion
        )
    
    ## Setting variables needed to execute this function
    [xml]$RescueModeXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
<unrescue xmlns="http://docs.rackspacecloud.com/servers/api/v1.1" />'

## Using conditional logic to route requests to the relevant API per data center
if ($CloudServerRegion -eq "DFW") {
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name RescueModeDFWURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    $RescueMode = Invoke-RestMethod -Uri $RescueModeDFWURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post

    Write-Host "Your server is being restored to normal service.  Please wait for the status of the server to show ACTIVE before carrying out any further commands against it."

}

elseif ($CloudServerRegion -eq "ORD") {

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


## Cloud Load Balancer API Cmdlets

function Get-CloudLoadBalancers{

    Param(
        [Parameter (Position=0, Mandatory=$false)]
        [string] $CloudLBRegion
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($CloudLBRegion -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available servers and storing data into a variable
    [xml]$LBListStep0 = (Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary)
    [xml]$LBListFinal = ($LBListStep0.innerxml)

    ## Handling empty response bodies indicating that no servers exist in the queried data center
    if ($LBListFinal.loadBalancers.loadBalancer -eq $null) {

        Write-Host "You do not currently have any Cloud Load Balancers provisioned in the DFW region."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $LBListFinal.loadBalancers.loadBalancer | Sort-Object Name | ft $LBListTable -AutoSize

    }

}

elseif ($CloudLBRegion -eq "ORD") {  
    
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
}

function Get-CloudLoadBalancerDetails {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLoadBalancerID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudLoadBalancerRegion
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWLBDetailURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLoadBalancerID.xml"
        Set-Variable -Name ORDLBDetailURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLoadBalancerID.xml"

    if ($CloudLoadBalancerRegion -eq "DFW") {

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

    $LBDetailOut = @{"CLB Name"=($LBDetailFinal.loadbalancer.name);"CLB ID"=($LBDetailFinal.loadbalancer.id);"CLB Algorithm"=($LBDetailFinal.loadbalancer.algorithm);"CLB Protocol"=($LBDetailFinal.loadbalancer.protocol);"CLB Port"=($LBDetailFinal.loadbalancer.port);"CLB Status"=($LBDetailFinal.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($LBDetailFinal.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($LBDetailFinal.loadbalancer.created.time);"CLB Updated"=($LBDetailFinal.loadbalancer.updated.time);"- CLB Node IDs"=($LBDetailFinal.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($LBDetailFinal.loadbalancer.nodes.node.port);"- CLB Node Condition"=($LBDetailFinal.loadbalancer.nodes.node.condition);"- CLB Node Status"=($LBDetailFinal.loadbalancer.nodes.node.status)}

    $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

    }

    elseif ($CloudLoadBalancerRegion -eq "ORD") {

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

    $LBDetailOut = @{"CLB Name"=($LBDetailFinal.loadbalancer.name);"CLB ID"=($LBDetailFinal.loadbalancer.id);"CLB Algorithm"=($LBDetailFinal.loadbalancer.algorithm);"CLB Protocol"=($LBDetailFinal.loadbalancer.protocol);"CLB Port"=($LBDetailFinal.loadbalancer.port);"CLB Status"=($LBDetailFinal.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($LBDetailFinal.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($LBDetailFinal.loadbalancer.created.time);"CLB Updated"=($LBDetailFinal.loadbalancer.updated.time);"- CLB Node IDs"=($LBDetailFinal.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($LBDetailFinal.loadbalancer.nodes.node.port);"- CLB Node Condition"=($LBDetailFinal.loadbalancer.nodes.node.condition);"- CLB Node Status"=($LBDetailFinal.loadbalancer.nodes.node.status)}

    $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

    }

    else {

    Send-RegionError

    }

}

function Add-CloudLoadBalancer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLoadBalancerName,
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
        [string]$CloudLBRegion
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWNewLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"
        Set-Variable -Name ORDNewLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers.xml"

        Get-AuthToken

[xml]$NewCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
	name="'+$CloudLoadBalancerName+'" 
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
 
 if ($CloudLBRegion -eq "DFW") {
        
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

elseif ($CloudServerRegion -eq "ORD") {

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

        Get-CloudServers ORD
                                   }

else {

    Send-RegionError
    }

}