## Info ##
## Author: Mitch Robins (mitch.robins) ##
## Description: PSv3 module for NextGen Rackspace Cloud API interaction (PowerClient)##
## Version 1.9.1 ##
## Contact Info: 210-312-5868 / mitch.robins@rackspace.com ##

## Define Global Variables Needed for API Comms ##

Set-Variable -Name CloudUsername -Value "" -Scope Global
Set-Variable -Name CloudAPIKey -Value "" -Scope Global
Set-Variable -Name CloudDDI -Value "" -Scope Global
## THIS VARIABLE WILL NOT BE USED IN V2 - Set-Variable -Name GlobalServerRegion -Value "ORD" -Scope Global

## Allow unlimited enumeration
$FormatEnumerationLimit = -1

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

$NodeServiceEventTable = @{Expression={$_.NodeId};Label="Node ID";width=7},
@{Expression={$_.detailedMessage};Label="Node Msg";width=40},
@{Expression={$_.loadbalancerId};Label="CLB ID";width=7},
@{Expression={$_.title};Label="Msg Title";width=40},
@{Expression={$_.description};Label="Msg Description";width=250},
@{Expression={$_.type};Label="Msg Type";width=25},
@{Expression={$_.severity};Label="Msg Severity";width=10},
@{Expression={$_.created};Label="Msg Created";width=40}

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

$ServerAttachmentsTable = @{Expression={$_.id};Label="Attachment ID";width=35},
@{Expression={$_.volumeid};Label="Attached Volume ID";width=35},
@{Expression={$_.device};Label="Attached Device Type";width=15}

$NewServerTable = @{Expression={$_.id};Label="Server ID";width=38}, 
@{Expression={$_.adminpass};Label="Server Password";width=40}

$RegionListTable = @{Expression={$_.region};Label="Region";width=10}, 
@{Expression={$_.publicURL};Label="Region URL";width=40}

$ServerBandwidthTable = @{Expression={$_.interface};Label="Interface";width=38}, 
@{Expression={$_.bandwidth_outbound};Label="Outbound Bandwidth";width=40},
@{Expression={$_.bandwidth_inbound};Label="Inbound Bandwidth";width=40},
@{Expression={$_.audit_period_start};Label="Start Date";width=40},
@{Expression={$_.audit_period_end};Label="End Date";width=40}

$HealthMonitorConnectTable = @{Expression={$_.delay};label="Monitor Delay"},
@{Expression={$_.timeout};label="Monitor Timeout"},
@{Expression={$_.attemptsbeforedeactivation};label="Monitor Failure Attempts"},
@{Expression={$_.type};label="Monitor Type"}

$HealthMonitorHTTPTable = @{Expression={$_.delay};label="Monitor Delay"},
@{Expression={$_.timeout};label="Monitor Timeout"},
@{Expression={$_.attemptsbeforedeactivation};label="Monitor Failure Attempts"},
@{Expression={$_.type};label="Monitor Type"},
@{Expression={$_.path};label="Monitor HTTP(S) Path"},
@{Expression={$_.statusregex};label="Monitor Status RegEx"},
@{Expression={$_.bodyregex};label="Monitor Body RegEx"},
@{Expression={$_.hostheader};label="Monitor Host Header"}

$EndPointTable = @{Expression={$service.name};Label="Name"},
@{Expression={$service.endpoint.region};Label="Region"},
@{Expression={$service.endpoint.publicURL};Label="URL"}

$ACLTable = @{Expression={$_.id};Label="ID"},
@{Expression={$_.address};Label="IP Address/Range"},
@{Expression={$_.type};Label="Action"}

$SSLTable = @{Expression={$_.enabled};Label="SSL Enabled";width=12},
@{Expression={$_.securePort};Label="SSL Port";width=10},
@{Expression={$_.secureTrafficOnly};Label="SSL Only";width=10},
@{Expression={$_.privateKey};Label="Private Key";width=40},
@{Expression={$_.certificate};Label="Certificate(s)";width=40},
@{Expression={$_.intermediateCertificate};Label="Intermediate Certificate(s)";width=50}

<#
## Define Optional Aliases for easier cmdlet execution
## To enable, remove the <# from 2 lines above this, and remove its inverse at the end of this block
Set-Alias -Name gcs -Value Get-CloudServers
Set-Alias -Name gcsi -Value Get-CloudServerImages
Set-Alias -Name gcsf -Value Get-CloudServerFlavors
Set-Alias -Name gcsd -Value Get-CloudServerDetails
Set-Alias -Name acs -Value Add-CloudServer
Set-Alias -Name acsi -Value Add-CloudServerImage
Set-Alias -Name ucs -Value Update-CloudServer
Set-Alias -Name rcs -Value Resize-CloudServer
Set-Alias -Name rmcs -Value Remove-CloudServer
Set-Alias -Name rmcsi -Value Remove-CloudServerImage

Set-Alias -Name gcbsvols -Value Get-CloudBlockStorageVolList
Set-Alias -Name gcbssnaps -Value Get-CloudBlockStorageSnapList
Set-Alias -Name gcbstypes -Value Get-CloudBlockStorageTypes
Set-Alias -Name gcbssnap -Value Get-CloudBlockStorageSnap
Set-Alias -Name gcbsvol -Value Get-CloudBlockStorageVol
Set-Alias -Name acbssnap -Value Add-CloudBlockStorageSnap
Set-Alias -Name acbsvol -Value Add-CloudBlockStorageVol
Set-Alias -Name rmcbssnap -Value Remove-CloudBlockStorageSnap
Set-Alias -Name rmcbsvol -Value Remove-CloudBlockStorageVol


Set-Alias -Name gcn -Value Get-CloudNetworks
Set-Alias -Name acn -Value Add-CloudNetwork
Set-Alias -Name rcn -Value Remove-CloudNetwork

Set-Alias -Name gclb -Value Get-CloudLoadBalancers
Set-Alias -Name gclbd -Value Get-CloudLoadBalancerDetails
Set-Alias -Name gclbnl -Value Get-CloudLoadBalancerNodeList
Set-Alias -Name gclbpro -Value Get-CloudLoadBalancerProtocols
Set-Alias -Name gclba -Value Get-CloudLoadBalancerAlgorithms
Set-Alias -Name gclbne -Value Get-CloudLoadBalancerNodeEvents
Set-Alias -Name aclb -Value Add-CloudLoadBalancer
Set-Alias -Name aclbn -Value Add-CloudLoadBalancerNode
Set-Alias -Name aclbsp -Value Add-SessionPersistence
Set-Alias -Name aclbcl -Value Add-ConnectionLogging
Set-Alias -Name aclbct -Value Add-ConnectionThrottling
Set-Alias -Name uclb -Value Update-CloudLoadBalancer
Set-Alias -Name uclbn -Value Update-CloudLoadBalancerNode
Set-Alias -Name uclbsp -Value Update-SessionPersistence
Set-Alias -Name uclbsp -Value Update-ConnectionThrottling
Set-Alias -Name rclb -Value Remove-CloudLoadBalancer
Set-Alias -Name rclbn -Value Remove-CloudLoadBalancerNode
Set-Alias -Name rclbsp -Value Remove-SessionPersistence
Set-Alias -Name rclbcl -Value Remove-ConnectionLogging
Set-Alias -Name rclbct -Value Remove-ConnectionThrottling
#>

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

