## Info ##
## Author: Mitch Robins (mitch.robins) ##
## Description: PSv3 module for NextGen Rackspace Cloud API interaction (PowerClient)##
## Version 2.1 ##
## Contact Info: mitch.robins@rackspace.com ##

## Define Global Variables Needed for API Comms ##

Set-Variable -Name CloudUsername -Value "" -Scope Global
Set-Variable -Name CloudAPIKey -Value "" -Scope Global
Set-Variable -Name CloudDDI -Value "" -Scope Global

## Valid Rackspace Regions
$RegionList = "DFW", "IAD", "HKG", "ORD", "SYD"

## *The CloudDDI variable is your account number or tenant ID.  This can be found at the top right of your screen when logged into the Rackspace Cloud Control Panel*
## THIS VARIABLE WILL NOT BE USED IN V1 - Set-Variable -Name GlobalServerRegion -Value "ORD" -Scope Global

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
@{Expression={$_.addresses.public.addr};Label="Server IP Addresses";width=200}

$NetworkListTable = @{Expression={$_.name};Label="Network Name";width=25},  
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

## Build base service URLs and URIs
function Get-URI ($service, $region) {

    $Endpoint = Get-CloudEndpoints $service | where {$_.region -eq $region}
    $Global:URL = $Endpoint.publicURL

    $Global:serversURI = "/servers"
    $Global:serversDetailURI = "/servers/detail"
    $Global:serversActionURI = "/servers/$CloudServerID/action"
    $Global:flavorsURI = "/flavors"
    $Global:flavorsDetailURI = "$flavorsURI/detail"
    $Global:imagesURI = "/images"
    $Global:imagesDetailURI = "$imagesURI/detail"
    $Global:volumesURI = "/servers/$CloudServerID/os-volume_attachments"
    $Global:networksURI = "/networks"
    $Global:subnetsURI = "/subnets"
    $Global:blockstoragevolumesURI = "/volumes"
    $Global:blockstoragevolumetypesURI = "/types"
    $Global:loadbalancersURI = "/loadbalancers"
    $Global:loadbalancersDetailURI = "$loadbalancersURI/$CloudLBID"
    $Global:loadbalancersSessionURI = "$loadbalancersDetailURI/sessionpersistence"
    $Global:loadbalancersCachingURI = "$loadbalancersDetailURI/contentcaching"
    $Global:loadbalancersLogURI = "$loadbalancersDetailURI/connectionlogging"
    $Global:loadbalancersACLURI = "$loadbalancersDetailURI/accesslist"
    $Global:loadbalancersThrottleURI = "$loadbalancersDetailURI/connectionthrottle"
    $Global:loadbalancersHealthURI = "$loadbalancersDetailURI/healthmonitor"
    $Global:loadbalancersSSLURI = "$loadbalancersDetailURI/ssltermination"
    $Global:loadbalancersACLDetailURI = "$loadbalancersACLURI/$ACLItemID"
    $Global:loadbalancersProtocolURI = "$loadbalancersURI/protocols"
    $Global:loadbalancersAlgorithmURI = "$loadbalancersURI/algorithms"
    $Global:loadbalancersNodeURI = "$loadbalancersURI/$CloudLBID/nodes"
    $Global:loadbalancersNodeEventsURI = "$loadbalancersNodeURI/events"
    $Global:loadbalancersNodeDetailURI = "$loadbalancersNodeURI/$CloudLBNodeID"
} 

## DEFINE FUNCTIONS

## Global API Call
function Get-APIRequest {
    Param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $URI
        )
    Try {
        $global:Response = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -ContentType application/json -Method Get
        }
    Catch {
        Write-Host "There has been an API call error:" $Error[0]
          }
    }

function Add-APIRequest {
    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $URI,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Body
        )

    Try {
        $global:Response = Invoke-RestMethod -Uri $URI -Headers $HeaderDictionary -Body $Body -ContentType application/json -Method Post
        }
    Catch {
        Write-Host "There has been an API call error:" $Error[0]
          }
    }

function Update-APIRequest {
    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $URI,
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Body
        )

    Try {
        $global:Response = Invoke-WebRequest -Uri $URI -Headers $HeaderDictionary -DisableKeepAlive -Body $Body -ContentType application/json -Method Put
        }
    Catch {
        Write-Host "There has been an API call error:" $Error[0]
          }
    }

function Remove-APIRequest {
    Param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $URI
        )
    Try {
        $global:Response = Invoke-WebRequest -Uri $URI -Headers $HeaderDictionary -DisableKeepAlive -ContentType application/json -Method Delete -ErrorAction Stop
        }
    Catch {
        Write-Host "There has been an API call error:" $Error[0]
          }
    }
 

## Region mismatch 
function Send-RegionError {
    
    ## This is simply writing an error to the console.
    Write-Host "You have entered an invalid region identifier.  Valid region identifiers for this tool are one of the following: $RegionList" -ForegroundColor Red
}


## Global Authentication Cmdlets

function Get-AuthToken {
    ## Check for current authentication token and retrieves a new one if needed
        if (($CloudUsername -eq "") -or ($CloudAPIKey -eq "") -or ($CloudDDI -eq "")) {
            Write-Host "You are missing critical authentication details.  Please make sure you've entered a username, API key, and DDI (account number) in the module."
            }
        
        elseif ((Get-Date) -ge $token.access.token.expires) {
                Pop-AuthToken
            }

        else {}
}

function Pop-AuthToken() {
    
    ## Setting variables needed for function execution
    Set-Variable -Name AuthURI -Value "https://identity.api.rackspacecloud.com/v2.0/tokens"
    Set-Variable -Name AuthBody -Value ('{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'+$CloudUsername+'", "apiKey":"'+$CloudAPIKey+'"}}}')

    ## Making the call to the token authentication API and saving it's output as a global variable for reference in every other function.
    Set-Variable -Name token -Value (Invoke-RestMethod -Uri $AuthURI -Body $AuthBody -ContentType application/json -Method Post) -Scope Global
    
    $FinalToken = $token.access.token.id
    $Global:Catalog = $token.access.serviceCatalog
    

    ## Headers in powershell need to be defined as a dictionary object, so here I'm creating a dictionary object with the newly granted token. It's global, as it's needed in every future request.
    Set-Variable -Name HeaderDictionary -Value (new-object "System.Collections.Generic.Dictionary``2[[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]") -Scope Global
    $HeaderDictionary.Add("X-Auth-Token", $finaltoken)
}

