#
# Functions for interacting with cloud monitoring
#

function Get-CloudMonitoringZone {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [string] zoneId
    )

    try {
        return (Get-CloudMonitoringZoneHelper -zoneId $zoneId)
    } catch {
        Write-Error 'Generic error message'
    }
    
<#
    .SYNOPSIS
    Get the details about a specific monitoring zone.

    .DESCRIPTION
    See synopsis.

    .PARAMETER zoneId
    Use this parameter to specify what zone you want details from.

    .EXAMPLE
    Get-CloudMonitoringZone -zoneId mzdfw
    Returns information on the DFW monitoring zone (mz)

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-monitoring-zones.html#GET_getMonitorZone_monitoring_zones__monitoringZoneId__service-monitoring-zones
#>
}

function Get-CloudMonitoringZones {
    param()

    try {
        return (Get-CloudMonitoringZoneHelper)
    } catch { 
        Write-Error 'Generic Error message'
    }

<#
    .SYNOPSIS
    Get the details of all the available monitoring zones

    .DESCRIPTION
    See synopsis.

    .EXAMPLE
    Get-CloudMonitoringZones
    Returns information on all monitoring zones available

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-monitoring-zones.html#GET_listMonitorZone_monitoring_zones_service-monitoring-zones
#>
}

function Get-CloudMonitoringZoneHelper {
    param (
        [Parameter (Position=0, Mandatory=$false)]
        [string] zoneId = $null
    )

    Set-Variable -Name cloudMonitoringURI -Value ((Get-IdentityMonitoringURI) + "/monitoring_zones")
    Set-Variable -Name result -Value $null
    
    if($zoneId) { $cloudMonitoringURI += '/' + $zoneId }
    
    Get-AccessToken | Out-Null
    $result = Invoke-RestMethod -URI $cloudMonitoringURI -Headers (Get-HeaderDictionary)

    if($zoneId) { return $result }
    return $result.values

<#
    .SYNOPSIS
    "Overloaded" helper supproting the Get-CloudMonitoringZone(s) functions.

    .DESCRIPTION
    Performs the actual token request and Rest-Method request and, based off the zoneId, 
    parses the and returns the $results for processing.

#>
}


function Trace-FromCloudMonitoringZone {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $zoneId,
        [Parameter (Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $target,
        [Parameter (Position=2, Mandatory=$false)]
        [ValidateSet("IPv4", "IPv6")]
        [string] $resolver = "IPv4"
    )

    Set-Variable -Name cloudMonitoringURI -Value ((Get-IdentityMonitoringURI) + "/monitoring_zones/$zoneId/traceroute")
    Set-Variable -Name traceRequestBody -Value `
        @{
            target="$target" 
            target_resolver="$resolver" 
        }
    
    $traceRequestBody = (ConvertTo-Json $traceRequestBody)

    Get-AccessToken |Out-Null

    try {
        Invoke-RestMethod -Uri $cloudMonitoringURI -Body $traceRequestBody -Headers (Get-HeaderDictionary) -ContentType application/json -Method Post
    } catch {
        Write-Error "Generic Error message that needs to be fixed here"
    }

<#
    .SYNOPSIS
    Returns a JSON response of the trace to the target location.

    .DESCRIPTION
    The body of this function uses existing authentication functions and builds the necessary Powershell 
    RestMethod request to trace from the monitoring zone to the target location.
    
    .PARAMETER zoneId
    Use this parameter to specify what zone you want to trace from.

    .PARAMETER target
    The target to trace to.

    .PARAMETER resolver
    Specifies whether to use IPv4 or IPv6. IPv4 is default. 

    .EXAMPLE
    Trace-FromCloudMonitoringZone -zoneId mzdfw -Target "yoursite.com" -Resolver "IPv4"
    Returns the trace from the DFW monitoring zone (mz) to the address resolved as Google.com using an IPv4 trace.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-monitoring-zones.html#POST_tracerouteMonitorZone_monitoring_zones__monitoringZoneId__traceroute_service-monitoring-zones
#>
}