function Get-CloudServerAttachments {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudServerID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWServerURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments.xml"
    Set-Variable -Name ORDServerURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments.xml"

 if ($Region -eq "DFW") {
        
        [xml]$CloudServerAttachmentsStep0 = Invoke-RestMethod -Uri $DFWServerURI -Headers $HeaderDictionary -Method Get
        [xml]$CloudServerAttachmentsFinal = $CloudServerAttachmentsStep0.InnerXml

            if (!$CloudServerAttachmentsFinal.volumeAttachments) {
                Write-Host "This cloud server has no cloud block storage volumes attached." -ForegroundColor Red
            }

            else {
                $CloudServerAttachmentsFinal.volumeAttachments.volumeAttachment | ft $ServerAttachmentsTable -AutoSize
            }
    }

elseif ($Region -eq "ORD") {
        
        [xml]$CloudServerAttachmentsStep0 = Invoke-RestMethod -Uri $ORDServerURI -Headers $HeaderDictionary -Method Get
        [xml]$CloudServerAttachmentsFinal = $CloudServerAttachmentsStep0.InnerXml

            if (!$CloudServerAttachmentsFinal.volumeAttachments) {
                    Write-Host "This cloud server has no cloud block storage volumes attached." -ForegroundColor Red
                }

            elseif ($CloudServerAttachmentsFinal) {
                $CloudServerAttachmentsFinal.volumeAttachments.volumeAttachment | ft $ServerAttachmentsTable -AutoSize
                }
    }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudServerAttachments cmdlet will retrieve a list of all cloud block storage volume attachments to a cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server to which you wish to view storage attachments. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerAttachments -CloudServerID e6ce2ee7-5d9a-4ef4-a78c-fe12f873f46c -Region ord
 This example shows how to retrieve a list of all attached cloud block storage volumes of the specified cloud server in the ORD region.
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
        
        $NewCloudServer = Invoke-RestMethod -Uri $DFWNewServerURI -Headers $HeaderDictionary -Body $NewCloudServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
        $NewCloudServerInfo = $NewCloudServer.innerxml

        Write-Host "The following is the ID and password of your new server. Please wait 10 seconds for a refreshed Cloud Server list."

        $NewCloudServer.Server | ft $newservertable

        Sleep 10

        Get-CloudServers DFW
                                   }

elseif ($Region -eq "ORD") {
        
        $NewCloudServer = Invoke-RestMethod -Uri $ORDNewServerURI -Headers $HeaderDictionary -Body $NewCloudServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
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

    Invoke-RestMethod -Uri $ServerImageURI -Headers $HeaderDictionary -Body $NewImageXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

    Write-Host "Your new Rackspace Cloud Server image is being created."

    }

elseif ($Region -eq "ORD") {

    Get-AuthToken
    
    Set-Variable -Name ServerImageURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerImageURI -Headers $HeaderDictionary -Body $NewImageXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

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

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
                
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

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null

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

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null

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

    Invoke-RestMethod -Uri $ServerPasswordUpdateURI -Headers $HeaderDictionary -Body $UpdateAdminPasswordXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

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

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
                
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

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null

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

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null

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

    Invoke-RestMethod -Uri $ServerPasswordUpdateURI -Headers $HeaderDictionary -Body $UpdateAdminPasswordXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

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

    Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

    Write-Host "Your Cloud Server will be soft rebooted based on your input."

    

        if ($hard) {
        $RestartServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <reboot
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        type="HARD"/>'

        Set-Variable -Name ServerRestartURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action" -Scope Global

        Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

        Write-Host "Your Cloud Server will be hard rebooted based on your input."
                }

    }

elseif ($Region -eq "ORD") {

    Get-AuthToken

    Set-Variable -Name ServerRestartURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

    Write-Host "Your Cloud Server will be soft rebooted based on your input."

        if ($hard) {
        $RestartServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
        <reboot
        xmlns="http://docs.openstack.org/compute/api/v1.1"
        type="HARD"/>'

        Set-Variable -Name ServerRestartURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action" -Scope Global

        Invoke-RestMethod -Uri $ServerRestartURI -Headers $HeaderDictionary -Body $RestartServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

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

function Resize-CloudServer {

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

      Invoke-RestMethod -Uri $ServerConfirmURI -Headers $HeaderDictionary -Body $ConfirmServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

      Write-Host "Your resized server has been confirmed."

            }
    
    elseif ($Revert) {
      
      ## Setting variables needed to execute this function
      $ConfirmServerXMLBody = '<?xml version="1.0" encoding="UTF-8"?>
      <revertResize
      xmlns="http://docs.openstack.org/compute/api/v1.1"/>'

      Set-Variable -Name ServerConfirmURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

      Invoke-RestMethod -Uri $ServerConfirmURI -Headers $HeaderDictionary -Body $ConfirmServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

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
 The Resize-CloudServer cmdlet will resize the specified cloud server to a new flavor.  After the original request, you can also use this command to either REVERT your changes, or CONFIRM them.

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
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW -CloudServerFlavorID 3
 This example shows how to resize a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the DFW region, to a new size of 1GB RAM, 1 vCPU, 40GB storage.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Confirm
 This example shows how to confirm the resizing of a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the ORD region.

 .EXAMPLE
 PS C:\Users\Administrator> Resize-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD -Revert
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
    
    Invoke-RestMethod -Uri $ServerDeleteURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

    Write-Host "Your server has been scheduled for deletion. This action will take up to a minute to complete."

    }

elseif ($Region -eq "ORD") {

    Get-AuthToken
    
    ## Setting variables needed to execute this function
    Set-Variable -Name ServerDeleteURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"
    
    Invoke-RestMethod -Uri $ServerDeleteURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

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

    Invoke-RestMethod -Uri $DFWImageDeleteURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

    Write-Host "Your Rackspace Cloud Server Image has been deleted."

    }

elseif ($Region -eq "ORD") {
    
    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name ordImageDeleteURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/images/$CloudServerImageID"

    Invoke-RestMethod -Uri $ORDImageDeleteURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

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

    $RescueMode = Invoke-RestMethod -Uri $RescueModeDFWURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
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

    $RescueMode = Invoke-RestMethod -Uri $RescueModeORDURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
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

    $RescueMode = Invoke-RestMethod -Uri $RescueModeDFWURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

    Write-Host "Your server is being restored to normal service.  Please wait for the status of the server to show ACTIVE before carrying out any further commands against it."

}

elseif ($Region -eq "ORD") {

    Get-AuthToken

    ## Setting variables needed to execute this function
    Set-Variable -Name RescueModeORDURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/action"

    $RescueMode = Invoke-RestMethod -Uri $RescueModeORDURI -Headers $HeaderDictionary -Body $RescueModeXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

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
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Body $NewVolXMLBody -ContentType application/xml -Method Post -ErrorAction Stop)
    [xml]$VolFinal = ($VolStep0.innerxml)

        $VolFinal.volume | ft $VolTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Body $NewVolXMLBody -ContentType application/xml -Method Post -ErrorAction Stop)
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
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop)
    [xml]$VolFinal = ($VolStep0.innerxml)

        Write-Host "The volume has been deleted."
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop)
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
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Body $NewSnapXMLBody -ContentType application/xml -Method Post -ErrorAction Stop)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        $VolSnapFinal.snapshot | ft $VolSnapTable -AutoSize
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Body $NewSnapXMLBody -ContentType application/xml -Method Post -ErrorAction Stop)
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
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $DFWCBSURI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop)
    [xml]$VolSnapFinal = ($VolSnapStep0.innerxml)

        Write-Host "The snapshot has been deleted."
    }

    elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    [xml]$VolSnapStep0 = (Invoke-RestMethod -Uri $ORDCBSURI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop)
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

function Connect-CloudBlockStorageVol {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudServerID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $CloudBlockStorageVolID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWServerURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments.xml"
    Set-Variable -Name ORDServerURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments.xml"

    [xml]$AttachStorage = '<?xml version="1.0" encoding="UTF-8"?>
<volumeAttachment
    xmlns="http://docs.openstack.org/compute/api/v1.1"
    volumeId="'+$CloudBlockStorageVolID+'"
    device="/dev/xvdb"/>'

 if ($Region -eq "DFW") {
        
        Invoke-RestMethod -Uri $DFWServerURI -Headers $HeaderDictionary -Body $AttachStorage -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null

        Write-Host "The cloud block storage volume has been attached.  Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-CloudBlockStorageVol -CloudBlockStorageVolID $CloudBlockStorageVolID -Region $Region
                                   }

elseif ($Region -eq "ORD") {
        
        Invoke-RestMethod -Uri $ORDServerURI -Headers $HeaderDictionary -Body $AttachStorage -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null

        Write-Host "The cloud block storage volume has been attached.  Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-CloudBlockStorageVol -CloudBlockStorageVolID $CloudBlockStorageVolID -Region $Region
                                   }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Connect-CloudBlockStorageVol cmdlet will attach a cloud block storage volume to a cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server to which you wish to attach storage. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> 

#>
}