function Get-CloudEndpoints ($CloudProduct){
    switch ( $CloudProduct ) {
        "cloudNetworks"  {
            return ( $catalog | `
                where { $_.name -eq "cloudNetworks" } ).endpoints | `
                select region, publicURL
            }
        "cloudServers"  {
            return ( $catalog | `
                where { $_.name -eq "cloudServersOpenStack" } ).endpoints | `
                select region, publicURL
            }
        "cloudBlockStorage" {
            return ( ($catalog | `
                where { $_.type -eq "volume" }).endpoints | `
                select region, publicURL )
        }
        "cloudLoadBalancers" {
            return ( ($catalog | `
                where {$_.name -eq "cloudLoadBalancers" -and $_.type -eq "rax:load-balancer"}).endpoints | `
                select region, publicURL)
        }
        "cloudFiles" {
            return ( ($catalog | `
                where { $_.type -eq "object-store" }).endpoints | `
                select region, publicURL)  
                }
        "cloudDNS" {
            return ( ($catalog | `
                where { $_.type -eq "rax:dns" }).endpoints | `
                select region, publicURL)
        }
        "cloudMonitoring" {
            return ( ($catalog | `
                where { $_.type -eq "rax:monitor" }).endpoints | `
                select region, publicURL)
        }
                            
    }
}


## Cloud Server API Cmdlets

function Get-CloudServerImages {
    
    Param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
	$URI = "$URL$imagesDetailURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region){
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Making the call to the API for a list of available server images and storing data into a variable
    Get-APIRequest $URI

    ## Use dot notation to show the information needed without further parsing.
    $Response.Images | Sort-Object Name | ft $ImageListTable -AutoSize
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

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages -Region DFW
 This example shows how to get a list of all available images in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages ORD
 This example shows how to get a list of all available images in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably. Example output:

 
 PS C:\Users\mitch.robins> Get-CloudServerImages ord

Image ID                             Image Name                                                                       Image Status Image Last Updated  
--------                             ----------                                                                       ------------ ------------------  
c94f5e59-0760-467a-ae70-9a37cfa6b94e Arch 2012.08                                                                     ACTIVE       2013-02-07T20:50:25Z
03318d19-b6e6-4092-9b5c-4758ee0ada60 CentOS 5.6                                                                       ACTIVE       2013-02-07T20:51:03Z
acf05b3c-5403-4cf0-900c-9b12b0db0644 CentOS 5.8                                                                       ACTIVE       2013-02-27T16:56:09Z
a3a2c42f-575f-4381-9c6d-fcd3b7d07d17 CentOS 6.0                                                                       ACTIVE       2013-02-27T16:57:56Z
0cab6212-f231-4abd-9c70-608d0d0e04ba CentOS 6.2                                                                       ACTIVE       2013-02-27T16:58:45Z
c195ef3b-9195-4474-b6f7-16e5bd86acd0 CentOS 6.3                                                                       ACTIVE       2013-02-27T16:59:31Z
...

.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Images-d1e4427.html
#>
}

function Get-CloudServers{

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$serversDetailURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available servers and storing data into a variable
    Get-APIRequest $URI

    ## Handling empty response bodies indicating that no servers exist in the queried data center
    if ($Response.Servers.id -eq $null) {

        Write-Host "You do not currently have any Cloud Servers provisioned in the $Region region."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Use dot notation to show the information needed without further parsing.
       $Response.Servers | Sort-Object Name | ft $ServerListTable -AutoSize

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

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers -Region DFW
 This example shows how to get a list of all servers currently deployed in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServers ORD
 This example shows how to get a list of all servers deployed in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.

 PS C:\Users\mitch.robins> Get-CloudServers ord

Server ID                            Server Name        Server Status Server IP Addresses                                                      
---------                            -----------        ------------- -------------------                                                      
abc123ab-a367-1234-970f-3e43617c194e AA-Mongo           ACTIVE        {IPs}  
abc123ab-537c-1234-9a17-659c15a78ad7 Chad_AD            ACTIVE        {IPS}   
abc123ab-6ee8-1234-b283-d768c6f33633 HotlabDJR2         ACTIVE        {IPs} 

.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/List_Servers-d1e2078.html

#>
}

function Get-CloudServerDetails {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

        ## Setting variables needed to execute this function
        Get-URI cloudServers $Region
        $URI = "$URL$serversURI/$CloudServerID"

    if ($RegionList -contains $Region) {

    Get-AuthToken

    Get-APIRequest $URI
    
        Write-Host ` '
    Server Status: '($Response.server.status)'
    Server Name: '($Response.server.name)'
    Server ID: '($Response.server.id)'
    Server Created: '($Response.server.created)'
    Server Last Updated: '($Response.server.updated)'
    Server Image ID: '($Response.server.image.id)'
    Server Flavor ID: '($Response.server.flavor.id)'
    Server IPv4: '($Response.server.accessIPv4)'
    Server IPv6: '($Response.server.accessIPv6)'
    Server Build Progress: '($Response.server.progress)''

    }

    else {

    Send-RegionError

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

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW
 This example shows how to get explicit data about one cloud server from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Bandwidth -Region ORD
 This example shows how to get explicit data about one cloud server from the ORD region, including bandwidth statistics.

 PS C:\Users\mitch.robins> Get-CloudServerDetails -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region ORD

    Server Status:  ACTIVE 
    Server Name:  AA-Mongo 
    Server ID:  abc123ef-9876-abcd-1234-123456abcdef
    Server Created:  2013-03-11T16:09:15Z 
    Server Last Updated:  2013-03-11T16:14:27Z 
    Server Image ID:  8a3a9f96-b997-46fd-b7a8-a9e740796ffd 
    Server Flavor ID:  4 
    Server IPv4:  100.100.100.100
    Server IPv6:  2001:::::::15d0 
    Server Build Progress:  100 

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Get_Server_Details-d1e2623.html

#>
}

function Get-CloudServerFlavors() {
    param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$flavorsDetailURI"

if ($RegionList -contains $Region) {

    Get-AuthToken

    Get-APIRequest $URI
    
    $Response.Flavors | Sort-Object id | ft $FlavorListTable -AutoSize
    }

else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudServerFlavors cmdlet will pull down a list of Rackspace Cloud flavors. Flavors are the predefined resource templates in Openstack.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerFlavors -Region DFW
 This example shows how to get flavor data from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerFlavors ORD
 This example shows how to get flavor data from the ORD region, without specifying the parameter name itself.

 PS C:\Users\mitch.robins> Get-CloudServerFlavors ORD

Flavor ID Flavor Name             RAM (in MB) Disk Size Swap Size vCPUs Rx/Tx Factor
--------- -----------             ----------- --------- --------- ----- ------------
2         512MB Standard Instance 512         20        512       1     2.0         
3         1GB Standard Instance   1024        40        1024      1     3.0         
4         2GB Standard Instance   2048        80        2048      2     6.0         
5         4GB Standard Instance   4096        160       2048      2     10.0        
6         8GB Standard Instance   8192        320       2048      4     15.0        
7         15GB Standard Instance  15360       620       2048      6     20.0        
8         30GB Standard Instance  30720       1200      2048      8     30.0     

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Flavors-d1e4180.html

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
    Get-URI cloudServers $Region
    $URI = "$URL$volumesURI"

 if ($RegionList -contains $Region) {
        
        Get-APIRequest $URI

            if ($Response.volumeAttachments.Count -eq 0) {
                Write-Host "This cloud server has no cloud block storage volumes attached." -ForegroundColor Red
            }

            else {
                $Response.volumeAttachments.volumeAttachment | ft $ServerAttachmentsTable -AutoSize
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
 Use this parameter to indicate the 32 character UUID of the cloud server which you wish to view storage attachments. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerAttachments -CloudServerID e6ce2ee7-5d9a-4ef4-a78c-fe12f873f46c -Region ord
 This example shows how to retrieve a list of all attached cloud block storage volumes of the specified cloud server in the ORD region.

 PS C:\Users\mitch.robins> Get-CloudServerAttachments -CloudServerID e6ce2ee7-5d9a-4ef4-a78c-fe12f873f46c -Region ord
 This cloud server has no cloud block storage volumes attached.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerAttachments -CloudServerID 30e52067-e3ba-4bf6-98df-4e9b0e83e205 -Region DFW
 This example shows how to retrieve a list of all attached cloud block storage volumes of the specified cloud server in the DFW region.

PS C:\Users\mitch.robins> Get-CloudServerAttachments -CloudServerID 30e52067-e3ba-4bf6-98df-4e9b0e83e205 -Region DFW

Attachment ID                        Attached Volume ID                   Attached Device Type
-------------                        ------------------                   --------------------
216fdfab-87a9-4963-aa11-6dd004ce0301 216fdfab-87a9-4963-aa11-6dd004ce0301 /dev/xvdb     

.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Volume_Attachment_Actions.html

#>
}

function Add-CloudServer {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerName,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$CloudServerFlavorID,
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
        Get-URI cloudServers $Region
        $URI = "$URL$serversURI"

    if ($CloudServerNetwork1ID) {


        if ($Isolated) {
            $Body = '{
    "server" : {
        "name" : "'+$CloudServerName+'",
        "imageRef" : "'+$CloudServerImageID+'",
        "flavorRef" : "'+$CloudServerFlavorID+'",
        "OS-DCF:diskConfig" : "AUTO",
        "networks": [
            {
                 "uuid": "'+$CloudServerNetwork1ID+'"
            }
        ]
    }
}'
            }

            else {
            $Body = '{
    "server" : {
        "name" : "'+$CloudServerName+'",
        "imageRef" : "'+$CloudServerImageID+'",
        "flavorRef" : "'+$CloudServerFlavorID+'",
        "OS-DCF:diskConfig" : "AUTO",
        "networks": [
            {
                 "uuid": "'+$CloudServerNetwork1ID+'"
            }, 
            {
                 "uuid": "00000000-0000-0000-0000-000000000000"
            }, 
            {
                 "uuid": "11111111-1111-1111-1111-111111111111"
            } 
        ]
    }
}'
            }
    }

    elseif ($CloudServerNetwork2ID) {

            if ($Isolated) {
            $Body = '{
    "server" : {
        "name" : "'+$CloudServerName+'",
        "imageRef" : "'+$CloudServerImageID+'",
        "flavorRef" : "'+$CloudServerFlavorID+'",
        "OS-DCF:diskConfig" : "AUTO",
        "networks": [
            {
                 "uuid": "'+$CloudServerNetwork1ID+'"
            }, 
            {
                 "uuid": "'+$CloudServerNetwork2ID+'"
            }
        ]
    }
}'
            }

            else {
            $Body = '{
    "server" : {
        "name" : "'+$CloudServerName+'",
        "imageRef" : "'+$CloudServerImageID+'",
        "flavorRef" : "'+$CloudServerFlavorID+'",
        "OS-DCF:diskConfig" : "AUTO",
        "networks": [
            {
                 "uuid": "'+$CloudServerNetwork1ID+'"
            }, 
            {
                 "uuid": "'+$CloudServerNetwork2ID+'"
            }, 
            {
                 "uuid": "00000000-0000-0000-0000-000000000000"
            }, 
            {
                 "uuid": "11111111-1111-1111-1111-111111111111"
            } 
        ]
    }
}'
            }

    }

    elseif ($CloudServerNetwork3ID) {

            if ($Isolated) {
            $Body = '{
    "server" : {
        "name" : "'+$CloudServerName+'",
        "imageRef" : "'+$CloudServerImageID+'",
        "flavorRef" : "'+$CloudServerFlavorID+'",
        "OS-DCF:diskConfig" : "AUTO",
        "networks": [
            {
                 "uuid": "'+$CloudServerNetwork1ID+'"
            }, 
            {
                 "uuid": "'+$CloudServerNetwork2ID+'"
            }, 
            {
                 "uuid": "'+$CloudServerNetwork3ID+'"
            } 
        ]
    }
}'
            }

            else {
            $Body = '{
    "server" : {
        "name" : "'+$CloudServerName+'",
        "imageRef" : "'+$CloudServerImageID+'",
        "flavorRef" : "'+$CloudServerFlavorID+'",
        "OS-DCF:diskConfig" : "AUTO",
        "networks": [
            {
                 "uuid": "'+$CloudServerNetwork1ID+'"
            }, 
            {
                 "uuid": "'+$CloudServerNetwork2ID+'"
            },
            {
                 "uuid": "'+$CloudServerNetwork3ID+'"
            },
            {
                 "uuid": "00000000-0000-0000-0000-000000000000"
            }, 
            {
                 "uuid": "11111111-1111-1111-1111-111111111111"
            } 
        ]
    }
}'
            }
    }

    else {
    $Body = '{"server":{"name":"'+$CloudServerName+'","imageRef":"'+$CloudServerImageID+'","flavorRef":"'+$CloudServerFlavorID+'","OS-DCF:diskConfig":"AUTO"}}'
            }
 
 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Add-APIRequest $URI $Body

        Write-Host "The following is the ID and password of your new server. Please wait 10 seconds for a refreshed Cloud Server list."

        $Response.Server | ft $newservertable

        Sleep 10

        Get-CloudServers $Region
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
 Use this parameter to indicate the region in which you would like to execute this request.

 .PARAMETER Isolated
 Use this parameter to indiacte that you'd like this server to be in an isolated network.  Using this switch will render this server ONLY connected to the UUIDs of the custom networks you define.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer -CloudServerName NewlyCreatedTestServer -CloudServerFlavorID 3 -CloudServerImageID 26fec9f2-2fb5-4e5e-a19f-0d12540ec639 -Region DFW
 This example shows how to spin up a new Windows Server 2012 cloud server called "NewlyCreatedTestServer" , with 1GB RAM, 1 vCPU, and 40GB of local storage, in the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServer NewlyCreatedTestServer1 4 c195ef3b-9195-4474-b6f7-16e5bd86acd0 ORD
 This example shows how to spin up a new CentOS 6.3 cloud server called "NewlyCreatedTestServer1", with 2GB RAM, 2 vCPU, and 80GB of lcoal storage, in the ORD region. Notice how parameter names were not needed in the command to save time.

.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/CreateServers.html

#>
}

function Add-CloudServerImage {

    Param(
        [string]$CloudServerID,
        [string]$NewImageName,
        [string]$Region
        )
    
    ## Setting variables needed to execute this function
    $Body = '{"createImage" : {"name" : "'+$NewImageName+'"} }'

    Get-URI cloudServers $Region
    $URI = "$URL$serversActionURI"

if ($RegionList -contains $Region) {

    Get-AuthToken

    Add-APIRequest $URI $Body

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

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudServerImage  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -NewImageName SnapshotCopy1 -Region DFW
 This example shows how to create a new server image snapshot of a serve, UUID of "abc123ef-9876-abcd-1234-123456abcdef", and the snapshot being titled "SnapshotCopy1" in the DFW region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Create_Image-d1e4655.html

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
        [Parameter(Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Mandatory=$true)]
        [string]$Region,
        [Parameter(Mandatory=$true)]
        [string]$NewValue
        )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$serversURI/$CloudServerID"

    if ($UpdateName) {

    $Body = '{
  "server" :
    {
        "name" : "'+$NewValue+'"
    }
}'
    }

    elseif ($UpdateIPv4Address) {

    $Body = '{
  "server" :
    {
        "accessIPv4" : "'+$NewValue+'"
    }
}'
    
    }

    elseif ($UpdateIPv6Address) {

    ## Setting variables needed to execute this function
    $Body = '{
  "server" :
    {
        "accessIPv6" : "'+$NewValue+'"
    }
}'
    
    Get-AuthToken
    
    Set-Variable -Name ServerUpdateURI -Value "https://$Region.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID"

    Invoke-RestMethod -Uri $ServerUpdateURI -Headers $HeaderDictionary -Body $UpdateCloudServerXMLBody -ContentType application/xml -Method Post -ErrorAction Stop | Out-Null

    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region
                    
                    }

if ($RegionList -contains $Region) {

    Get-AuthToken

    Update-APIRequest $URI $Body | Out-Null
                
    Write-Host "Your Cloud Server has been updated. Please wait 10 seconds for a refreshed Cloud Server list."

    Sleep 10

    Get-CloudServers $Region

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

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -UpdateName abc123ef-9876-abcd-1234-123456abcdef  New-Windows-Web-Server
 This example shows the command to rename a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new name of "New-Windows-Web-Server".

  .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -UpdateAdminPassword abc123ef-9876-abcd-1234-123456abcdef  NewC0mplexPassw0rd!
 This example shows the command to update the adminsitrative password of a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new password of "NewC0mplexPassw0rd!".

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ServerUpdate.html

#>
}

function Update-CloudServerPassword {

    Param(
        [Parameter(Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Mandatory=$true)]
        [string]$Region,
        [Parameter(Mandatory=$true)]
        [string]$NewValue
        )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$serversActionURI"

    $Body = '{
   "changePassword":
      {
         "adminPass": "'+$NewValue+'"
      }
}'

if ($RegionList -contains $Region) {

    Get-AuthToken

    Add-APIRequest $URI $Body | Out-Null

    Write-Host "Your Cloud Server has been updated."

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

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -UpdateName abc123ef-9876-abcd-1234-123456abcdef  New-Windows-Web-Server
 This example shows the command to rename a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new name of "New-Windows-Web-Server".

  .EXAMPLE
 PS C:\Users\Administrator> Update-CloudServer -UpdateAdminPassword abc123ef-9876-abcd-1234-123456abcdef  NewC0mplexPassw0rd!
 This example shows the command to update the adminsitrative password of a Rackspace Cloud Server with an ID of "abc123ef-9876-abcd-1234-123456abcdef" to a new password of "NewC0mplexPassw0rd!".

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/ServerUpdate.html

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
    Get-URI cloudServers $Region
    $URI = "$URL$serversActionURI"

    if ($hard) {
        $Body = '{
        "reboot" : {
            "type" : "HARD"
        }
    }'
               }
    else {
    
    $Body = '{
        "reboot" : {
            "type" : "SOFT"
        }
    }'
        }

if ($RegionList -contains $Region) {

    Get-AuthToken

    Add-APIRequest $URI $Body

    Write-Host "Your Cloud Server is now being rebooted based on your input.  Please allow a few seconds for the reboot to begin"

    }

<#
 .SYNOPSIS
 The Restart-CloudServer cmdlet will carry out a soft reboot of the specified cloud server.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server of which you want to reboot. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

  .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .PARAMETER Hard
 Use this switch to indicate that you would like the server be hard rebooted, as opposed to the default of a soft reboot.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW
 This example shows how to request a soft reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW -Hard
 This example shows how to request a hard reboot of cloud server, UUID of abc123ef-9876-abcd-1234-123456abcdef, in the DFW region.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Reboot_Server-d1e3371.html

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
        [string]$CloudServerFlavorID
        )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$serversActionURI"
    
    if ($Confirm) {
      
    $Body = '{
"confirmResize" : null
}'

    $Out = "Your server resize has been confirmed."
            }
    
    elseif ($Revert) {
      
      ## Setting variables needed to execute this function
    $Body = '{
    "revertResize" : null
}'

    $Out = "Your server resize has been reverted."
            }
    
    else {
    
    ## Setting variables needed to execute this function
    $Body = '{
    "resize" : {
        "flavorRef" : "'+$CloudServerFlavorID+'"
    }
}'

    $Out = "Your server will now be resized.  Please note, resize requests are only valid against standard flavors, and not compute/memory/IO optimized flavors."
    }

if ($RegionList -contains $Region) {    

      Add-APIRequest $URI $Body

      Write-Host $Out

}

else {

    Send-RegionError

}
<#
 .SYNOPSIS
 The Resize-CloudServer cmdlet will resize the specified cloud server to a new flavor.  After the original request, you can also use this command to either REVERT your changes, or CONFIRM them.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server which you want to resize. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

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

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Resize_Server-d1e3707.html

#>
}

function Remove-CloudServer { 

    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$True)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$serversURI/$CloudServerID"

if ($RegionList -contains $Region) {

    Get-AuthToken
    
    Remove-APIRequest $URI -ErrorAction Stop

    Write-Host "Your server has been scheduled for deletion. This action will take up to a minute to complete."

    }

else {
    Send-RegionError
}
<#
 .SYNOPSIS
 The Remove-CloudServer cmdlet will permanently delete a cloud server from your account.

 .DESCRIPTION
 See synopsis.

 .PARAMETER CloudServerID
 Use this parameter to indicate the 32 character UUID of the cloud server that you would like to delete. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServer  -CloudServerID abc123ef-9876-abcd-1234-123456abcdef -Region DFW 
 This example shows how to delete a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServer  abc123ef-9876-abcd-1234-123456abcdef ORD
 This example shows how to delete a server, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the ORD region, without using the parameter names.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Server-d1e2883.html

#>
}

function Remove-CloudServerImage {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerImageID,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$imagesURI/$CloudServerImageID"

if ($RegionList -contains $Region) {
    
    Get-AuthToken

    Remove-APIRequest $URI -ErrorAction Stop

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

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudServerImage  -CloudServerImageID abc123ef-9876-abcd-1234-123456abcdef -Region DFW 
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Restart-CloudServerImage  abc123ef-9876-abcd-1234-123456abcdef ORD
 This example shows how to delete a server image snapshot, UUID of abc123ef-9876-abcd-1234-123456abcdef, from the ORD region, without using the parameter names.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Image-d1e4957.html

#>
}

function Set-CloudServerRescueMode {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudServerID,
        [Parameter(Position=1,Mandatory=$false)]
        [string]$RescueImageID,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Get-URI cloudServers $Region
    $URI = "$URL$serversActionURI"
    
if ($RescueImageID) {    
    
    ## Setting variables needed to execute this function
    $Body = '{
    "rescue" :
        {
            "rescue_image_ref": "'+$RescueImageID+'"
        }
}'

}

else {

        ## Setting variables needed to execute this function
    $Body = '{
    "rescue" :
        {
            "rescue_image_ref": "none"
        }
}'

}

if ($RegionList -contains $Region) {

    Get-AuthToken

    Add-APIRequest $URI $Body | Out-Null

    $RescuePass = $Response.adminPass

    Write-Host "Rescue Mode takes 5 - 10 minutes to enable. Please do not interact with this server again until it's status is RESCUE.
    Your temporary password in rescue mode is:

    $RescuePass
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
    $Body = '{
"unrescue" : null
}'
    
    Get-URI cloudServers $Region
    $URI = "$URL$serversActionURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {
    
    ## Retrieving authentication token
    Get-AuthToken

    Add-APIRequest $URI $Body

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
    Get-URI cloudBlockStorage $Region
    $URI = "$URL$blockstoragevolumetypesURI"

    if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $Response.volume_types | ft $VolTypeTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudBlockStorageTypes cmdlet will retrieve a list of all cloud block storage volume types.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageTypes -Region DFW 
 This example shows how to list all cloud block storage volumes in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageTypes ORD
 This example shows how to list all cloud block storage volumes in the ORD region, without parameter names.

 PS C:\Users\mitch.robins> Get-CloudBlockStorageTypes ord

ID Name
-- ----
1  SATA
2  SSD

.LINK
http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumeTypes_v1__tenant_id__types_v1__tenant_id__types.html

#>
}

function Get-CloudBlockStorageVolList {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Get-URI cloudBlockStorage $Region
    $URI = "$URL$blockstoragevolumesURI"

    if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $Response.volumes | ft $VolListTable -AutoSize
    }

    else {

    Send-RegionError

    }
<#
 .SYNOPSIS
 The Get-CloudBlockStorageVolList cmdlet will retrieve a list of all cloud block storage volumes for the specified region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVolList -Region DFW 
 This example shows how to list all cloud block storage volumes in the DFW region.

 PS C:\Users\mitch.robins> Get-CloudBlockStorageVolList -Region DFW 

Vol ID                               Vol Name      Vol Status Vol Type Vol Size Vol Desc. Vol Created        
------                               --------      ---------- -------- -------- --------- -----------        
216fdfab-87a9-1234-1234-6dd004ce0301 mitch_testing in-use     SATA     100      None      2013-03-20 22:07:37
6754e10a-e7d0-1234-1234-e9a59fa2933e rhcsa-luks    in-use     SATA     100      None      2013-02-26 22:49:53

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVolList ORD
 This example shows how to list all cloud block storage volumes in the ORD region, without parameter names.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumesSimple__v1__tenant_id__volumes.html

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
    Set-Variable -Name URI -Value "https://$Region.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes/$CloudBlockStorageVolID"

    if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $Response.volume | ft $VolTable -AutoSize
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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol -CloudBlockStorageVolID 216fdfab-1234-4963-aa11-6dd004ce0301 -Region DFW
 This example shows how to list details for a cloud block storage volume in the DFW region.

 PS C:\Users\mitch.robins> Get-CloudBlockStorageVol -CloudBlockStorageVolID 216fdfab-87a9-4963-aa11-6dd004ce0301 -Region DFW

ID                                   Name          Status Attached To                          Type Size Desc. Created            
--                                   ----          ------ -----------                          ---- ---- ----- -------            
216fdfab-1234-4963-aa11-6dd004ce0301 mitch_testing in-use 30e52067-e3ba-4bf6-98df-4e9b0e83e205 SATA 100  None  2013-03-20 22:07:37

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageVol ORD
 This example shows how to list details for a cloud block storage volume in the DFW region, without parameter names.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolume__v1__tenant_id__volumes.html

#>
}

function Add-CloudBlockStorageVol {

    Param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $CloudBlockStorageVolName,
        [Parameter (Position=2, Mandatory=$false)]
        [string] $CloudBlockStorageVolDesc,
        [Parameter (Position=3, Mandatory=$true)]
        [int] $CloudBlockStorageVolSize,
        [Parameter (Position=4, Mandatory=$true)]
        [string] $CloudBlockStorageVolType,
        [Parameter (Position=5, Mandatory=$true)]
        [string] $Region
    )

    ## Force switch variable setting
    if ($CloudBlockStorageVolSize -lt 50) {
        Write-Host "You must enter a volume size of greater than 75 GB for SATA volumes and 50 GB for SSD volumes." -ForegroundColor Red
        Break
    }

    elseif ($CloudBlockStorageVolSize -gt 1024) {
        Write-Host "You must enter a volume size of less than 1024GB." -ForegroundColor Red
        Break
    }

    ## Setting variables needed to execute this function
    Set-Variable -Name URI -Value "https://$Region.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes"

    ## Create JSON request
    $Body = '{
    "volume": {
        "display_name": "'+$CloudBlockStorageVolName+'",
        "display_description": "'+$CloudBlockStorageVolDesc+'",
        "size": '+$CloudBlockStorageVolSize+',
        "volume_type": "'+$CloudBlockStorageVolType+'"
     }
}'

    if ($RegionList -contains $Region) {
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Add-APIRequest $URI $Body

    $Response.volume | ft $VolTable -AutoSize
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

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/POST_createVolume__v1__tenant_id__volumes.html

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
    Set-Variable -Name URI -Value "https://$Region.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/volumes/$CloudBlockStorageVolID"

    if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Remove-APIRequest $URI

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageVol  -CloudBlockStorageVolID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Region dfw
 This example shows how to remove a cloud block storage volume from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageVol 5ea333b3-cdf7-40ee-af60-9caf871b15fa ORD
 This example shows how to list details for a cloud block storage volume in the DFW region, without parameter names.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/DELETE_deleteVolume__v1__tenant_id__volumes.html

#>
}

function Get-CloudBlockStorageSnapList {

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name URI -Value "https://$Region.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots"

        if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
    $Response.snapshots | ft $VolSnapTable -AutoSize

    if ($Response.snapshots.Count -eq 0) {
        Write-Host "You do not currently have any Block Storage Volume snapshots."
        }

    else {}

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnapList -Region DFW 
 This example shows how to list all cloud block storage snapshots in the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnapList ORD
 This example shows how to list all cloud block storage snapshots in the ORD region, without parameter names.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getSnapshotsSimple__v1__tenant_id__snapshots.html

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
    Set-Variable -Name URI -Value "https://$Region.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots/$CloudBlockStorageSnapID"

    if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
    $Response.snapshot | ft $VolSnapTable -AutoSize
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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnap -CloudBlockStorageSnapID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Region DFW
 This example shows how to list details for a cloud block storage snapshot in the DFW region.

 PS C:\Users\mitch.robins> Get-CloudBlockStorageSnap -CloudBlockStorageSnapID 5ea333b3-1234-40ee-af60-9caf871b15fa -Region DFW

Snap ID                              Name                Status    Progress Vol. ID                              Size Desc. Created            
-------                              ----                ------    -------- -------                              ---- ----- -------            
5ea333b3-1234-40ee-af60-9caf871b15fa rhcsa-luks-snaptest available 0%       6754e10a-1234-47f5-b181-e9a59fa2933e 100  None  2013-03-20 17:54:39

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudBlockStorageSnap -CloudBlockStorageSnapID abc123ab-1234-40ee-af60-9caf871b15fa -Region ORD
 This example shows how to list details for a cloud block storage snapshot in the ORD region, without parameter names.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getSnapshot__v1__tenant_id__snapshots.html

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
    Set-Variable -Name URI -Value "https://$Region.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots"

    ## Create JSON request
    $Body = '{
    "snapshot": {
        "display_name": "'+$CloudBlockStorageSnapName+'",
        "display_description": "'+$CloudBlockStorageSnapDesc+'",
        "volume_id": "'+$CloudBlockStorageVolID+'",
        "force": '+$ForceOut+'
     }
}'

    if ($RegionList -contains $Region) {
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Add-APIRequest $URI $Body

    $Response.snapshot | ft $VolSnapTable -AutoSize

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudBlockStorageSnap -CloudBlockStorageVolID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -CloudBlockStorageSnapName Snapshot-Test -CloudBlockStorageSnapDesc This is a test snapshot -Region DFW -Force
 This example shows how to add a cloud block storage snapshot in the DFW region.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/POST_createSnapshot__v1__tenant_id__snapshots.html

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
    Set-Variable -Name URI -Value "https://$Region.blockstorage.api.rackspacecloud.com/v1/$CloudDDI/snapshots/$CloudBlockStorageSnapID"

    if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available volumes and storing data into a variable
    Remove-APIRequest $URI

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
 Use this parameter to define the ID of the cloud block storage snapshot that you would like to delete.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageSnap  -CloudBlockStorageSnapID 5ea333b3-cdf7-40ee-af60-9caf871b15fa -Region dfw
 This example shows how to remove a cloud block storage snapshot from the DFW region.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudBlockStorageSnap 5ea333b3-cdf7-40ee-af60-9caf871b15fa ORD
 This example shows how to list details for a cloud block storage snapshot in the DFW region, without parameter names.

 .LINK
 http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/DELETE_deleteSnapshot__v1__tenant_id__snapshots.html

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
    Set-Variable -Name URI -Value "https://$Region.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments"

    $Body = '{
   "volumeAttachment":{
      "device":null,
      "volumeId":"'+$CloudBlockStorageVolID+'"
   }
}'

 if ($RegionList -contains $Region) {
        
        Add-APIRequest $URI $Body | Out-Null

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Attach_Volume_to_Server.html

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
    Set-Variable -Name URI -Value "https://$Region.servers.api.rackspacecloud.com/v2/$CloudDDI/servers/$CloudServerID/os-volume_attachments/$CloudServerAttachmentID"

 if ($RegionList -contains $Region) {
        
        Remove-APIRequest $URI -ErrorAction Stop

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
 Use this parameter to indicate the 32 character UUID of the cloud server to which you wish to detach storage. If you need to find this information, you can run the "Get-CloudServers" cmdlet for a complete listing of servers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Volume_Attachment.html

#>
}


## Cloud Network API Cmdlets

function Get-CloudNetworks{

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Get-URI cloudNetworks $Region
    $URI = "$URL$networksURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available networks and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $Response.networks | Sort-Object label | ft $NetworkListTable -AutoSize

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudNetworks -Region DFW
 This example shows how to get a list of all networks currently deployed in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudNetworks ORD
 This example shows how to get a list of all networks deployed in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.

 PS C:\Users\mitch.robins> Get-CloudNetworks ORD
 
Network Name Network ID                          
------------ ----------                          
pstest       191d3959-331e-4e29-a5f7-a8c0619123df
pstest1      dfc46217-942a-4609-98b4-ed916df8547f

.LINK
http://docs.rackspace.com/servers/api/v2/cn-devguide/content/list_networks.html

#>
}

<# function Get-CloudNetworksSubnets{

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Get-URI cloudNetworks $Region
    $URI = "$URL$subnetsURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available networks and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $Response.networks | Sort-Object label | ft $NetworkListTable -AutoSize

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudNetworks -Region DFW
 This example shows how to get a list of all networks currently deployed in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudNetworks ORD
 This example shows how to get a list of all networks deployed in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.

 PS C:\Users\mitch.robins> Get-CloudNetworks ORD
 
Network Name Network ID                          
------------ ----------                          
pstest       191d3959-331e-4e29-a5f7-a8c0619123df
pstest1      dfc46217-942a-4609-98b4-ed916df8547f

.LINK
http://docs.rackspace.com/servers/api/v2/cn-devguide/content/list_networks.html


}#>

function Add-CloudNetwork {
    
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudNetworkLabel,
        [Parameter(Position=1,Mandatory=$true)]
        [string]$Region
        )

    ## Setting variables needed to execute this function
    Get-URI cloudNetworks $Region
    $URI = "$URL$networksURI"

    $Body = '{
    "network": 
    {
        "name": "'+$CloudNetworkLabel+'",
        "shared": false,
        "tenant_id": "'+$CloudDDI+'"
    }
}'
 
 if ($RegionList -contains $Region) {
        
        Get-AuthToken
        
        Add-APIRequest $URI $Body -ErrorAction Stop

        Write-Host "You have just created the following cloud network:"

        $Response.network

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
 Use this parameter to define the name/label of the cloud network you are about to create.

 .PARAMETER CloudNetworkCIDR
 Use this parameter to define the IP block that is going to be used for this cloud network.  This must be written in CIDR notation, for example, "172.16.0.0/24" without the quotes.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudNetwork -CloudNetworkLabel DBServers -CloudNetworkCIDR 192.168.101.0/24 -Region DFW
 This example shows how to spin up a new cloud network called DBServers, which will service IP block 192.168.101.0/24, in the DFW region.

.EXAMPLE
 PS C:\Users\Administrator> Add-CloudNetwork PaymentServers 192.168.101.0/24 ORD
 This example shows how to spin up a new cloud network called PaymentServers, which will service IP block 192.168.101.0/24 in the ORD region, without using the parameter names.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cn-devguide/content/create_virtual_interface.html

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
        Get-URI cloudNetworks $Region
        $URI = "$URL$networksURI/$CloudNetworkID"

 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Remove-APIRequest $URI

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
 Use this parameter to define the name/label of the cloud network you are about to delete.

.PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudNetwork -CloudNetworkID 88e316b1-8e69-4591-ba92-bea8bb1837f5 -Region ord
 This example shows how to delete a cloud network with an ID of 88e316b1-8e69-4591-ba92-bea8bb1837f5 from the ORD region.

.EXAMPLE
 PS C:\Users\Administrator> Remove-CloudNetwork 88e316b1-8e69-4591-ba92-bea8bb1837f5 DFW
 This example shows how to delete a cloud network with an ID of 88e316b1-8e69-4591-ba92-bea8bb1837f5 from the DFW region, without the parameter names.

 .LINK
 http://docs.rackspace.com/servers/api/v2/cn-devguide/content/delete_network.html

#>
}



## Cloud Load Balancer API Cmdlets

function Get-CloudLoadBalancers{

    Param(
        [Parameter (Position=0, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    Get-APIRequest $URI

    ## Handling empty response bodies indicating that no load balancers exist in the queried data center
    if ($Response.loadBalancers.Count -eq 0) {

        Write-Host "You do not currently have any Cloud Load Balancers provisioned in the $Region region."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
        $Response.loadBalancers | Sort-Object Name | ft $LBListTable -AutoSize

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancers -Region DFW
 This example shows how to get a list of all load balancers currently deployed in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancers ORD
 This example shows how to get a list of all load balancers deployed in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably.

 PS C:\Users\mitch.robins>  Get-CloudLoadBalancers ORD

CLB ID CLB Name            CLB Status CLB Algorithm              CLB Port CLB Node Count
------ --------            ---------- -------------              -------- --------------
1234   andrei-lb           ACTIVE     RANDOM                     443      2             
12345  josh-lb-plesk       ACTIVE     LEAST_CONNECTIONS          80       1             

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancers-d1e1367.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersDetailURI"
        $URI2 = "$URL$loadbalancersCachingURI"

    if ($RegionList -contains $Region) {

    Get-AuthToken

    Get-APIRequest $URI

    $ContentCachingDetails = Invoke-RestMethod -Uri $URI2 -Headers $HeaderDictionary -Method Get -ErrorAction Stop

    ## Handling empty response bodies indicating that no servers exist in the queried data center
    if ($Response.loadBalancer -eq $null) {

        Write-Host "You have entered an incorrect Cloud Load Balancer ID."

    }

            $lbip0 = $Response.loadBalancer.virtualIps
            $nodeip0 = $Response.loadBalancer.nodes
        
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

        $LBDetailOut = @{"CLB Content Caching"=($ContentCachingFinal.contentCaching.enabled);"CLB Name"=($Response.loadbalancer.name);"CLB ID"=($Response.loadbalancer.id);"CLB Algorithm"=($Response.loadbalancer.algorithm);"CLB Timeout"=($Response.loadbalancer.timeout);"CLB Protocol"=($Response.loadbalancer.protocol);"CLB Port"=($Response.loadbalancer.port);"CLB Status"=($Response.loadbalancer.status);"CLB IP(s)"=($Response.ip);"CLB Session Persistence"=($Response.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($Response.loadbalancer.created.time);"CLB Updated"=($Response.loadbalancer.updated.time);"- CLB Node Count"=($Response.loadBalancer.nodes.Count);"- CLB Node IDs"=($Response.loadbalancer.nodes.id);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($Response.loadbalancer.nodes.port);"- CLB Node Condition"=($Response.loadbalancer.nodes.condition);"- CLB Node Status"=($Response.loadbalancer.nodes.status);"CLB Logging"=($Response.loadbalancer.connectionlogging.enabled);"CLB Connections (Min)"=($Response.loadbalancer.connectionthrottle.minconnections);"CLB Connections (Max)"=($Response.loadbalancer.connectionthrottle.maxconnections);"CLB Connection Rate (Max)"=($Response.loadbalancer.connectionthrottle.maxconnectionrate);"CLB Connection Rate Interval"=($Response.loadbalancer.connectionthrottle.rateinterval)}

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
 Use this parameter to indicate the region in which you would like to execute this request. 

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerDetails -CloudLBID 12345 -Region DFW
 This example shows how to get explicit data about one cloud load balancer from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerDetails 12345 ORD
 This example shows how to get explicit data about one cloud load balancer from the ORD region, without using the parameter names.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancer_Details-d1e1522.html

#>
}

function Get-CloudLoadBalancerProtocols{

    ## Setting variables needed to execute this function
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersProtocolURI"

    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $Response.Protocols | Sort-Object Name | ft -AutoSize

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerProtocols cmdlet will pull down a list of all available Rackspace Cloud Load Balancer protocols.

 .DESCRIPTION
 See the synopsis field.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerProtocols
 This example shows how to get a list of all load balancer protocols available for use.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancing_Protocols-d1e4269.html

#>
}

function Get-CloudLoadBalancerAlgorithms{

    ## Setting variables needed to execute this function
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersAlgorithmURI"

    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $Response.algorithms | Sort-Object Name | ft -AutoSize

<#
 .SYNOPSIS
 The Get-CloudLoadBalancerAlgorithms cmdlet will pull down a list of all available Rackspace Cloud Load Balancer algorithms.

 .DESCRIPTION
 See the synopsis field.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerAlgorithms
 This example shows how to get a list of all load balancer algorithms available for use.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Load_Balancing_Algorithms-d1e4459.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersURI"

        $Body = '{
        "loadBalancer": {
            "name": "'+$CloudLBName+'",
            "port": '+$CloudLBPort+',
            "protocol": "'+$CloudLBProtocol.ToUpper()+'",
            "algorithm": "'+$CloudLBAlgorithm.ToUpper()+'",
            "virtualIps": [
                {
                    "type": "PUBLIC"
                }
            ],
            "nodes": [
                {
                    "address": "'+$CloudLBNodeIP+'",
                    "port": '+$CloudLBNodePort+',
                    "condition": "'+$CloudLBNodeCondition.ToUpper()+'"
                }
            ]
        }
    }'

 
 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Add-APIRequest $URI $Body

        Write-Host "The following is the information for your new CLB. A refreshed CLB list will appear in 10 seconds."

        $lbip0 = $Response.loadBalancer.virtualIps
        $nodeip0 = $Response.loadBalancer.nodes
        
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

        $LBDetailOut = @{"CLB Name"=($Response.loadbalancer.name);"CLB ID"=($Response.loadbalancer.id);"CLB Algorithm"=($Response.loadbalancer.algorithm);"CLB Protocol"=($Response.loadbalancer.protocol);"CLB Port"=($Response.loadbalancer.port);"CLB Status"=($Response.loadbalancer.status);"CLB IP(s)"=($LBIPFinal.ip);"CLB Session Persistence"=($Response.loadbalancer.sessionpersistence.persistenceType);"CLB Created"=($Response.loadbalancer.created.time);"CLB Updated"=($Response.loadbalancer.updated.time);"- CLB Node ID(s)"=($Response.loadbalancer.node.id);"- CLB Node Count"=($Response.loadBalancer.nodes.Count);"- CLB Node IP"=($NodeIPFinal.IP);"- CLB Node Port"=($Response.loadbalancer.nodes.port);"- CLB Node Condition"=($Response.loadbalancer.nodes.condition);"- CLB Node Status"=($Response.loadbalancer.nodes.status)}

        $LBDetailOut.GetEnumerator() | Sort-Object -Property Name -Descending

        Sleep 10

        Get-CloudLoadBalancers $Region
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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancer -CloudLBName TestLB -CloudLBPort 80 -CloudLBProtocol HTTP -CloudLBAlgorithm RANDOM -CloudLBNodeIP 10.1.1.10 -CloudLBNodePort 80 -CloudLBNodeCondition ENABLED  -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Create_Load_Balancer-d1e1635.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersNodeURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    Get-APIRequest $URI

    ## Handling empty response bodies indicating that no load balancers exist in the queried data center
    if ($Response.nodes -eq $null) {

        Write-Host "You do not currently have any nodes provisioned to this Cloud Load Balancer."

    }
    
    ## See first "if" block for notes on each line##
    else {
        
        ## Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
     
        $Response.nodes

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList -CloudLBID 12345 -Region DFW
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeList 12345 ORD
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the ORD region, without using the parameter names.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/List_Nodes-d1e2218.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersNodeURI"

        Get-AuthToken
	
		if (!$CloudLBNodeWeight) {
		
		$Body = '{"nodes": [
        {
            "address": "'+$CloudLBNodeIP+'",
            "port": '+$CloudLBNodePort+',
            "condition": "'+$CloudLBNodeCondition.ToUpper()+'",
            "type":"'+$CloudLBNodeType.ToUpper()+'"
        }
    ]
}'
        }
	 
	 	elseif ($CloudLBNodeWeight) {
	 	
	 	$Body = '{"nodes": [
        {
            "address": "'+$CloudLBNodeIP+'",
            "port": '+$CloudLBNodePort+',
            "condition": "'+$CloudLBNodeCondition.ToUpper()+'",
            "weight": '+$CloudLBNodeWeight+',
            "type":"'+$CloudLBNodeType.ToUpper()+'"
        }
    ]
}'
        }
 
 if ($RegionList -contains $Region) {
        
    Add-APIRequest $URI $Body
	
    Write-Host "The node has been added as follows:"

	$Response.nodes
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
 Use this parameter to define the name of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Add_Nodes-d1e2379.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersNodeURI/$CloudLBNodeID"

     if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Remove-APIRequest $URI
	
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
 Use this parameter to define the name of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER CloudLBNodeID
 Use this parameter to define the ID of the node you wish to remove from the load balancer configuration.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerNode -CloudLBID 123456 -CloudLBNodeID 5 -Region DFW
 This example shows how to spin up a new load balancer called TestLB, balancing incoming HTTP port 80 traffic randomly to a server with a private IP address of 10.1.1.10 on port 80, in the DFW region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Remove_Nodes-d1e2675.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersDetailURI"

     if ($RegionList -contains $Region) {

        Get-AuthToken        
        
        Remove-APIRequest $URI
	
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
 Use this parameter to define the name of the load balancer you are about to remove. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancer -CloudLBID 123456 -Region DFW
 This example shows how to remove a load balancer with an ID of 12345 in the DFW region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Remove_Load_Balancer-d1e2093.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersDetailURI"

        if ($ChangeName) {
            $Body = '{"loadBalancer":{
    "name": "'+$CloudLBName+'"
    }
}'
        }

        elseif ($ChangePort) {
            $Body = '{"loadBalancer":{
    "port": '+$CloudLBPort+'
    }
}'
        }

        elseif ($ChangeProtocol) {
            $Body = '{"loadBalancer":{
    "protocol": "'+$CloudLBProtocol.ToUpper()+'"
    }
}'
        }

        elseif ($ChangeAlgorithm) {
            $Body = '{"loadBalancer":{
    "algorithm": "'+$CloudLBAlgorithm.ToUpper()+'"
    }
}'
        }

        elseif ($ChangeTimeout) {
            $Body = '{"loadBalancer":{
    "timeout": '+$CloudLBTimeout+'
    }
}'
        }

 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Update-APIRequest $URI $Body

        Write-Host "Your load balancer has been updated. Updated information will be shown in 10 seconds:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Update_Load_Balancer_Attributes-d1e1812.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersNodeDetailURI"

        if ($ChangeCondition) {
            $Body = '{"node":{
        "condition": "'+$CloudLBNodeCondition.ToUpper()+'"
    }
}'
        }

        elseif ($ChangeType) {
            $Body = '{"node":{
        "type": "'+$CloudLBNodeType+'",
    }
}'
        }

        elseif ($ChangeWeight) {
            $Body = '{"node":{
        "weight": '+$CloudLBNodeWeight+'
    }
}'
        }

 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Update-APIRequest $URI $Body

        Write-Host "Your node has been updated. Updated information will be shown in 10 seconds:"

        Sleep 10

        Get-CloudLoadBalancerNodeList $CloudLBID $Region
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Update-CloudLoadBalancer -ChangeType -CloudLBID 12345 -CloudLBNodeID 1234 -CloudLBNodeType SECONDARY -Region DFW
 This example shows how to modify a load balancer node to become SECONDARY in the DFW region.

 .LINK
http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Modify_Nodes-d1e2503.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersNodeEventsURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API for a list of available load balancers and storing data into a variable
    Get-APIRequest $URI

    ## Since the response body is JSON, we can use dot notation to show the information needed without further parsing.

    if ($Response.NodeServiceEvents.Count -eq 0) {

    Write-Host "There are no events posted for this node."

    }

    else {
     
    $Response.NodeServiceEvents | ft $NodeServiceEventTable -AutoSize

    }
}

else {

    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudLoadBalancerNodeEvents cmdlet will pull retrieve all service events from the specified load balancer.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER CloudLBID
 Use this parameter to indicate the ID of the cloud load balancer of which you want explicit details. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeEvents -CloudLBID 12345 -Region DFW
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerNodeEvents -CloudLBID 12345 -Region ORD
 This example shows how to get a list of all nodes currently provisioned behind a load balancer with an ID of 12345, from the ORD region, without using the parameter names.

 PS C:\Users\mitch.robins> Get-CloudLoadBalancerNodeEvents -CloudLBID 12345 -Region ORD

Node ID Node Msg                                        CLB ID Msg Title           Msg Description                                                   Msg Type    Msg Severity Msg Created        
------- --------                                        ------ ---------           ---------------                                                   --------    ------------ -----------        
38484   Timeout while waiting for valid server response 1234   Node Status Updated Node '38484' status changed to 'OFFLINE' for load balancer '9956' UPDATE_NODE INFO         03-30-2013 17:07:47
38485   Timeout while waiting for valid server response 1234   Node Status Updated Node '38485' status changed to 'OFFLINE' for load balancer '9956' UPDATE_NODE INFO         03-30-2013 17:07:50

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Node-Events-d1e264.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersACLURI"

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Get-APIRequest $URI

        if (!$Response.accessList) {

                Write-Host "This load balancer does not currently have any ACLs configured."

            }

        else {
            
                $Response.accessList | ft $ACLTable -AutoSize

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
 Use this parameter to define the ID of the load balancer you are querying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudLoadBalancerACLs -CloudLBID 51885 -Region DFW
 This example shows how to get all ACL items from the specified load balancer in the DFW region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersACLURI"

    $Body = '{
    "accessList": [
        {
            "address": "'+$IP+'",
            "type": "'+$Action.ToUpper()+'"
        }
    ]
}'


 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Add-APIRequest $URI $Body

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
 Use this parameter to define the ID of the load balancer you are modifying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER IP
 Use this parameter to define the IP address for item to add to access list.  This can a single IP, such as "5.5.5.5" or a CIDR notated range, such as "172.50.0.0/16".

 .PARAMETER Action
 Use this parameter to define the action type of the item you're adding:

    ALLOW – Specifies items that will always take precedence over items with the DENY type.

    DENY – Specifies items to which traffic can be denied.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.
 
 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudLoadBalancerACL -CloudLBID 116351 -IP 5.5.5.5/32 -Action deny -Region ord
 This example shows how to add an ACL item for the specified load balancer in the ORD region.  This example shows how to explicitly block a single IP from being served by your load balancer, the IP being 5.5.5.5.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersACLDetailURI"

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Remove-APIRequest $URI

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
 Use this parameter to define the ID of the load balancer you are modifying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

  .PARAMETER ACLItemID
 Use this parameter to define the ID of the ACL item that you would like to remove. If you are unsure of this ID, please run the "Get-CloudLoadBalancerACLs" cmdlet.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerACLItem -CloudLBID 116351 -ACLItemID 1234 -Region ORD
 This example shows how to remove an ACL item from the specified load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersACLURI"

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Remove-APIRequest $URI

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
 Use this parameter to define the ID of the load balancer you are modifying. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudLoadBalancerACLItem -CloudLBID 116351 -ACLItemID 1234 -Region ORD
 This example shows how to remove an ACL item from the specified load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Access_Lists-d1e3187.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersSessionURI"

    $Body = '{
   "sessionPersistence":{
      "persistenceType":"'+$PersistenceType.ToUpper()+'"
   }
}'

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    Update-APIRequest $URI $Body

    ## Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
     
    Write-Host "Session Persistence has now been enabled.  Please wait 10 seconds for an updated attribute listing."

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
 Use this parameter to indicate the ID of the cloud load balancer of which you want to enable session persistence. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-SessionPersistence -CloudLBID 116351 -PersistenceType source_ip -Region ord
 This example shows how to add source IP based session persistence to a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Session_Persistence-d1e3733.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersSessionURI"

    $Body = '{
   "sessionPersistence":{
      "persistenceType":"'+$PersistenceType.ToUpper()+'"
   }
}'

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    Update-APIRequest $URI $Body

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
     
    Write-Host "Session Persistence has now been modified.  Please wait 10 seconds for an updated attribute listing."

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
 Use this parameter to indicate the ID of the cloud load balancer of which you want to update session persistence settings. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Update-SessionPersistence -CloudLBID 116351 -PersistenceType source_ip -Region ord
 This example shows how to update the session persistence type to "SOURCE_IP" of a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Session_Persistence-d1e3733.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersSessionURI"

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    Remove-APIRequest $URI

    ## Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
     
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
 Use this parameter to indicate the ID of the cloud load balancer from which you want to disable session persistence. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.
 
 .PARAMETER PeresistenceType
 Use this parameter to define the type of persistence you would like to enable on the specified load balancer.  The following modes of persistence are supported:

 HTTP_COOKIE - A session persistence mechanism that inserts an HTTP cookie and is used to determine the destination back-end node. This is supported for HTTP load balancing only.
 SOURCE_IP   - A session persistence mechanism that will keep track of the source IP address that is mapped and is able to determine the destination back-end node. This is supported for HTTPS pass-through and non-HTTP load balancing only.
 
 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-SessionPersistence -CloudLBID 116351 -Region ord
 This example shows how to disable based session persistence on a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Manage_Session_Persistence-d1e3733.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersLogURI"

    $Body = '{
   "connectionLogging":{
      "enabled":true
   }
}'

 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Update-APIRequest $URI $Body

        Write-Host "Connection logging has now been enabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-ConnectionLogging -CloudLBID 116351 -Region ord
 This example shows how to enable connection logging on a CLB in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Log_Connections-d1e3924.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersLogURI"

    $Body = '{
   "connectionLogging":{
      "enabled":false
   }
}'

 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Update-APIRequest $URI $Body

        Write-Host "Connection logging has now been disabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-ConnectionLogging -CloudLBID 116351 -Region ord
 This example shows how to disable connection logging on a CLB in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Log_Connections-d1e3924.html

#>
}

function Add-ConnectionThrottling {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$CloudLBID,
        [Parameter(Position=1,Mandatory=$false)]
        [int]$MaxConnectionRate,
        [Parameter(Position=2,Mandatory=$false)]
        [int]$MaxConnections,
        [Parameter(Position=3,Mandatory=$false)]
        [int]$MinConnections,
        [Parameter(Position=4,Mandatory=$false)]
        [int]$RateInterval,
        [Parameter(Position=5,Mandatory=$true)]
        [string]$Region
        )


    ## Setting variables needed to execute this function
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancerThrottleURI"

    $Body = '{
    "connectionThrottle":{
        "maxConnections": '+$MaxConnections+',
        "minConnections": '+$MinConnections+',
        "maxConnectionRate": '+$MaxConnectionRate+',
        "rateInterval": '+$RateInterval+'
    }
}'

 if ($RegionList -contains $Region) {

        Get-AuthToken
        
        Update-APIRequest $URI $Body

        Write-Host "Connection throttling has now been enabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER MaxConnectionRate
 Use this parameter to define the maximum number of connections allowed from a single IP address in the defined "RateInterval" parameter. Setting a value of 0 allows an unlimited connection rate; otherwise, set a value between 1 and 100000.

 .PARAMETER MaxConnections
 Use this parameter to define the maximum number of connections to allow for a single IP address. Setting a value of 0 will allow unlimited simultaneous connections; otherwise set a value between 1 and 100000.

 .PARAMETER MinConnections
 Use this parameter to define the lowest possible number of connections per IP address before applying throttling restrictions. Setting a value of 0 allows unlimited simultaneous connections; otherwise, set a value between 1 and 1000.

 .PARAMETER RateInterval
 Use this parameter to define the frequency (in seconds) at which the "maxConnectionRate" parameter is assessed. For example, a "maxConnectionRate" value of 30 with a "rateInterval" of 60 would allow a maximum of 30 connections per minute for a single IP address. This value must be between 1 and 3600.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-ConnectionThrottling -CloudLBID 116351 -Region ord
 This example shows how to enable connection logging on a CLB in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Throttle_Connections-d1e4057.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancerThrottleURI"

        if ($ChangeMaxConnectionRate) {
    
            $Body = '{
    "connectionThrottle":{
        "maxConnectionRate": '+$MaxConnectionRate+'
    }
}'

        }

        elseif ($ChangeMaxConnections) {

            $Body = '{
    "connectionThrottle":{
        "maxConnections": '+$MaxConnections+'
    }
}'

        }

        elseif ($ChangeMinConnections) {

            $Body = '{
    "connectionThrottle":{
        "minConnections": '+$MinConnections+'
    }
}'

        }

        elseif ($ChangeRateInterval) {
            
            $Body = '{
    "connectionThrottle":{
        "rateInterval": '+$RateInterval+'
    }
}'

        }

## Using conditional logic to route requests to the relevant API per data center
if ($RegionList -contains $Region) {    
    
    ## Retrieving authentication token
    Get-AuthToken

    ## Making the call to the API
    Update-APIRequest $URI $Body

    ## Since the response body is JSON, we can use dot notation to show the information needed without further parsing.
     
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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Update-ConnectionThrottling -CloudLBID 116351 -ChangeMaxConnections -MaxConnections 150 -Region ord
 This example shows how to update the MaxConnections value of a CLB in the ORD region

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Throttle_Connections-d1e4057.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersThrottleURI"

 if ($RegionList -contains $Region) {

        ## Retrieving authentication token
        Get-AuthToken
        
        Remove-APIRequest $URI

        Write-Host "Connection throttling has now been disabled. Please wait 10 seconds to see an updated detail listing:"

        Sleep 10

        Get-CloudLoadBalancerDetails $CloudLBID $Region
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-ConnectionThrottling -CloudLBID 116351 -Region ord
 This example shows how to disable connection throttling on a CLB in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Throttle_Connections-d1e4057.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersHealthURI"

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
    Get-AuthToken
        
        Get-APIRequest $URI

            if ($Response.healthMonitor.type -ne "CONNECT" -and $Response.healthMonitor.type -ne "HTTP") {

                    Write-Host "This load balancer does not currently have any health monitors configured." -ForegroundColor Red

                }

                elseif ($Response.healthMonitor.type -eq "CONNECT") {

                    $Response.healthMonitor | ft $HealthMonitorConnectTable -AutoSize

                }

                elseif ($Response.healthMonitor.type -eq "HTTP") {

                    $Response.healthMonitor | ft $HealthMonitorHTTPTable -AutoSize

                }

                elseif ($Response.healthMonitor.type -eq "HTTPS") {

                    $Response.healthMonitor | ft $HealthMonitorHTTPTable -AutoSize

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
 Use this parameter to define the ID of the load balancer you are about to query. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-HealthMonitor -CloudLBID 9956 -Region ord
 This example shows how to get the status and configuration of a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_Health-d1e3434.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersHealthURI"

        if ($WatchConnections) {

            $Body = '{
    "healthMonitor":{
        "type": "CONNECT",
        "delay": '+$MonitorDelay+',
        "timeout": '+$MonitorTimeout+',
        "attemptsBeforeDeactivation": '+$MonitorFailureAttempts+'
    }
}'

        }

        elseif ($WatchHTTP) {

            $Body = '{
    "healthMonitor":{
        "type": "HTTP",
        "delay": '+$MonitorDelay+',
        "timeout": '+$MonitorTimeout+',
        "attemptsBeforeDeactivation": '+$MonitorFailureAttempts+',
        "path": "'+$MonitorHTTPPath+'",
        "statusRegex": "'+$MonitorStatusRegex+'",
        "bodyRegex": "'+$MonitorBodyRegex+'",
        "hostHeader": "'+$MonitorHostHeader+'"
    }
}'

        }

        elseif ($WatchHTTPS) {

            $Body = '{
    "healthMonitor":{
        "type": "HTTPS",
        "delay": '+$MonitorDelay+',
        "timeout": '+$MonitorTimeout+',
        "attemptsBeforeDeactivation": '+$MonitorFailureAttempts+',
        "path": "'+$MonitorHTTPPath+'",
        "statusRegex": "'+$MonitorStatusRegex+'",
        "bodyRegex": "'+$MonitorBodyRegex+'",
        "hostHeader": "'+$MonitorHostHeader+'"
    }
}'

        }

 if ($RegionList -contains $Region) {
        
    ## Retrieving authentication token
    Get-AuthToken
        
    Update-APIRequest $URI $Body

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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_Connections-d1e3536.html

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_HTTP_and_HTTPS-d1e3635.html

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
        Get-URI cloudLoadBalancers $Region
        $URI = "$URL$loadbalancersHealthURI"

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Remove-APIRequest $URI

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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-HealthMonitor -CloudLBID 9956 -Region ord
 This example shows how to remove health mointoring from a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/Monitor_Health-d1e3434.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersCachingURI"

    ## Set JSON body variable
    $Body = '{
   "contentCaching":{
      "enabled":true
   }
}'

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Update-APIRequest $URI $Body

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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-ContentCaching -CloudLBID 9956 -Region ord
 This example shows how to enable content caching for a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/ContentCaching-d1e3358.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersCachingURI"

    ## Set XML body variable
    $Body = '{
   "contentCaching":{
      "enabled":true
   }
}'

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Update-APIRequest $URI $Body

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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-ContentCaching -CloudLBID 9956 -Region ord
 This example shows how to remove content caching from a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/ContentCaching-d1e3358.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersSSLURI"

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Get-APIRequest $URI

        if ($Response -eq "") {
            Write-Host "This LB does not currently have SSL termination enabled"
        }

        else {
        $Response.sslTermination | ft $SSLTable -Wrap
        }
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
 Use this parameter to define the ID of the load balancer you are about to query. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Get-SSLTermination -CloudLBID 555 -Region ord
 This example shows how to retrieve the SSL termination settings from a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersSSLURI"

    if (($enabled) -and ($SecureTrafficOnly)) {
        
        $Body = '{
    "sslTermination":{
        "certificate":"'+$Certificate+'",
        "enabled":true,
        "secureTrafficOnly":true,
        "privatekey":"'+$PrivateKey+'",
        "intermediateCertificate":"'+$IntermediateCertificate+'",
        "securePort":'+$SSLPort+'
    }
}'
       
    }

    elseif (($enabled) -and (!$SecureTrafficOnly)) {

        $Body = '{
    "sslTermination":{
        "certificate":"'+$Certificate+'",
        "enabled":true,
        "secureTrafficOnly":false,
        "privatekey":"'+$PrivateKey+'",
        "intermediateCertificate":"'+$IntermediateCertificate+'",
        "securePort":'+$SSLPort+'
    }
}'
       
    }

    elseif ((!$enabled) -and ($SecureTrafficOnly)) {
        
        $Body = '{
    "sslTermination":{
        "certificate":"'+$Certificate+'",
        "enabled":false,
        "secureTrafficOnly":true,
        "privatekey":"'+$PrivateKey+'",
        "intermediateCertificate":"'+$IntermediateCertificate+'",
        "securePort":'+$SSLPort+'
    }
}'
       
    }

    elseif ((!$enabled) -and (!$SecureTrafficOnly)) {

        $Body = '{
    "sslTermination":{
        "certificate":"'+$Certificate+'",
        "enabled":false,
        "secureTrafficOnly":false,
        "privatekey":"'+$PrivateKey+'",
        "intermediateCertificate":"'+$IntermediateCertificate+'",
        "securePort":'+$SSLPort+'
    }
}'
       
    }




 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Update-APIRequest $URI $Body | Out-Null
        
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Add-SSLTermination -CloudLBID 116351 -SSLPort 443 -PrivateKey "PrivateKeyGoesHereInQuotes" -Certificate "CertificateGoesHereInQuotes" -Enabled -Region ORD
 This example shows how to add SSL termination to a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersSSLURI"

    if ($EnableSSLTermination) {
        
            $Body = '{
    "sslTermination":{
        "enabled":true
    }
}'
       
    }

    elseif ($DisableSSLTermination) {
        
            $Body = '{
    "sslTermination":{
        "enabled":false
    }
}'
       
    }

    elseif ($EnableSecureTrafficOnly) {
        
            $Body = '{
    "sslTermination":{
        "secureTrafficOnly":true
    }
}'
       
    }

    elseif ($DisableSecureTrafficOnly) {
        
            $Body = '{
    "sslTermination":{
        "secureTrafficOnly":false
    }
}'
       
    }

    elseif ($UpdateSSLPort) {
        
            $Body = '{
    "sslTermination":{
        "securePort":'+$SSLPort+'
    }
}'
       
    }


 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Update-APIRequest $URI $Body | Out-Null
        
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

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
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Update-SSLTermination -CloudLBID 116351 -DisableSSLTrafficOnly -Region ORD
 This example shows how to update the SSL termination settings of a cloud load balancer in the ORD region. This example would configure the load balancer to accept both non-secure and secure traffic.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

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
    Get-URI cloudLoadBalancers $Region
    $URI = "$URL$loadbalancersSSLURI"

 if ($RegionList -contains $Region) {
        
        ## Retrieving authentication token
        Get-AuthToken
        
        Remove-APIRequest $URI
        
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
 Use this parameter to define the ID of the load balancer you are about to modify. If you need to find this information, you can run the "Get-CloudLoadBalancers" cmdlet for a complete listing of load balancers.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-SSLTermination -CloudLBID 555 -Region ord
 This example shows how to remove the SSL termination settings from a cloud load balancer in the ORD region.

 .LINK
 http://docs.rackspace.com/loadbalancers/api/v1.0/clb-devguide/content/SSLTermination-d1e2479.html

#>
}

##CLOUD FILES BITS
function UrlEncode {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$toEncode
        )
    return [System.Web.HttpUtility]::UrlEncode($toEncode)
<#
 .SYNOPSIS
 URL Encodes the string passed in.

 .DESCRIPTION
 See synopsis.

 .PARAMETER toEncode
 This is the string that will be URL Encoded and returned.

 .EXAMPLE
 PS C:\Users\Administrator> UrlEncode -toEncode "foo<ness"
 This example shows how to url encode the string foo<ness.  The response is foo%3cness.

#>
}

function Get-CloudFilesEndpointForRegion {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl
        )
    
    Get-AuthToken

    $rackspaceUrl = ""
    foreach ($service in $token.access.serviceCatalog.service)
    {
        if ($service.name -eq "cloudFiles")
        {
            foreach ($endpoint in $service.endpoint)
            {
                if ($endpoint.region -eq $Region)
                {
                    if ($GetInternalUrl)
                    {
                        $rackspaceUrl = $endpoint.internalURL
                    }
                    else
                    {
                        $rackspaceUrl = $endpoint.publicURL
                    }
                }
            }
        }
    }
    return $rackspaceUrl
<#
 .SYNOPSIS
 The Get-CloudFilesEndpointForRegion cmdlet will return the specified URL for your Cloud File account.  This URL can be used for Rackspace REST based requests.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudFilesEndpointForRegion -Region ord -GetInternalUrl $False
 This example shows how to get your ORD region's public URL for cloud files.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Authentication-d1e639.html

#>
}

function Get-CloudFilesStatistics {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl
        )
    
    Get-AuthToken

    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $resp = Invoke-WebRequest -Uri $rackspaceUrl -Headers $HeaderDictionary -Method Head
    $result = New-Object -TypeName PSObject
    $result | Add-Member -MemberType NoteProperty -Name ObjectCount -Value ([int]$resp.Headers["X-Account-Object-Count"])
    $result | Add-Member -MemberType NoteProperty -Name BytesUsed -Value ([long]$resp.Headers["X-Account-Bytes-Used"])
    $result | Add-Member -MemberType NoteProperty -Name ContainerCount -Value ([int]$resp.Headers["X-Account-Container-Count"])
    return $result
<#
 .SYNOPSIS
 The Get-CloudFilesStatistics cmdlet will return statistical information for all of your objects stored on Cloud Files in a given region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudFilesStatistics -Region ord -GetInternalUrl $False
 This example shows how to query the ORD region through Rackspace's public interface for the cloud files statistics.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/View_Account_Details-d1e108.html

#>
}

function Get-CloudFilesContainerList {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl
        )
    
    Get-AuthToken

    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $rackspaceUrl += "?format=json"
    $response = @()
    $currentResponse = @()
    $markerUrl = ""
    do {
        if ($currentResponse.Length -eq 10000)
        {
            $markerUrl = $rackspaceUrl + "&marker=" + (UrlEncode $currentResponse[9999].name)
        }
        else
        {
            $markerUrl = $rackspaceUrl
        }
        $currentResponse = Invoke-RestMethod -Uri $markerUrl -Headers $HeaderDictionary -Method Get
        $response += $currentResponse
    } until ($currentResponse.Length -lt 10000)

    return $response
<#
 .SYNOPSIS
 The Get-CloudFilesContainerList cmdlet will return statistical information for each of your containers in the Cloud Files in a given region.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudFilesContainerList -Region ord -GetInternalUrl $False
 This example shows how to query the ORD region through Rackspace's public interface for the cloud files containers.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/List_containers-d1e121.html

#>
}

function Get-CloudFilesContainerListContaining {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$ContainsString
        )

    $containers = Get-CloudFilesContainerList $Region $GetInternalUrl
    $resp = @()
    foreach ($container in $containers)
    {
        if ($container.name.ToLower().Contains($ContainsString))
        {
            $resp += $container
        }
    }
    return $resp
<#
 .SYNOPSIS
 The Get-CloudFilesContainerListContaining cmdlet will return statistical information for each of your containers in the Cloud Files in a given region
 that contains the text passed in the parameter $ContainsString

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER ContainsString
 Use this parameter to filter the containers to only return the containers that contain this string. This is case insensitive.

 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudFilesContainerListContaining -Region ord -ContainsString "movies" -GetInternalUrl $False
 This example shows how to query the ORD region through Rackspace's public interface for the cloud files containers.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/List_containers-d1e121.html

#>
}

function Get-CloudFilesObjectList {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$ContainerName,
        [Parameter(Position=3,Mandatory=$false)]
        [string]$Delimiter,
        [Parameter(Position=4,Mandatory=$false)]
        [string]$Prefix
        )

    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $rackspaceUrl += "/" + $ContainerName + "?format=json"
    if (($Delimiter.Length -gt 0) -or ($Prefix.Length -gt 0))
    {
        if ($Delimiter.Length -gt 0)
        {
            $rackspaceUrl += "&delimiter=" + $Delimiter
        }
        if ($Prefix.Length -gt 0)
        {
            $rackspaceUrl += "&prefix=" + $Prefix
        }
    }
    
    $resp = Invoke-RestMethod -Uri $rackspaceUrl -Headers $HeaderDictionary -Method Get
    return $resp
 <#
 .SYNOPSIS
 The Get-CloudFilesObjectList cmdlet will return a list of objects with the properties of hash, last_modified, bytes, name, and content_type for each object
 in the container specified by $ContainerName and satisfying the $Delimiter and the $Prefix requirements.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER ContainerName
 Use this parameter to indicate the container containing the objects you wish to list.
 
 .PARAMETER Delimiter
 Use this parameter to indicate the character that is your delimiter so that a "directory" behaves as a container.

 .PARAMETER Prefix
 Use this parameter to filter out all objects that do not begin with the value passed in the $Prefix.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudFilesObjectList -Region ord -GetInternalUrl $False -ContainerName "movies"
 This example shows how to query the ORD region through Rackspace's public interface for the list of objects in the cloud files container named "movies".

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Pseudo-Hierarchical_Folders_Directories-d1e1580.html

#>
}

function Get-DoesCloudFilesContainerExist {

    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$ContainerName
        )

    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $rackspaceUrl += "/" + $ContainerName
    
    Try
    {
        $resp = Invoke-WebRequest -Uri $rackspaceUrl -Headers $HeaderDictionary -Method Head
        return ($resp.StatusCode -eq 204)
    }
    Catch [system.exception]
    {
        return $False
    }
<#
 .SYNOPSIS
 The Get-DoesCloudFilesContainerExist cmdlet will return $True if the container name exists or $False if the container name does not exist.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER ContainerName
 Use this parameter to indicate the container you wish to verify exists.

 .EXAMPLE
 PS C:\Users\Administrator> Get-DoesCloudFilesContainerExist -Region ord -GetInternalUrl $False -ContainerName "movies"
 This example shows how to query the ORD region through Rackspace's public interface for the existence of the cloud files container named "movies".

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/View-Container_Info-d1e1285.html

#>
}

function Add-CloudFilesContainer {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$ContainerName
        )
    
    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $rackspaceUrl += "/" + $ContainerName

    (Invoke-WebRequest -Uri $rackspaceUrl -Headers $HeaderDictionary -Method Put)
<#
 .SYNOPSIS
 The Add-CloudFilesContainer cmdlet will create a new empty container.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER ContainerName
 Use this parameter to indicate the container you wish to create.

 .EXAMPLE
 PS C:\Users\Administrator> Add-CloudFilesContainer -Region ord -GetInternalUrl $False -ContainerName "movies"
 This example shows how to create a new container named "movies" in the ORD region through Rackspace's public interface.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Create_Container-d1e1694.html

#>
}

function Remove-CloudFilesContainer {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$ContainerName
        )
    
    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $rackspaceUrl += "/" + $ContainerName

    Invoke-WebRequest -Uri $rackspaceUrl -Headers $HeaderDictionary -Method Delete
<#
 .SYNOPSIS
 The Remove-CloudFilesContainer cmdlet will attempt to delete a container. The container must be empty.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER ContainerName
 Use this parameter to indicate the container you wish to delete.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudFilesContainer -Region ord -GetInternalUrl $False -ContainerName "movies"
 This example shows how to delete a container named "movies" in the ORD region through Rackspace's public interface.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Delete_Container-d1e1765.html

#>
}

function Get-CloudFilesObject {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$ContainerName,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$ObjectName
        )
    
    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $rackspaceUrl += "/" + $ContainerName + "/" + $ObjectName

    return Invoke-RestMethod -Uri $rackspaceUrl -Headers $HeaderDictionary -Method Get
<#
 .SYNOPSIS
 The Get-CloudFilesObject cmdlet will attempt to download the contents of the cloud files object.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER ContainerName
 Use this parameter to indicate the container the object is in.

 .PARAMETER ObjectName
 Use this parameter to indicate the name of the object you wish to acquire.

 .EXAMPLE
 PS C:\Users\Administrator> Get-CloudFilesObject -Region ord -GetInternalUrl $False -ContainerName "movies" -ObjectName "TopGun.avi"
 This example shows how to download a file named "TopGun.avi" from a container named "movies" in the ORD region through Rackspace's public interface.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Retrieve_Object-d1e4301.html

#>
}

function Remove-CloudFilesObject {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$ContainerName,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$ObjectName
        )
    
    $rackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    $rackspaceUrl += "/" + $ContainerName + "/" + $ObjectName
    
    Invoke-WebRequest -Uri $rackspaceUrl -Headers $HeaderDictionary -Method Delete
<#
 .SYNOPSIS
 The Remove-CloudFilesObject cmdlet will attempt to delete the cloud files object.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER ContainerName
 Use this parameter to indicate the container the object is in.

 .PARAMETER ObjectName
 Use this parameter to indicate the name of the object you wish to delete.

 .EXAMPLE
 PS C:\Users\Administrator> Remove-CloudFilesObject -Region ord -GetInternalUrl $False -ContainerName "movies" -ObjectName "TopGun.avi"
 This example shows how to delete a file named "TopGun.avi" from a container named "movies" in the ORD region through Rackspace's public interface.

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Retrieve_Object-d1e4301.html

#>
}

function Copy-CloudFilesObject {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$SourceContainerName,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$SourceObjectName,
        [Parameter(Position=4,Mandatory=$true)]
        [string]$DestinationContainerName,
        [Parameter(Position=5,Mandatory=$true)]
        [string]$DestinationObjectName,
        [Parameter(Position=6,Mandatory=$false)]
        [string]$RackspaceUrl
        )
    
    $destinationPath = "/" + $DestinationContainerName + "/" + $DestinationObjectName
    $sourcePath = "/" + $SourceContainerName + "/" + $SourceObjectName
    if ($RackspaceUrl.Length -lt 1)
    {
        $RackspaceUrl = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl
    }
    $rackspaceSourceUrl = $RackspaceUrl + $sourcePath

    $webRequest = [System.Net.WebRequest]::Create( $rackspaceSourceUrl )
    $webRequest.PreAuthenticate = $true
    $webRequest.Method = "COPY"
    $webRequest.Headers.Add("Destination", $destinationPath)
    $webRequest.Headers.Add("X-Auth-Token", $HeaderDictionary["X-Auth-Token"])
    $resp = $webRequest.GetResponse()

    return $resp
<#
 .SYNOPSIS
 The Copy-CloudFilesObject cmdlet will attempt to copy the cloud files object.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER SourceContainerName
 Use this parameter to indicate the container the source object is in.

 .PARAMETER SourceObjectName
 Use this parameter to indicate the name of the object you wish to copy.

 .PARAMETER DestinationContainerName
 Use this parameter to indicate the destination's container.

 .PARAMETER DestinationObjectName
 Use this parameter to indicate the name of the object you wish to copy to.

 .PARAMETER RackspaceUrl
 Use this parameter to indicate the base URL to use when communicating with Rackspace. This is to prevent a possibly unnecessary call to Rackspace for URL information if it's already available.

 .EXAMPLE
 PS C:\Users\Administrator> Copy-CloudFilesObject -Region ord -GetInternalUrl $False -SourceContainerName "movies" -SourceObjectName "TopGun.avi" -DestinationContainerName "Top5Movies" -DestinationObjectName "Number1.avi"
 This example shows how to copy a file named "TopGun.avi" from a container named "movies" in the ORD region through Rackspace's public interface to an object named "Number1.avi" in a container named "Top5Movies".

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Copy_Object-d1e2241.html

#>
}

function Copy-CloudFilesContainer {
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Region,
        [Parameter(Position=1,Mandatory=$true)]
        [switch]$GetInternalUrl,
        [Parameter(Position=2,Mandatory=$true)]
        [string]$SourceContainerName,
        [Parameter(Position=3,Mandatory=$true)]
        [string]$DestinationContainerName
        )

    $url = Get-CloudFilesEndpointForRegion $Region $GetInternalUrl

    $sourceObjects = Get-CloudFilesObjectList $Region $GetInternalUrl -ContainerName $SourceContainerName

    if (!(Get-DoesCloudFilesContainerExist $Region $GetInternalUrl $DestinationContainerName))
    {
        Add-CloudFilesContainer $Region $GetInternalUrl $DestinationContainerName
    }

    foreach ($sourceObject in $sourceObjects)
    {
        Copy-CloudFilesObject $Region $GetInternalUrl $SourceContainerName $sourceObject.name $DestinationContainerName $sourceObject.name $url
    }
<#
 .SYNOPSIS
 The Copy-CloudFilesContainer cmdlet will attempt to copy all cloud files object in a container to another container. All metadata and object names are preserved.

 .DESCRIPTION
 See synopsis.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).
 
 .PARAMETER GetInternalUrl
 Use this parameter to indicate whether the URL returned should be the publically accessible URL or the Rackspace internal URL to possibly save on usage costs.

 .PARAMETER SourceContainerName
 Use this parameter to indicate the container the source objects are in.

 .PARAMETER DestinationContainerName
 Use this parameter to indicate the destination container.

 .EXAMPLE
 PS C:\Users\Administrator> Copy-CloudFilesContainer -Region ord -GetInternalUrl $False -SourceContainerName "movies" "TopGun.avi" -DestinationContainerName "AllMovies"
 This example shows how to copy all objects from a container named "movies" in the ORD region through Rackspace's public interface to a container named "AllMovies".

 .LINK
 http://docs.rackspace.com/files/api/v1/cf-devguide/content/Copy_Object-d1e2241.html

#>
}
