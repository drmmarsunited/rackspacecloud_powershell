#
# Functions for interacting with cloud monitoring zones
#

function Add-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [Object[]] $criticalState,
        [Parameter(Mandatory=$false)]
        [Object[]] $warningState,
        [Parameter(Mandatory=$false)]
        [Object[]] $okState,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-IdentityMonitoringURI) + "/notification_plans" )
    Set-Variable -Name jsonBody -Value $null

    if($metadata) {
        $metaDataType = $metadata.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $metaDataType) ) {
            Write-Host "The data type passed is not of type Array or Hashtable."
            return
        }
    }

    $jsonBody = (Convert-CloudMonitoringNotificationPlan -label $label -criticalState $criticalState -warningState $warningState -okState $okState -metadata $metaData)

    Write-Debug "URI: `"$notificationPlanUri`""
    Write-Debug "Body: `n$jsonBody"
    try {
        Invoke-RestMethod -URI $notificationPlanUri -Body $jsonBody -ContentType application/json -Headers (Get-HeaderDictionary) -Method POST
    } catch {
        Write-Host "Generic Error here"
    }
<#
    .SYNOPSIS
    Adds a notification plan

    .DESCRIPTION
    See synopsis.

    .PARAMETER label
    Friendly name for the notification plan.

    .PARAMETER criticalState
    The notification list to send to when the state is CRITICAL.

    .PARAMETER warningState
    The notification list to send to when the state is WARNING.

    .PARAMETER okState
    The notification list to send to when the state is OK.

    .PARAMETER metadata
    Arbitrary key/value pairs. Supports Hashtables and Arrays.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notification-plans.html#POST_createNotifyPlan_notification_plans_service-notification-plans
#>
}

function Convert-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [Object[]] $criticalState,
        [Parameter(Mandatory=$false)]
        [Object[]] $warningState,
        [Parameter(Mandatory=$false)]
        [Object[]] $okState,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    $body = New-Object -TypeName PSObject

    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($criticalState) { $body | Add-Member -MemberType NoteProperty -Name critical_state -Value $criticalState }
    if($warningState) { $body | Add-Member -MemberType NoteProperty -Name warning_state -Value $warningState }
    if($okState) { $body | Add-Member -MemberType NoteProperty -Name ok_state -Value $okState }
    if($metadata) { $body | Add-Member -MemberType NoteProperty -Name metadata -Value $metadata }

    return (ConvertTo-Json $body)
<#
    .SYNOPSIS
    Converts the data to a JSON body for use within notificaton plan operations.

    .DESCRIPTION
    See synopsis.

    .PARAMETER label
    Friendly name for the notification plan.

    .PARAMETER criticalState
    The notification list to send to when the state is CRITICAL.

    .PARAMETER warningState
    The notification list to send to when the state is WARNING.

    .PARAMETER okState
    The notification list to send to when the state is OK.

    .PARAMETER metadata
    Arbitrary key/value pairs. Supports Hashtables and Arrays.
#>
}

function Get-CloudMonitoringNotificationPlan {
    param(
        [Parameter(Mandatory=$false)]
        [string []] $notificationPlanId
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-IdentityMonitoringURI) + "/notification_plans" )
    Set-Variable -Name notificationPlanArray -Value $null
    Set-Variable -Name result -Value $null

    if($notificationPlanId) { 
        $notificationPlanArray = [System.Collections.Generic.List[System.Object]] $notificationPlanId
        $notificationPlanUri += "?$($notificationPlanArray.Item(0))" 
        $notificationPlanArray.RemoveAt(0)

        foreach($n in $notificationPlanArray) {
            $notificationPlanUri += "&$n"
        }
    }

    Write-Debug "URI: `"$notificationPlanUri`""
    try {
        $result = (Invoke-RestMethod -URI $notificationPlanUri -Headers (Get-HeaderDictionary))
    } catch {
        Write-Host "Generic Error Here"
    }

    if($notificationPlanId.Length -gt 0) {$result = $result.values}
    return $result
<#
    .SYNOPSIS
    Retrieves the specified notification plan(s)

    .DESCRIPTION
    Parses the passed in IDs and returns information on those plan(s).

    .PARAMETER notificationPlanId
    The notification plan(s) to retrieve further information on. Removing this argument
    is the same as getting all notification plans.

    .EXAMPLE
    Get-CloudMonitoringNotificationPlans
    Gets all notification plans.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notification-plans.html#GET_listNotifyPlan_notification_plans_service-notification-plans
#>
}

function Get-CloudMonitoringNotificationPlans {
    param ()

    return (Get-CloudMonitoringNotificationPlan).values
<#
    .SYNOPSIS
    Retrieves all notification plans.

    .DESCRIPTION
    See synopsis.

    .EXAMPLE
    Get-CloudMonitoringNotificationPlans
    Gets all notification plans.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notification-plans.html#GET_listNotifyPlan_notification_plans_service-notification-plans
#>
}

function Remove-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationPlanId
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-IdentityMonitoringURI) + "/notification_plans/$notificationPlanId" )

    Write-Debug "URI: `"$notificationPlanUri`""
    try {
        Invoke-RestMethod -URI $notificationPlanUri -Headers (Get-HeaderDictionary) -Method DELETE
    } catch {
        Write-Host "Generic Error here"
    }

<#
    .SYNOPSIS
    Deletes a notification plan.

    .DESCRIPTION
    See synopsis.

    .EXAMPLE
    Delete-CloudMonitoringNotificationPlan -notificationPlanId <notificationPlanId>
    Deletes the notification plan passed in.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notification-plans.html#DELETE_deleteNotifyPlan_notification_plans__notificationPlanId__service-notification-plans
#>
}

function Update-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationPlanId,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [Object[]] $criticalState,
        [Parameter(Mandatory=$false)]
        [Object[]] $warningState,
        [Parameter(Mandatory=$false)]
        [Object[]] $okState,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-IdentityMonitoringURI) + "/notification_plans/$notificationPlanId" )
    Set-Variable -Name jsonBody -Value $null

    if($metadata) {
        $metaDataType = $metadata.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $metaDataType) ) {
            Write-Host "The data type passed is not of type Array or Hashtable."
            return
        }
    }

    $jsonBody = (Convert-CloudMonitoringNotificationPlan -label $label -criticalState $criticalState -warningState $warningState -okState $okState -metadata $metaData)

    Write-Debug "URI: `"$notificationPlanUri`""
    Write-Debug "Body: `n$jsonBody"
    try {
        Invoke-RestMethod -URI $notificationPlanUri -Body $jsonBody -ContentType application/json -Headers (Get-HeaderDictionary) -Method PUT
    } catch {
        Write-Host "Generic Error here"
    }
<#
    .SYNOPSIS
    Updates a notification plan.

    .DESCRIPTION
    See synopsis.

    .PARAMETER label
    Friendly name for the notification plan.

    .PARAMETER criticalState
    The notification list to send to when the state is CRITICAL.

    .PARAMETER warningState
    The notification list to send to when the state is WARNING.

    .PARAMETER okState
    The notification list to send to when the state is OK.

    .PARAMETER metadata
    Arbitrary key/value pairs. Supports Hashtables and Arrays.

    .EXAMPLE
    Update-CloudMonitoringNotificationPlan -notificationPlanId <notificationPlanId>
    This example does nothing as no useful data was passed in to update.

    .EXAMPLE
    Update-CloudMonitoringNotificationPlan -notificationPlanId <notificationPlanId> -label <label>
    Updates the notificaton plan with the specified label.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notification-plans.html#PUT_updateNotifyPlan_notification_plans__notificationPlanId__service-notification-plans
#>
}

