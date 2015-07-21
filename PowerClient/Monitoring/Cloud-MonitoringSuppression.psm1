#
# Functions for interacting with cloud monitoring suppressions
#

function Add-CloudMonitoringSuppression {
    param (
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [string[]] $alarms,
        [Parameter(Mandatory=$false)]
        [string[]] $checks,
        [Parameter(Mandatory=$false)]
        [string[]] $entities,
        [Parameter(Mandatory=$false)]
        [int32] $startTime,
        [Parameter(Mandatory=$false)]
        [int32] $endTime,
        [Parameter(Mandatory=$false)]
        [string[]] $notificationPlans
    )

    Set-Variable -Name suppressionUri -Value ((Get-IdentityMonitoringURI) + '/suppressions​')
    Set-Variable -Name suppressionBody -Value `
        (Convert-CloudMonitoringSuppression -label $label -alarms $alarms -checks $checks -entities $entities `
            -startTime $startTime -endTime $endTime -notificationPlans $notificationPlans)

    Write-Debug "URI: `"$suppressionUri`""
    Write-Debug "Suppression Body: $suppressionBody"
    try {
        Invoke-RestMethod -Uri $suppressionUri -Body $suppressionBody -Headers (Get-HeaderDictionary) -Method Post
    } catch {
        Write-Host "Generic Error Here"
    }
<#
    .SYNOPSIS
    Get the details about a specific monitoring zone.

    .DESCRIPTION
    See synopsis.

    .PARAMETER label
    A friendly label for a suppression.

    .PARAMETER alarms
    A list of alarm ids(e.g. "enFooBar:alAbc123") for determining notification suppression

    .PARAMETER checks
    A list of check ids(e.g. "enFooBar:chAbc123") for determining notification suppression.

    .PARAMETER entities
    A list of entity ids for determining notification suppression.
    
    .PARAMETER startTime
    The unix timestamp in milliseconds that the suppression will start. Specify 0 to use the current time.

    .PARAMETER endTime
    The unix timestamp in milliseconds that the suppression will end. Specify 0 to use the current time.
    
    .PARAMETER notificationPlans
     A list of notification plan ids for determining notification suppression.

    .EXAMPLE
    Add-CloudMonitoringSuppression
    Creates a suppression attached to nothing.

    .EXAMPLE
    Add-CloudMonitoringSuppression -label MySuppression -startTime 0 -endTime 1437433200000 -alarms alarm1Id,alarm2Id,alarm3Id
    Creates a supression that starts immediately and ends 2015-07-20 23:00:00 GMT for the specified alarms.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-suppressions.html#POST_createSuppression_suppressions_service-suppressions
#>
}

function Convert-CloudMonitoringSuppression {
    param (
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [string[]] $alarms,
        [Parameter(Mandatory=$false)]
        [string[]] $checks,
        [Parameter(Mandatory=$false)]
        [string[]] $entities,
        [Parameter(Mandatory=$false)]
        [int32] $startTime,
        [Parameter(Mandatory=$false)]
        [int32] $endTime,
        [Parameter(Mandatory=$false)]
        [string[]] $notificationPlans 	
    )

    $body = New-Object -TypeName PSObject

    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($alarms) { $body | Add-Member -MemberType NoteProperty -Name alarms -Value $alarms }
    if($checks) { $body | Add-Member -MemberType NoteProperty -Name checks -Value $checks }
    if($entities) { $body | Add-Member -MemberType NoteProperty -Name entities -Value $entities }
    if($startTime) { $body | Add-Member -MemberType NoteProperty -Name start_time -Value $startTime }
    if($endTime) { $body | Add-Member -MemberType NoteProperty -Name end_time -Value $endTime }
    if($notificationPlans) { $body | Add-Member -MemberType NoteProperty -Name notification_plans -Value $notificationPlans }

    return (ConvertTo-Json $body)

<#
    .SYNOPSIS
    Convert the specified information into a JSON object

    .DESCRIPTION
    See synopsis.

    .PARAMETER label
    A friendly label for a suppression.

    .PARAMETER alarms
    A list of alarm ids(e.g. "enFooBar:alAbc123") for determining notification suppression

    .PARAMETER checks
    A list of check ids(e.g. "enFooBar:chAbc123") for determining notification suppression.

    .PARAMETER entities
    A list of entity ids for determining notification suppression.
    
    .PARAMETER startTime
    The unix timestamp in milliseconds that the suppression will start. Specify 0 to use the current time.

    .PARAMETER endTime
    The unix timestamp in milliseconds that the suppression will end. Specify 0 to use the current time.
    
    .PARAMETER notificationPlans
     A list of notification plan ids for determining notification suppression.
#>
}

function Delete-CloudMonitoringSuppression {
    [Parameter(Mandatory=$true)]
    [string] $suppressionId

    Set-Variable -Name suppressionUri -Value ((Get-IdentityMonitoringURI) + "/suppressions​/$suppressionId")

    Write-Debug "URI: `"$suppressionUri`""
    try {
        Invoke-RestMethod -Uri $suppressionUri -Headers (Get-HeaderDictionary) -Method Delete
    } catch {
        Write-Host "Generic Error Here"
    }