function Disconnect-CloudBlockStorageVol {

        Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $CloudServerID,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $CloudServerAttachmentID,
        [Parameter (Position=2, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWServerURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments/$CloudServerAttachmentID.xml"
    Set-Variable -Name ORDServerURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments/$CloudServerAttachmentID.xml"

 if ($Region -eq "DFW") {
        
        Invoke-RestMethod -Uri $DFWServerURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

        Write-Host "The cloud block storage volume has been detached.  Please wait 15 seconds for confirmation:"

        Sleep 15

        Get-CloudServerAttachments -CloudServerID $CloudServerID -Region $Region
                                   }

elseif ($Region -eq "ORD") {
        
        Invoke-RestMethod -Uri $ORDServerURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

        Write-Host "The cloud block storage volume has been detached.  Please wait 15 seconds for confirmation:"

        Sleep 15

        Get-CloudServerAttachments -CloudServerID $CloudServerID -Region $Region
                                   }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Disconnect-CloudBlockStorageVol cmdlet will detach a cloud block storage volume from a cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server to which you wish to attach storage. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> 

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
        
        $NewCloudNet = Invoke-RestMethod -Uri $DFWNewNetURI -Headers $HeaderDictionary -Body $NewCloudNetXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
        [xml]$NewCloudNetInfo = $NewCloudNet.innerxml

        Write-Host "You have just created the following cloud network:"

        $NewCloudNetInfo.network

        }

elseif ($Region -eq "ORD") {

        $NewCloudNet = Invoke-RestMethod -Uri $ORDNewNetURI -Headers $HeaderDictionary -Body $NewCloudNetXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
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
        Set-Variable -Name DFWLBCachingURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/contentcaching.xml"
        Set-Variable -Name ORDLBCachingURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/contentcaching.xml"


    if ($Region -eq "DFW") {

    Get-AuthToken

    [xml]$LBDetailStep0 = (Invoke-RestMethod -Uri $DFWLBDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$LBDetailFinal = ($LBDetailStep0.innerxml)

    [xml]$ContentCachingStep0 = Invoke-RestMethod -Uri $DFWLBCachingURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop
    [xml]$ContentCachingFinal = ($ContentCachingStep0.innerxml)

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

        $LBDetailOut = @{"CLB Content Caching"=($ContentCachingFinal.contentCaching.enabled);"CLB Name"=($LBDetailFinal.loadbalancer.name);"CLB ID"=($LBDetailFinal.loadbalancer.id);"CLB Algorithm"=($LBDetailFinal.loadbalancer.algorithm);"CLB Timeout"=($LBDetailFinal.loadbalancer.timeout);"CLB Protocol"=($LBDetailFinal.loadbalancer.protocol);"CLB Port"=($LBDetailFinal.loadbalancer.port);"CLB Status"=($LBDetailFinal.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($LBDetailFinal.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($LBDetailFinal.loadbalancer.created.time);"CLB Updated"=($LBDetailFinal.loadbalancer.updated.time);"- CLB Node IDs"=($LBDetailFinal.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($LBDetailFinal.loadbalancer.nodes.node.port);"- CLB Node Condition"=($LBDetailFinal.loadbalancer.nodes.node.condition);"- CLB Node Status"=($LBDetailFinal.loadbalancer.nodes.node.status);"CLB Logging"=($LBDetailFinal.loadbalancer.connectionlogging.enabled);"CLB Connections (Min)"=($LBDetailFinal.loadbalancer.connectionthrottle.minconnections);"CLB Connections (Max)"=($LBDetailFinal.loadbalancer.connectionthrottle.maxconnections);"CLB Connection Rate (Max)"=($LBDetailFinal.loadbalancer.connectionthrottle.maxconnectionrate);"CLB Connection Rate Interval"=($LBDetailFinal.loadbalancer.connectionthrottle.rateinterval)}

        $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

    }

    elseif ($Region -eq "ORD") {

    Get-AuthToken

    [xml]$LBDetailStep0 = (Invoke-RestMethod -Uri $ORDLBDetailURI  -Headers $HeaderDictionary -Method Get)
    [xml]$LBDetailFinal = ($LBDetailStep0.innerxml)

    [xml]$ContentCachingStep0 = Invoke-RestMethod -Uri $ORDLBCachingURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop
    [xml]$ContentCachingFinal = ($ContentCachingStep0.innerxml)

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

        $LBDetailOut = @{"CLB Content Caching"=($ContentCachingFinal.contentCaching.enabled);"CLB Name"=($LBDetailFinal.loadbalancer.name);"CLB ID"=($LBDetailFinal.loadbalancer.id);"CLB Algorithm"=($LBDetailFinal.loadbalancer.algorithm);"CLB Timeout"=($LBDetailFinal.loadbalancer.timeout);"CLB Protocol"=($LBDetailFinal.loadbalancer.protocol);"CLB Port"=($LBDetailFinal.loadbalancer.port);"CLB Status"=($LBDetailFinal.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($LBDetailFinal.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($LBDetailFinal.loadbalancer.created.time);"CLB Updated"=($LBDetailFinal.loadbalancer.updated.time);"- CLB Node IDs"=($LBDetailFinal.loadbalancer.nodes.node.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($LBDetailFinal.loadbalancer.nodes.node.port);"- CLB Node Condition"=($LBDetailFinal.loadbalancer.nodes.node.condition);"- CLB Node Status"=($LBDetailFinal.loadbalancer.nodes.node.status);"CLB Logging"=($LBDetailFinal.loadbalancer.connectionlogging.enabled);"CLB Connections (Min)"=($LBDetailFinal.loadbalancer.connectionthrottle.minconnections);"CLB Connections (Max)"=($LBDetailFinal.loadbalancer.connectionthrottle.maxconnections);"CLB Connection Rate (Max)"=($LBDetailFinal.loadbalancer.connectionthrottle.maxconnectionrate);"CLB Connection Rate Interval"=($LBDetailFinal.loadbalancer.connectionthrottle.rateinterval)}

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
        
        $NewCloudLB = Invoke-RestMethod -Uri $DFWNewLBURI -Headers $HeaderDictionary -Body $NewCloudLBXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
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

        $NewCloudLB = Invoke-RestMethod -Uri $ORDNewLBURI -Headers $HeaderDictionary -Body $NewCloudLBXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
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

function Get-CloudLoadBalancerNodeList{

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
 The Get-CloudLoadBalancerNodeList cmdlet will pull down a list of all nodes that are currently provisioned behind the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList -CloudLBID 12345 -Region DFW
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList 12345 ORD
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
        
        $NewCloudLBNode = Invoke-RestMethod -Uri $DFWNewNodeURI -Headers $HeaderDictionary -Body $NewCloudLBNodeXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
        [xml]$NewCloudLBNodeInfo = $NewCloudLBNode.innerxml
	
    Write-Host "The node has been added as follows:"

	$NewCloudLBNodeInfo.nodes.node
	}

elseif ($Region -eq "ORD") {

        $NewCloudLBNode = Invoke-RestMethod -Uri $ORDNewNodeURI -Headers $HeaderDictionary -Body $NewCloudLBNodeXMLBody -ContentType application/xml -Method Post -ErrorAction Stop
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
 
 "PRIMARY"   - Nodes defined as PRIMARY are in the normal rotation to receive traffic from the load balancer.
 "SECONDARY" - Nodes defined as SECONDARY are only in the rotation to receive traffic from the load balancer when all the primary nodes fail.
 
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

function Update-CloudLoadBalancer {
    
    Param(
        [Parameter(Mandatory=$false)]
        [switch]$ChangeName,
        [Parameter(Mandatory=$false)]
        [switch]$ChangePort,
        [Parameter(Mandatory=$false)]
        [switch]$ChangeProtocol,
        [Parameter(Mandatory=$false)]
        [switch]$ChangeAlgorithm,
        [Parameter(Mandatory=$false)]
        [switch]$ChangeTimeout,
        [Parameter(Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBName,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBPort,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBProtocol,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBAlgorithm,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBTimeout,
        [Parameter(Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"
        Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID.xml"

        Get-AuthToken

        if ($ChangeName) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            name="'+$CloudLBName+'"/>'
        }

        elseif ($ChangePort) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            port="'+$CloudLBPort+'"/>'
        }

        elseif ($ChangeProtocol) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            protocol="'+$CloudLBProtocol+'"/>'
        }

        elseif ($ChangeAlgorithm) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            algorithm="'+$CloudLBAlgorithm+'"/>'
        }

        elseif ($ChangeTimeout) {
            [xml]$UpdateCloudLBXMLBody = '<loadBalancer xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
            timeout="'+$CloudLBTimeout+'"/>'
        }

 if ($Region -eq "DFW") {
        
        $UpdateCloudLB = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $UpdateCloudLBXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Your load balancer has been updated. Updated information will be shown in 10 seconds:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID DFW
}

elseif ($Region -eq "ORD") {

        $UpdateCloudLB = Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $UpdateCloudLBXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Your load balancer has been updated. Updated information will be shown in 10 seconds:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID ORD
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Update-CloudLoadBalancer cmdlet will update a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER CloudLBName
 Use this parameter to define the name of the specified load balancer.

 .PARAMETER CloudLBPort
 Use this parameter to define the TCP/UDP port number of the specified load balancer.

.PARAMETER CloudLBProtocol
 Use this parameter to define the protocol of the specified load balancer.  If you are unsure, you can get a list of supported protocols and ports by running the "Get-LoadBalancerProtocols" cmdlet.

 .PARAMETER CloudLBAlgorithm
 Use this parameter to define the load balancing algorithm you'd like to use with your load balancer.  If you are unsure, you can get a list of supported algorithms by running the "Get-LoadBalancerAlgorithms" cmdlet.

 .PARAMETER CloudLBTimeout
 Use this parameter to define the timeout value of the specified load balancer.

 .PARAMETER ChangeName
 Use this switch to specify that you are changing the name of the load balancer.

 .PARAMETER ChangePort
 Use this switch to specify that you are changing the port of the load balancer.

 .PARAMETER ChangeProtocol
 Use this switch to specify that you are changing the protocol of the load balancer.

 .PARAMETER ChangeAlgorithm
 Use this switch to specify that you are changing the algorithm of the load balancer.

 .PARAMETER ChangeTimeout
 Use this switch to specify that you are changing the timeout of the load balancer.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancer -CloudLBName TestLB -CloudLBPort 80 -CloudLBProtocol HTTP -CloudLBAlgorithm RANDOM -CloudLBNodeIP 10.1.1.10 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED  -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.
#>
}

function Update-CloudLoadBalancerNode {
    
    Param(
        [Parameter(Mandatory=$false)]
        [switch]$ChangeCondition,
        [Parameter(Mandatory=$false)]
        [switch]$ChangeType,
        [Parameter(Mandatory=$false)]
        [switch]$ChangeWeight,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBID,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBNodeID,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBNodeCondition,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBNodeType,
        [Parameter(Mandatory=$false)]
        [string]$CloudLBNodeWeight,
        [Parameter(Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes/$CloudLBNodeID.xml"
        Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes/$CloudLBNodeID.xml"

        Get-AuthToken

        if ($ChangeCondition) {
            [xml]$UpdateCloudLBXMLBody = '<node xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" condition="'+$CloudLBNodeCondition.ToUpper()+'"/>'
        }

        elseif ($ChangeType) {
            [xml]$UpdateCloudLBXMLBody = '<node xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" type="'+$CloudLBNodeType.ToUpper()+'" />'
        }

        elseif ($ChangeWeight) {
            [xml]$UpdateCloudLBXMLBody = '<node xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" weight="'+$CloudLBNodeWeight+'"/>'
        }

 if ($Region -eq "DFW") {
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $UpdateCloudLBXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Your node has been updated. Updated information will be shown in 10 seconds:"

        Sleep 10

        Get-CloudLoadBalancerNodeList $CloudLBID DFW
}

elseif ($Region -eq "ORD") {

            Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $UpdateCloudLBXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

            Write-Host "Your node has been updated. Updated information will be shown in 10 seconds:"

            Sleep 10

            Get-CloudLoadBalancerNodeList $CloudLBID ORD
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Update-CloudLoadBalancerNode cmdlet will update a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER CloudLBNodeID
 Use this parameter to define the ID of the node you are about to modify.

 .PARAMETER CloudLBNodeCondition
 Use this parameter to define the condition of the specified node. At all times, you must have at least one ENABLED node within a load balancer's configuration. Accepted values in this field are:

 "ENABLED"  - Node is permitted to accept new connections
 "DISABLED" - Node is not permitted to accept any new connections. Existing connections are forcibly terminated.
 "DRAINING" - Node is allowed to service existing established connections and connections that are being directed to it as a result of the session persistence configuration.

 .Parameter CloudLBNodeType
 Use this parameter to define the type of the specified node.  At all times, you must have at least one PRIMARY node within a load balancer's configuration. Allowable node types are:
 
 "PRIMARY"   - Nodes defined as PRIMARY are in the normal rotation to receive traffic from the load balancer.
 "SECONDARY" - Nodes defined as SECONDARY are only in the rotation to receive traffic from the load balancer when all the primary nodes fail.

 .Parameter CloudLBNodeWeight
 Use this parameter to definte the weight of the node you are adding to the load balancer.  This parameter is only required if you are adding a node to a load balancer that is utilizing a weighted load balancing algorithm.

 .PARAMETER CloudLBTimeout
 Use this parameter to define the timeout value of the specified load balancer.

 .PARAMETER ChangeName
 Use this switch to specify that you are changing the name of the load balancer.

 .PARAMETER ChangePort
 Use this switch to specify that you are changing the port of the load balancer.

 .PARAMETER ChangeProtocol
 Use this switch to specify that you are changing the protocol of the load balancer.

 .PARAMETER ChangeAlgorithm
 Use this switch to specify that you are changing the algorithm of the load balancer.

 .PARAMETER ChangeTimeout
 Use this switch to specify that you are changing the timeout of the load balancer.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancer -CloudLBName TestLB -CloudLBPort 80 -CloudLBProtocol HTTP -CloudLBAlgorithm RANDOM -CloudLBNodeIP 10.1.1.10 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED  -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.
#>
}

function Get-CloudLoadBalancerNodeEvents{

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes/events.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/nodes/events.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    [xml]$NodeEventStep0 = Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary
    [xml]$NodeEventFinal = ($NodeEventStep0.innerxml)

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        $NodeEventFinal.NodeServiceEvents.NodeServiceEvent | ft $NodeServiceEventTable -AutoSize

}

elseif ($Region -eq "ORD") {  
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    [xml]$NodeEventStep0 = (Invoke-RestMethod -Uri $ORDLBURI  -Headers $HeaderDictionary)
    [xml]$NodeEventFinal = ($NodeEventStep0.innerxml)
    
    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        $NodeEventFinal.NodeServiceEvents.NodeServiceEvent | ft $NodeServiceEventTable -AutoSize
 }

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerNodeList cmdlet will pull down a list of all nodes that are currently provisioned behind the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList -CloudLBID 12345 -Region DFW
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList 12345 ORD
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the ORD region, without using the parameter names.
#>
}

function Get-CloudLoadBalancerACLs {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist.xml"


 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        [xml]$AccessListStep0 = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop
        [xml]$AccessListFinal = $AccessListStep0.InnerXml

            if (!$AccessListFinal.accessList.networkItem) {

                Write-Host "This load balancer does not currently have any ACLs configured." -ForegroundColor Red

            }

            else {
            
                $AccessListFinal.accessList.networkItem | ft $ACLTable -AutoSize

            }
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
        
        [xml]$AccessListStep0 = Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop
        [xml]$AccessListFinal = $AccessListStep0.InnerXml

        if (!$AccessListFinal.accessList.networkItem) {

                Write-Host "This load balancer does not currently have any ACLs configured." -ForegroundColor Red

            }

            else {
            
                $AccessListFinal.accessList.networkItem | ft $ACLTable -AutoSize

            }

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerACLs cmdlet will retrieve all configured ACL items from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are querying.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerACLs -CloudLBID 51885 -Region DFW
 This example shows how to get all ACL items from the specified load balancer in the DFW region.
#>
}

function Add-CloudLoadBalancerACLItem {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$IP,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$Action,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist.xml"

    [xml]$ACLXMLBody = '<accessList xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"><networkItem address="'+$IP+'" type="'+$Action.ToUpper()+'" /></accessList>'


 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $ACLXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

        Write-Host "The ACL item has been added.  Please wait 10 seonds for confirmation:"

        Sleep 10

        Get-CloudLoadBalancerACLs -CloudLBID $CloudLBID -Region $Region
        
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $ACLXMLBody -ContentType application/xml -Method Post -ErrorAction Stop

        Write-Host "The ACL item has been added.  Please wait 10 seonds for confirmation:"

        Sleep 10

        Get-CloudLoadBalancerACLs -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-CloudLoadBalancerACL cmdlet will add/append an ACL item for a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are modifying.

 .PARAMETER IP
 Use this parameter to define the IP address for item to add to access list.  This can a single IP, such as "5.5.5.5" or a CIDR notated range, such as "172.50.0.0/16".

 .PARAMETER Action
 Use this parameter to define the action type of the item you're adding:

    ALLOW – Specifies items that will always take precedence over items with the DENY type.

    DENY – Specifies items to which traffic can be denied.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerACL -CloudLBID 116351 -IP 5.5.5.5/32 -Action deny -Region ord
 This example shows how to add an ACL item for the specified load balancer in the ORD region.  This example shows how to explicitly block a single IP from being served by your load balancer, the IP being 5.5.5.5.
#>
}

function Remove-CloudLoadBalancerACLItem {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$ACLItemID,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist/$ACLItemID.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist/$ACLItemID.xml"


 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

        Write-Host "The ACL item has been deleted. Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-CloudLoadBalancerACLs -CloudLBID $CloudLBID -Region $Region
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

        Write-Host "The ACL item has been deleted. Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-CloudLoadBalancerACLs -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerACLItem cmdlet will remove a specific  ACL item from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are modifying.

  .PARAMETER ACLItemID
 Use this parameter to define the ID of the ACL item that you would like to remove. If you are unsure of this ID, please run the "Get-CloudLoadBalancerACLs" cmdlet.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerACLItem -CloudLBID 116351 -ACLItemID 1234 -Region ORD
 This example shows how to remove an ACL item from the specified load balancer in the ORD region.
#>
}

function Remove-CloudLoadBalancerACL {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/accesslist.xml"


 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

        Write-Host "All ACL items have been deleted. Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-CloudLoadBalancerACLs -CloudLBID $CloudLBID -Region $Region
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

        Write-Host "All ACL items have been deleted. Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-CloudLoadBalancerACLs -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-CloudLoadBalancerACL cmdlet will remove ALL ACL items from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are modifying.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerACLItem -CloudLBID 116351 -ACLItemID 1234 -Region ORD
 This example shows how to remove an ACL item from the specified load balancer in the ORD region.
#>
}

function Add-SessionPersistence {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$PersistenceType,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/sessionpersistence.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/sessionpersistence.xml"

    [xml]$AddSessionPersistenceXMLBody = '<sessionPersistence xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" persistenceType="'+$PersistenceType.ToUpper()+'"/>'

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$AddPersistenceStep0 = Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary -ContentType application/xml -Body $AddSessionPersistenceXMLBody -Method Put -ErrorAction Stop
    [xml]$AddPersistencetFinal = ($AddPersistenceStep0.innerxml)

        if (!$AddPersistencetFinal) {
            Break
        }

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Session Persistence has now been enabled.  Please wait 10 seconds for an updated attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails -CloudLBID $CloudLBID -Region $Region

}

elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$AddPersistenceStep0 = Invoke-RestMethod -Uri $ORDLBURI  -Headers $HeaderDictionary -ContentType application/xml -Body $AddSessionPersistenceXMLBody -Method Put -ErrorAction Stop
    [xml]$AddPersistencetFinal = ($AddPersistenceStep0.innerxml)

        if (!$AddPersistencetFinal) {
            Break
        }

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Session Persistence has now been enabled.  Please wait 10 seconds for an update attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError

}
<#
 .SYNOPSIS
 The Add-SessionPersistence cmdlet will enable session persistence on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want to enabled session persistence. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-SessionPersistence -CloudLBID 116351 -PersistenceType source_ip -Region ord
 This example shows how to add source IP based session persistence to a cloud load balancer in the ORD region.
#>
}

function Update-SessionPersistence {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$PersistenceType,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/sessionpersistence.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/sessionpersistence.xml"

    [xml]$AddSessionPersistenceXMLBody = '<sessionPersistence xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" persistenceType="'+$PersistenceType.ToUpper()+'"/>'

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$AddPersistenceStep0 = Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary -ContentType application/xml -Body $AddSessionPersistenceXMLBody -Method Put -ErrorAction Stop
    [xml]$AddPersistencetFinal = ($AddPersistenceStep0.innerxml)

        if (!$AddPersistencetFinal) {
            Break
        }

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Session Persistence has now been modified.  Please wait 10 seconds for an updated attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails -CloudLBID $CloudLBID -Region $Region

}

elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$AddPersistenceStep0 = Invoke-RestMethod -Uri $ORDLBURI  -Headers $HeaderDictionary -ContentType application/xml -Body $AddSessionPersistenceXMLBody -Method Put -ErrorAction Stop
    [xml]$AddPersistencetFinal = ($AddPersistenceStep0.innerxml)

        if (!$AddPersistencetFinal) {
            Break
        }

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Session Persistence has now been modified.  Please wait 10 seconds for an update attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError

}
<#
 .SYNOPSIS
 The Update-SessionPersistence cmdlet will modify session persistence on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want to enabled session persistence. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Update-SessionPersistence -CloudLBID 116351 -PersistenceType source_ip -Region ord
 This example shows how to update the session persistence type to "SOURCE_IP" of a cloud load balancer in the ORD region.
#>
}

function Remove-SessionPersistence {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/sessionpersistence.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/sessionpersistence.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$PersistenceStep0 = Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    [xml]$PersistencetFinal = ($PersistenceStep0.innerxml)

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Session Persistence has now been disabled.  Please wait 10 seconds for an updated attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region

}

elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$PersistenceStep0 = Invoke-RestMethod -Uri $ORDLBURI  -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
    [xml]$PersistencetFinal = ($PersistenceStep0.innerxml)

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Session Persistence has now been disabled.  Please wait 10 seconds for an updated attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region

}

else {

    Send-RegionError

}
<#
 .SYNOPSIS
 The Remove-SessionPersistence cmdlet will disable session persistence on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want to enabled session persistence. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-SessionPersistence -CloudLBID 116351 -Region ord
 This example shows how to disable based session persistence on a cloud load balancer in the ORD region.
#>
}

function Add-ConnectionLogging {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionlogging.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionlogging.xml"

    [xml]$AddConnectionLoggingXMLBody = '<connectionLogging xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="true"/>'

 if ($Region -eq "DFW") {
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $AddConnectionLoggingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Connection logging has now been enabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID DFW
}

elseif ($Region -eq "ORD") {

            Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $AddConnectionLoggingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

            Write-Host "Connection logging has now been enabled. Please wait 10 seconds to see an updated detail listing:"

            Sleep 10

            Get-CloudLoadBalancerDetails $CloudLBID ORD
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-ConnectionLogging cmdlet will enable connection logging on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-ConnectionLogging -CloudLBID 116351 -Region ord
 This example shows how to enable connection logging on a CLB in the ORD region.
#>
}

function Remove-ConnectionLogging {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionlogging.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionlogging.xml"

    [xml]$AddConnectionLoggingXMLBody = '<connectionLogging xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="false"/>'

 if ($Region -eq "DFW") {
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $AddConnectionLoggingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Connection logging has now been disabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID DFW
}

elseif ($Region -eq "ORD") {

            Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $AddConnectionLoggingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

            Write-Host "Connection logging has now been disabled. Please wait 10 seconds to see an updated detail listing:"

            Sleep 10

            Get-CloudLoadBalancerDetails $CloudLBID ORD
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-ConnectionLogging cmdlet will disable connection logging on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-ConnectionLogging -CloudLBID 116351 -Region ord
 This example shows how to disable connection logging on a CLB in the ORD region.
#>
}

function Add-ConnectionThrottling {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [int]$MaxConnectionRate,
        [Parameter(Position=2,Mandatory=$true)]
        [int]$MaxConnections,
        [Parameter(Position=3,Mandatory=$true)]
        [int]$MinConnections,
        [Parameter(Position=4,Mandatory=$true)]
        [int]$RateInterval,
        [Parameter(Position=5,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionthrottle.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionthrottle.xml"

    [xml]$AddConnectionThrottleXMLBody = '<connectionThrottle xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
    minConnections="'+$MinConnections+'"
    maxConnections="'+$MaxConnections+'"
    maxConnectionRate="'+$MaxConnectionRate+'"
    rateInterval="'+$RateInterval+'" />'

 if ($Region -eq "DFW") {
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $AddConnectionThrottleXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Connection throttling has now been enabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID DFW
}

elseif ($Region -eq "ORD") {

            Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $AddConnectionThrottleXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

            Write-Host "Connection throttling has now been enabled. Please wait 10 seconds to see an updated detail listing:"

            Sleep 10

            Get-CloudLoadBalancerDetails $CloudLBID ORD
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-ConnectionThrottling cmdlet will enable connection throttling on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER MaxConnectionRate
 Use this parameter to define the maximum number of connections allowed from a single IP address in the defined "RateInterval" parameter. Setting a value of 0 allows an unlimited connection rate; otherwise, set a value between 1 and 100000.

 .PARAMETER MaxConnections
 Use this parameter to define the maximum number of connections to allow for a single IP address. Setting a value of 0 will allow unlimited simultaneous connections; otherwise set a value between 1 and 100000.

 .PARAMETER MinConnections
 Use this parameter to define the lowest possible number of connections per IP address before applying throttling restrictions. Setting a value of 0 allows unlimited simultaneous connections; otherwise, set a value between 1 and 1000.

 .PARAMETER RateInterval
 Use this parameter to define the frequency (in seconds) at which the "maxConnectionRate" parameter is assessed. For example, a "maxConnectionRate" value of 30 with a "rateInterval" of 60 would allow a maximum of 30 connections per minute for a single IP address. This value must be between 1 and 3600.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-ConnectionLogging -CloudLBID 116351 -Region ord
 This example shows how to enable connection logging on a CLB in the ORD region.
#>
}

function Update-ConnectionThrottling {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$false)]
        [switch]$ChangeMaxConnectionRate,
        [Parameter(Position=2,Mandatory=$false)]
        [switch]$ChangeMaxConnections,
        [Parameter(Position=3,Mandatory=$false)]
        [switch]$ChangeMinConnections,
        [Parameter(Position=4,Mandatory=$false)]
        [switch]$ChangeRateInterval,
        [Parameter(Position=5,Mandatory=$false)]
        [int]$MaxConnectionRate,
        [Parameter(Position=6,Mandatory=$false)]
        [int]$MaxConnections,
        [Parameter(Position=7,Mandatory=$false)]
        [int]$MinConnections,
        [Parameter(Position=8,Mandatory=$false)]
        [int]$RateInterval,
        [Parameter(Position=9,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionthrottle.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionthrottle.xml"

        if ($ChangeMaxConnectionRate) {
    
            [xml]$ChangeConnectionThrottleXMLBody = '<connectionThrottle xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" maxConnectionRate="'+$MaxConnectionRate+'"/>'

        }

        elseif ($ChangeMaxConnections) {

            [xml]$ChangeConnectionThrottleXMLBody = '<connectionThrottle xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" maxConnections="'+$MaxConnections+'"/>'

        }

        elseif ($ChangeMinConnections) {

            [xml]$ChangeConnectionThrottleXMLBody = '<connectionThrottle xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" minConnections="'+$MinConnections+'"/>'

        }

        elseif ($ChangeRateInterval) {
            
            [xml]$ChangeConnectionThrottleXMLBody = '<connectionThrottle xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" rateInterval="'+$RateInterval+'"/>'

        }

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$ThrottleStep0 = Invoke-RestMethod -Uri $DFWLBURI  -Headers $HeaderDictionary -ContentType application/xml -Body $ChangeConnectionThrottleXMLBody -Method Put -ErrorAction Stop
    [xml]$ThrottleFinal = ($ThrottleStep0.innerxml)

        if (!$ThrottleFinal) {
            Break
        }

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Connection Throttling values have now been modified.  Please wait 10 seconds for an updated attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails -CloudLBID $CloudLBID -Region $Region

}

elseif ($Region -eq "ORD") {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    [xml]$ThrottleStep0 = Invoke-RestMethod -Uri $ORDLBURI  -Headers $HeaderDictionary -ContentType application/xml -Body $ChangeConnectionThrottleXMLBody -Method Put -ErrorAction Stop
    [xml]$ThrottleFinal = ($ThrottleStep0.innerxml)

        if (!$ThrottleFinal) {
            Break
        }

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
        Write-Host "Connection Throttling values have now been modified.  Please wait 10 seconds for an updated attribute listing."

        Sleep 10

        Get-CloudLoadBalancerDetails -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError

}
<#
 .SYNOPSIS
 The Update-ConnectionThrottling cmdlet will modify connection throttling values on the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER $ChangeMaxConnectionRate
 Use this switch to indicate you wish to change the MaxConnectionRate value.

 .PARAMETER $ChangeMaxConnections
 Use this switch to indicate you wish to change the MaxConnections value.

 .PARAMETER $ChangeMinConnections
 Use this switch to indicate you wish to change the MinConnections value.

 .PARAMETER $ChangeRateInterval
 Use this switch to indicate you wish to change the RateInterval value.

 .PARAMETER MaxConnectionRate
 Use this parameter to define the maximum number of connections allowed from a single IP address in the defined "RateInterval" parameter. Setting a value of 0 allows an unlimited connection rate; otherwise, set a value between 1 and 100000.

 .PARAMETER MaxConnections
 Use this parameter to define the maximum number of connections to allow for a single IP address. Setting a value of 0 will allow unlimited simultaneous connections; otherwise set a value between 1 and 100000.

 .PARAMETER MinConnections
 Use this parameter to define the lowest possible number of connections per IP address before applying throttling restrictions. Setting a value of 0 allows unlimited simultaneous connections; otherwise, set a value between 1 and 1000.

 .PARAMETER RateInterval
 Use this parameter to define the frequency (in seconds) at which the "maxConnectionRate" parameter is assessed. For example, a "maxConnectionRate" value of 30 with a "rateInterval" of 60 would allow a maximum of 30 connections per minute for a single IP address. This value must be between 1 and 3600.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Update-ConnectionThrottling -CloudLBID 116351 -ChangeMaxConnections -MaxConnections 150 -Region ord
 This example shows how to update the MaxConnections value of a CLB in the ORD region
#>
}

function Remove-ConnectionThrottling {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionthrottle.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/connectionthrottle.xml"

 if ($Region -eq "DFW") {

        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $AddConnectionLoggingXMLBody -Method Delete -ErrorAction Stop

        Write-Host "Connection throttling has now been disabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID DFW
}

elseif ($Region -eq "ORD") {

            ## Retrieving authentication token
            Get-AuthToken
            
            Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $AddConnectionLoggingXMLBody -Method Delete -ErrorAction Stop

            Write-Host "Connection logging has now been disabled. Please wait 10 seconds to see an updated detail listing:"

            Sleep 10

            Get-CloudLoadBalancerDetails $CloudLBID ORD
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-ConnectionThrottling cmdlet will disable connection logging on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-ConnectionThrottling -CloudLBID 116351 -Region ord
 This example shows how to disable connection throttling on a CLB in the ORD region.
#>
}

function Get-HealthMonitor {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/healthmonitor.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/healthmonitor.xml"

 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
    Get-AuthToken
        
        [xml]$HealthMonitorStep0 = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop

            if (!$HealthMonitorStep0.healthMonitor.delay) {

                    Write-Host "This load balancer does not currently have any health monitors configured." -ForegroundColor Red

                }

                elseif ($HealthMonitorStep0.healthMonitor.type -eq "CONNECT") {

                    $HealthMonitorStep0.healthMonitor | ft $HealthMonitorConnectTable -AutoSize

                }

                elseif ($HealthMonitorStep0.healthMonitor.type -eq "HTTP") {

                    $HealthMonitorStep0.healthMonitor | ft $HealthMonitorHTTPTable -AutoSize

                }

                elseif ($HealthMonitorStep0.healthMonitor.type -eq "HTTPS") {

                    $HealthMonitorStep0.healthMonitor | ft $HealthMonitorHTTPTable -AutoSize

                }

}

elseif ($Region -eq "ORD") {

            ## Retrieving authentication token
    Get-AuthToken
            
            [xml]$HealthMonitorStep0 =  Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop

                if (!$HealthMonitorStep0.healthMonitor.delay) {

                    Write-Host "This load balancer does not currently have any health monitors configured." -ForegroundColor Red

                }

                elseif ($HealthMonitorStep0.healthMonitor.type -eq "CONNECT") {

                    $HealthMonitorStep0.healthMonitor | ft $HealthMonitorConnectTable -AutoSize

                }

                elseif ($HealthMonitorStep0.healthMonitor.type -eq "HTTP") {

                    $HealthMonitorStep0.healthMonitor | ft $HealthMonitorHTTPTable -AutoSize

                }

                elseif ($HealthMonitorStep0.healthMonitor.type -eq "HTTPS") {

                    $HealthMonitorStep0.healthMonitor | ft $HealthMonitorHTTPTable -AutoSize

                }

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-HealthMonitor cmdlet will return the status of health monitoring on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-HealthMonitor -CloudLBID 9956 -Region ord
 This example shows how to get the status and configuration of a cloud load balancer in the ORD region.
#>
}

function Add-HealthMonitor {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$false)]
        [switch]$WatchConnections,
        [Parameter(Position=2,Mandatory=$false)]
        [switch]$WatchHTTP,
        [Parameter(Position=2,Mandatory=$false)]
        [switch]$WatchHTTPS,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$MonitorDelay,
        [Parameter(Position=4,Mandatory=$true)]
        [string]$MonitorTimeout,
        [Parameter(Position=5,Mandatory=$true)]
        [string]$MonitorFailureAttempts,
        [Parameter(Position=6,Mandatory=$false)]
        [string]$MonitorBodyRegex,
        [Parameter(Position=7,Mandatory=$false)]
        [string]$MonitorStatusRegex,
        [Parameter(Position=8,Mandatory=$false)]
        [string]$MonitorHTTPPath,
        [Parameter(Position=9,Mandatory=$false)]
        [string]$MonitorHostHeader,
        [Parameter(Position=10,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/healthmonitor.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/healthmonitor.xml"

        if ($WatchConnections) {

            [xml]$HealthMonitorXMLBody = '<healthMonitor xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
    type="CONNECT"
    delay="'+$MonitorDelay+'"
    timeout="'+$MonitorTimeout+'"
    attemptsBeforeDeactivation="'+$MonitorFailureAttempts+'" />'

        }

        elseif ($WatchHTTP) {

             [xml]$HealthMonitorXMLBody = '<healthMonitor xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
    type="HTTP"
    delay="'+$MonitorDelay+'"
    timeout="'+$MonitorTimeout+'"
    attemptsBeforeDeactivation="'+$MonitorFailureAttempts+'"
    path="'+$MonitorHTTPPath+'"
    statusRegex="'+$MonitorStatusRegex+'"
    bodyRegex="'+$MonitorBodyRegex+'"
    hostHeader="'+$MonitorHostHeader+'"/>'

        }

        elseif ($WatchHTTPS) {

             [xml]$HealthMonitorXMLBody = '<healthMonitor xmlns="http://docs.openstack.org/loadbalancers/api/v1.0"
    type="HTTPS"
    delay="'+$MonitorDelay+'"
    timeout="'+$MonitorTimeout+'"
    attemptsBeforeDeactivation="'+$MonitorFailureAttempts+'"
    path="'+$MonitorHTTPPath+'"
    statusRegex="'+$MonitorStatusRegex+'"
    bodyRegex="'+$MonitorBodyRegex+'"
    hostHeader="'+$MonitorHostHeader+'"/>'

        }

 if ($Region -eq "DFW") {
        
    ## Retrieving authentication token
    Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $HealthMonitorXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Health Monitoring has now been enabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region
}

elseif ($Region -eq "ORD") {

     ## Retrieving authentication token
     Get-AuthToken
            
            Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $HealthMonitorXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

            Write-Host "Health Monitoring has now been enabled. Please wait 10 seconds to see an updated detail listing:"

            Sleep 10

            Get-CloudLoadBalancerDetails $CloudLBID $Region
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-HealthMonitor cmdlet will enable health monitoring on a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER WatchConnections
 Use this switch to indicate that you'd like to setup a basic connection health monitor. The monitor connects to each node on its defined port to ensure that the service is listening properly. The connect monitor is the most basic type of health check and does no post-processing or protocol specific health checks.

 .PARAMETER WatchHTTP
 Use this switch to indicate that you'd like to setup an HTTP health monitor. The HTTP and HTTPS monitor is more intelligent than the connect monitor. It is capable of processing an HTTP or HTTPS response to determine the condition of a node. It supports the same basic properties as the connect monitor and includes additional attributes that are used to evaluate the HTTP response.

 .PARAMETER WatchHTTPS
 Use this switch to indicate that you'd like to setup an HTTPS health monitor. The HTTP and HTTPS monitor is more intelligent than the connect monitor. It is capable of processing an HTTP or HTTPS response to determine the condition of a node. It supports the same basic properties as the connect monitor and includes additional attributes that are used to evaluate the HTTP response.

 .PARAMETER MonitorDelay
 Use this parameter to define the minimum number of seconds to wait before executing the health monitor. Must be a number between 1 and 3600. This parameter is needed for any type of health check.

 .PARAMETER MonitorTimeout
 Use this parameter to define the maximum number of seconds to wait for a connection to be established before timing out. Must be a number between 1 and 300. This parameter is needed for any type of health check.

 .PARAMETER MonitorFailureAttempts
 Use this parameter to define the number of permissible monitor failures before removing a node from rotation. Must be a number between 1 and 10. This parameter is needed for any type of health check.

 .PARAMETER MonitorBodyRegex
 Use this parameter to define a regular expression that will be used to evaluate the contents of the body of the HTTP/HTTPS response.

 .PARAMETER MonitorStatusRegEx
 Use this parameter to define a regular expression that will be used to evaluate the HTTP status code returned in the HTTP/HTTPS response.

 .PARAMETER MointorHTTPPath
 Use this parameter to define the HTTP path that will be used in the sample request.

 .PARAMETER MonitorHostHeader        
 Use this parameter to define the name of a host for which the health monitors will check. This parameter is only needed for an HTTP/HTTPS type monitor.


 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
#>
}

function Remove-HealthMonitor {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/healthmonitor.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/healthmonitor.xml"

 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        [xml]$HealthMonitorStep0 = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

         Write-Host "Health monitoring has been removed from this load balancer."
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
            
            [xml]$HealthMonitorStep0 =  Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop

            Write-Host "Health monitoring has been removed from this load balancer."

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-HealthMonitor cmdlet will remove a health monitor from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-HealthMonitor -CloudLBID 9956 -Region ord
 This example shows how to remove health mointoring from a cloud load balancer in the ORD region.
#>
}

function Add-ContentCaching {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/contentcaching.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/contentcaching.xml"

    ## Set XML body variable
    [xml]$ContentCachingXMLBody = '<contentCaching xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="true"/>'

 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        [xml]$ContentCachingStep0 = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $ContentCachingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

         Write-Host "Content caching has been enabled on this load balancer."
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
        
        [xml]$ContentCachingStep0 =  Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $ContentCachingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Content caching has been enabled on this load balancer."

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-ContentCaching cmdlet will enable content caching for a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-ContentCaching -CloudLBID 9956 -Region ord
 This example shows how to enable content caching for a cloud load balancer in the ORD region.
#>
}

function Remove-ContentCaching {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/contentcaching.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/contentcaching.xml"

    ## Set XML body variable
    [xml]$ContentCachingXMLBody = '<contentCaching xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="false"/>'

 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        [xml]$ContentCachingStep0 = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $ContentCachingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

         Write-Host "Content caching has been removed from this load balancer."
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
        
        [xml]$ContentCachingStep0 =  Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $ContentCachingXMLBody -ContentType application/xml -Method Put -ErrorAction Stop

        Write-Host "Content caching has been removed from this load balancer."

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-ContentCaching cmdlet will remove content caching from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-ContentCaching -CloudLBID 9956 -Region ord
 This example shows how to remove content caching from a cloud load balancer in the ORD region.
#>
}

function Get-SSLTermination {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    
    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"

 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
    Get-AuthToken
        
        [xml]$SSLTerminationStep0 = Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop
        [xml]$SSLTerminationFinal = $SSLTerminationStep0.InnerXml

        $SSLTerminationFinal.sslTermination | ft $SSLTable -Wrap
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
    Get-AuthToken
        
        [xml]$SSLTerminationStep0 = Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Method Get -ErrorAction Stop
        [xml]$SSLTerminationFinal = $SSLTerminationStep0.InnerXml

        $SSLTerminationFinal.sslTermination | ft $SSLTable -Wrap

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-SSLTermination cmdlet will retrieve the SSL termination settings from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-SSLTermination -CloudLBID 555 -Region ord
 This example shows how to retrieve the SSL termination settings from a cloud load balancer in the ORD region.
#>
}

function Add-SSLTermination {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$SSLPort,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$PrivateKey,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$Certificate,
        [Parameter(Position=4,Mandatory=$false)]
        [string]$IntermediateCertificate,
        [Parameter(Position=5,Mandatory=$false)]
        [switch]$Enabled,
        [Parameter(Position=6,Mandatory=$false)]
        [switch]$SecureTrafficOnly,
        [Parameter(Position=7,Mandatory=$true)]
        [string]$Region
        )

    
    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"

    if (($enabled) -and ($SecureTrafficOnly)) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="true" securePort="'+$SSLPort+'" secureTrafficOnly="true">
        <privatekey>'+$PrivateKey+'</privatekey>
        <certificate>'+$Certificate+'</certificate>
        <intermediateCertificate>'+$IntermediateCertificate+'</intermediateCertificate>
        </sslTermination>'
       
    }

    elseif (($enabled) -and (!$SecureTrafficOnly)) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="true" securePort="'+$SSLPort+'" secureTrafficOnly="false">
        <privatekey>'+$PrivateKey+'</privatekey>
        <certificate>'+$Certificate+'</certificate>
        <intermediateCertificate>'+$IntermediateCertificate+'</intermediateCertificate>
        </sslTermination>'
       
    }

    elseif ((!$enabled) -and ($SecureTrafficOnly)) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="false" securePort="'+$SSLPort+'" secureTrafficOnly="true">
        <privatekey>'+$PrivateKey+'</privatekey>
        <certificate>'+$Certificate+'</certificate>
        <intermediateCertificate>'+$IntermediateCertificate+'</intermediateCertificate>
        </sslTermination>'
       
    }

    elseif ((!$enabled) -and (!$SecureTrafficOnly)) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="false" securePort="'+$SSLPort+'" secureTrafficOnly="false">
        <privatekey>'+$PrivateKey+'</privatekey>
        <certificate>'+$Certificate+'</certificate>
        <intermediateCertificate>'+$IntermediateCertificate+'</intermediateCertificate>
        </sslTermination>'
       
    }




 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
    Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $SSLTerminationXMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
        
        Write-Host "SSL termination has been configured.  Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-SSLTermination -CloudLBID $CloudLBID -Region $Region
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
    Get-AuthToken
        
        Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $SSLTerminationXMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
        
        Write-Host "SSL termination has been configured.  Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-SSLTermination -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Add-SSLTermination cmdlet will add SSL termination to a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER SSLPort
 Use this parameter to define the port on which the SSL termination load balancer will listen for secure traffic. The SSLPort must be unique to the existing LB protocol/port combination. For example, port 443.

 .PARAMETER PrivateKey
 Use this parameter to define the private key for the SSL certificate. The private key is validated and verified against the provided certificate(s).

 .PARAMETER Certificate
 Use this parameter to define the certificate used for SSL termination. The certificate is validated and verified against the key and intermediate certificate if provided.

 .PARAMETER IntermediateCertificate
 Use this parameter to define the user's intermediate certificate used for SSL termination. The intermediate certificate is validated and verified against the key and certificate credentials provided.

 .PARAMETER Enabled
 Use this switch to indicate if the load balancer is enabled to terminate SSL traffic. If the Enabled switch is not passed, the load balancer will retain its specified SSL attributes, but will NOT immediately terminate SSL traffic upon configuration.

 .PARAMETER SecureTrafficOnly
 Use this switch to indicate if the load balancer may accept only secure traffic. If the SecureTrafficOnly switch is passed, the load balancer will NOT accept non-secure traffic. 

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Add-SSLTermination -CloudLBID 116351 -SSLPort 443 -PrivateKey "PrivateKeyGoesHereInQuotes" -Certificate "CertificateGoesHereInQuotes" -Enabled -Region ORD
 This example shows how to add SSL termination to a cloud load balancer in the ORD region.
#>
}

function Update-SSLTermination {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$false)]
        [switch]$EnableSSLTermination,
        [Parameter(Position=2,Mandatory=$false)]
        [switch]$DisableSSLTermination,
        [Parameter(Position=3,Mandatory=$false)]
        [switch]$UpdateSSLPort,
        [Parameter(Position=4,Mandatory=$false)]
        [string]$SSLPort,
        [Parameter(Position=5,Mandatory=$false)]
        [switch]$EnableSecureTrafficOnly,
        [Parameter(Position=6,Mandatory=$false)]
        [switch]$DisableSecureTraficOnly,
        [Parameter(Position=7,Mandatory=$true)]
        [string]$Region
        )

    
    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"

    if ($EnableSSLTermination) {
        
            [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="true"></sslTermination>'
       
    }

    elseif ($DisableSSLTermination) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" enabled="false"></sslTermination>'
       
    }

    elseif ($EnableSecureTrafficOnly) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" secureTrafficOnly="true"></sslTermination>'
       
    }

    elseif ($DisableSecureTrafficOnly) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" secureTrafficOnly="false"></sslTermination>'
       
    }

    elseif ($UpdateSSLPort) {
        
        [xml]$SSLTerminationXMLBody = '<sslTermination xmlns="http://docs.openstack.org/loadbalancers/api/v1.0" securePort="'+$SSLPort+'"></sslTermination>'
       
    }


 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
    Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Body $SSLTerminationXMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
        
        Write-Host "SSL termination configuration has been updated.  Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-SSLTermination -CloudLBID $CloudLBID -Region $Region
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
    Get-AuthToken
        
        Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Body $SSLTerminationXMLBody -ContentType application/xml -Method Put -ErrorAction Stop | Out-Null
        
        Write-Host "SSL termination configuration has been updated.  Please wait 10 seconds for confirmation:"

        Sleep 10

        Get-SSLTermination -CloudLBID $CloudLBID -Region $Region

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Update-SSLTermination cmdlet will add SSL termination to a cloud load balancer in the specified region.

 .DESCRIPTION
 Using this cmdlet, you can alter the port in which you would like to accept secure traffic, whether or not you would like the load balancer to be SSL ONLY, and whether or not SSL termination is active or simply configured and standing by.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER UpdateSSLPort
 Use this switch to indicate that you would like to update the port which your load balancer will be accepting secure traffic on. Define the new port with the SSLPort parameter.
 
 .PARAMETER SSLPort
 Use this parameter to define the port on which the SSL termination load balancer will listen for secure traffic. The SSLPort must be unique to the existing LB protocol/port combination. For example, port 443. Use this in conjunction with the UpdateSSLPort switch.

 .PARAMETER EnableSSLTermination
 Use this switch to indicate that SSL termination can be enabled on the specified load balancer. If this switch is passed, the load balancer will enact its configuration for SSL termination.

 .PARAMETER DisableSSLTermination
 Use this switch to indicate that SSL termination can be disabled on the specified load balancer. If this switch is passed, the load balancer will retain its configuration for SSL termination, however, it will not terminate SSL connections again until you re-enable it.

 .PARAMETER EnableSecureTrafficOnly
 Use this switch to indicate if the load balancer may accept only secure traffic. If this switch is passed, the load balancer will begin ONLY accepting secure traffic.  All non-secure traffic will be rejected.

 .PARAMETER DisableSecureTrafficOnly
 Use this switch to indicate if the load balancer may accept non-secure and secure traffic. If this switch is passed, the load balancer will begin accepting all types of traffic.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Update-SSLTermination -CloudLBID 116351 -DisableSSLTrafficOnly -Region ORD
 This example shows how to update the SSL termination settings of a cloud load balancer in the ORD region. This example would configure the load balancer to accept both non-secure and secure traffic.
#>
}

function Remove-SSLTermination {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    
    ## Setting variables needed to execute this function
    Set-Variable -Name DFWLBURI -Value "https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"
    Set-Variable -Name ORDLBURI -Value "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/$CloudDDI/loadbalancers/$CloudLBID/ssltermination.xml"

 if ($Region -eq "DFW") {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $DFWLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
        
        Write-Host "All SSL settings have been removed."
}

elseif ($Region -eq "ORD") {

        ## Retrieving authentication token
        Get-AuthToken
        
        Invoke-RestMethod -Uri $ORDLBURI -Headers $HeaderDictionary -Method Delete -ErrorAction Stop
        
        Write-Host "All SSL settings have been removed."

}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Remove-SSLTermination cmdlet will remove all SSL termination settings from a cloud load balancer in the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudLBID
 Use this parameter to define the ID of the load balancer you are about to modify.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Remove-SSLTermination -CloudLBID 555 -Region ord
 This example shows how to remove the SSL termination settings from a cloud load balancer in the ORD region.
#>
}