<#
    .SYNOPSIS
    Deletes the suppression.

    .DESCRIPTION
    See synopsis.

    .PARAMETER $suppressionId
    The id of the suppression to delete.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-suppressions.html#DELETE_deleteSuppression_suppressions__suppressionId__service-suppressions
#>
}

function Get-CloudMonitoringSuppression {
    param (
        [Parameter(Mandatory=$false)]
        [string[]] $suppressionId,
    )

    Set-Variable -Name suppressionUri -Value ((Get-IdentityMonitoringURI) + '/suppressions​')
    Set-Variable -Name suppressionArray -Value $null
    Set-Variable -Name result -Value $null

    if($suppressionId) { 
        Write-Verbose "Additional suppressions ids found. Updating URI"
        $suppressionArray = [System.Collections.Generic.List[System.Object]] $suppressionId
        $suppressionUri += "?${suppressionArray.Item(0)}" 
        $suppressionArray.RemoveAt(0)

        foreach($s in $suppressionArray) {
            $suppressionUri += "&$s"
        }
    }

    Write-Debug "URI: `"$suppressionUri`""
    try {
        $result = (Invoke-RestMethod -Uri $suppressionUri -Headers (Get-HeaderDictionary))
    } catch {
        Write-Host "Generic Error Here"
    }

    if($suppressionId.Length -gt 1) {$result = $result.values}
    return $result
<#
    .SYNOPSIS
    Returns the suppressions based off the suppressionId(s) that are passed in.

    .DESCRIPTION
    Returns the suppressions based off the suppressionId(s) that are passed in. This function behaves the same way
    as Get-CloudMonitoringSuppressions if no data is passed in.

    .PARAMETER suppressionId
    A string, or array of strings, that filter which suppression(s) are displayed.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-suppressions.html#GET_listSuppressions_suppressions_service-suppressions
#>
}

function Get-CloudMonitoringSuppressionLogs {
    param ()

    Set-Variable -Name suppressionUri -Value ((Get-IdentityMonitoringURI) + '/suppression_logs')

    Write-Debug "URI: `"$suppressionUri`""
    try {
        Invoke-RestMethod -URI $suppressionUri -Headers (Get-HeaderDictionary)
    } catch {
        Write-Host "Generic Error Here"
    }
<#
    .SYNOPSIS
    Returns the logs genereated during the suppression window.

    .DESCRIPTION
    See Synopsis

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/suppression-logs.html#GET_getSuppressionLog_suppression_logs_suppression-logs
#>
}

function Get-CloudMonitoringSuppressions {
    param()

    return (Get-CloudMonitoringSuppression).values
<#
    .SYNOPSIS
    Returns all monitoring suppressions.

    .DESCRIPTION
    See synopsis.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-suppressions.html#GET_listSuppressions_suppressions_service-suppressions
#>
}

function Update-CloudMonitoringSuppression {
    param (
        [Parameter(Mandatory=$true)]
        [string] $suppressionId,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [string[]] $alarms,
        [Parameter(Mandatory=$false)]
        [string[]] $checks,
        [Parameter(Mandatory=$false)]
        [string[]] $entities,
        [Parameter(Mandatory=$false)]
        [int32] $startTime,
        [Parameter(Mandatory=$false)]
        [int32] $endTime,
        [Parameter(Mandatory=$false)]
        [string[]] $notification_plans 	
    )

    Set-Variable -Name suppressionUri -Value ((Get-IdentityMonitoringURI) + "/suppressions​/$suppressionId")
    Set-Variable -Name suppressionBody -Value `
        (Convert-CloudMonitoringSuppression -label $label -alarms $alarms -checks $checks -entities $entities `
            -startTime $startTime -endTime $endTime -notificationPlans $notificationPlans)

    Write-Debug "URI: `"$suppressionUri`""
    Write-Debug "Suppression Body: $suppressionBody"
    try {
        Invoke-RestMethod -Uri $suppressionUri -Body $suppressionBody -Headers (Get-HeaderDictionary) -Method Put
    } catch {
        Write-Host "Generic Error Here"
    }
<#
    .SYNOPSIS
    Updates the specified suppression with the information passed in.

    .DESCRIPTION
    See synopsis.

    .PARAMETER label
    A friendly label for a suppression.

    .PARAMETER alarms
    A list of alarm ids(e.g. "enFooBar:alAbc123") for determining notification suppression

    .PARAMETER checks
    A list of check ids(e.g. "enFooBar:chAbc123") for determining notification suppression.

    .PARAMETER entities
    A list of entity ids for determining notification suppression.
    
    .PARAMETER startTime
    The unix timestamp in milliseconds that the suppression will start. Specify 0 to use the current time.

    .PARAMETER endTime
    The unix timestamp in milliseconds that the suppression will end. Specify 0 to use the current time.
    
    .PARAMETER notificationPlans
     A list of notification plan ids for determining notification suppression.

     .EXAMPLE
     Update-CloudMonitoringSuppression -suppressionId $suppressionId
     This example does nothing (as no data is passed it to update)

     .EXAMPLE
     Update-CloudMonitoringSuppression -suppressionId $suppressionId -label MySupressionLabel
     This example updates the label of the suppression to "MySuppressionLabel"

     .LINK
     http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-suppressions.html#PUT_updateSuppression_suppressions__suppressionId__service-suppressions
#>
}