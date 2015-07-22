#
# Functions for interacting with cloud monitoring notifications
#

function Add-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [Object] $details,
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$true)]
        [ValidateSet("webhook", "email", "pagerduty", "sms", "managed", "technicalContactsEmail", "atomHopper")]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/notifications")

    #try {
        return (Private-AddCloudMonitoringNotification -notificationUri $notificationUri -details $details -label $label -type $type -metadata $metadata)
    #} catch {
    #    Write-Host "Generic Error message that needs to be fixed here"
    #}
<#
    .SYNOPSIS
    Adds a monitoring notification.

    .DESCRIPTION
    See synopsis. The link specified will have more details about the types of notifications.

    .PARAMETER details
    A hash of notification specific details based on the notification type.
    
    .PARAMETER label
    Friendly name for the notification.

    .PARAMETER type
    The notification type to send. Valid options are: webhook, email, pagerduty, sms, managed, technicalContactsEmail, atomHopper

    .PARAMETER metadata
    A hashtable with the metadata values

    .EXAMPLE
    Add-CloudMonitoringNotification -label "Sample Webhook" -details @{uri="https://webhook.sample.com/alert"} -type "webhook"
    Adds a webhook sample notification

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notifications.html#POST_createNotification_notifications_service-notifications
#>
}

function Convert-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$false)]
        [Object] $details,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    $body = New-Object -TypeName PSObject

    if($details) { $body | Add-Member -MemberType NoteProperty -Name details -Value $details }
    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($type) { $body | Add-Member -MemberType NoteProperty -Name type -Value $type }
    if($metadata) { $body | Add-Member -MemberType NoteProperty -Name metadata -Value $metadata }

    return (ConvertTo-Json $body)
<#
    .SYNOPSIS
    Converts the specified parameters to a consumable JSON.

    .DESCRIPTION
    See synopsis.

    .PARAMETER details
    A hash of notification specific details based on the notification type.
    
    .PARAMETER label
    Friendly name for the notification.

    .PARAMETER type
    The notification type to send. Valid options are: webhook, email, pagerduty, sms, managed, technicalContactsEmail, atomHopper

    .PARAMETER metadata
    A hashtable with the metadata values
#>
}

function Get-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$false)]
        [string[]] $notificationId
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + '/notifications')
    Set-Variable -Name notificationArray -Value $null
    Set-Variable -Name result -Value $null

    if($notificationId) { 
        $notificationArray = [System.Collections.Generic.List[System.Object]] $notificationId
        $notificationUri += "?${notificationArray.Item(0)}" 
        $notificationArray.RemoveAt(0)

        foreach($n in $notificationArray) {
            $notificationUri += "&$n"
        }
    }

    try {
        $result = (Invoke-RestMethod -URI $notificationUri -Headers (Get-HeaderDictionary))
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }

    if($notificationId.Length -gt 0) {$result = $result.values}
    return $result

<#
    .SYNOPSIS
    Returns information on the specific notification(s)

    .DESCRIPTION
    Returns information on the specific notification(s). If nothing is specified, then all notifications are returned.

    .PARAMETER notificationId
    The notification(s) to view.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notifications.html#GET_listNotifications_notifications_service-notifications
#>
}

function Get-CloudMonitoringNotifications {
    param ( )

    return (Get-CloudMonitoringNotification).values

<#
    .SYNOPSIS
    Returns information on all notifications.

    .DESCRIPTION
    See synopsis

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notifications.html#GET_listNotifications_notifications_service-notifications
#>
}

function Private-AddCloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationUri,
        [Parameter(Mandatory=$true)]
        [Object] $details,
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$true)]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name jsonBody -Value $null

    if($details) {
        $detailsDataType = $details.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $detailsDataType) ) {
            Write-Debug "Datatype seen: $detailsDataType"
            Write-Host "The data type passed in as details is not of type Array or Hashtable."
            return
        }
    }

    if($metadata) {
        $metaDataType = $metadata.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $metaDataType) ) {
            Write-Debug "Datatype seen: $detailsDataType"
            Write-Host "The data type passed is not of type Array or Hashtable."
            return
        }
    }

    $jsonBody = Convert-CloudMonitoringNotification -details $details -label $label -type $type -metadata $metadata

    Write-Debug "URI: `"$notificationUri`""
    Write-Debug "Body: `n$jsonBody"
    return (Invoke-RestMethod -URI $notificationUri -Body $jsonBody -ContentType application/json -Headers (Get-HeaderDictionary) -Method POST)
<#
    .SYNOPSIS
    Performs the actual work for adding/testing notifications.

    .DESCRIPTION
    See synopsis.

    .PARAMETER notificationUri
    The URI to invoke.

    .PARAMETER details
    A hash of notification specific details based on the notification type.
    
    .PARAMETER label
    Friendly name for the notification.

    .PARAMETER type
    The notification type to send. Valid options are: webhook, email, pagerduty, sms, managed, technicalContactsEmail, atomHopper

    .PARAMETER metadata
    A hashtable with the metadata values
#>
}

function Remove-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationId
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/notifications/$notificationId")
    
    try {
        Invoke-RestMethod -URI $notificationUri -Headers (Get-HeaderDictionary) -Method DELETE
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Deletes the notification

    .DESCRIPTION
    See synopsis.

    .PARAMETER notificationId
    The notification to delete.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notifications.html#DELETE_deleteNotification_notifications__notificationId__service-notifications
#>
}

function Test-AddCloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [Object] $details,
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$true)]
        [ValidateSet("webhook", "email", "pagerduty", "sms", "managed", "technicalContactsEmail", "atomHopper")]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/test-notification")

    try {
        return (Private-AddCloudMonitoringNotification -notificationUri $notificationUri -details $details -label $label -type $type -metadata $metadata)
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Test adds a monitoring notification.

    .DESCRIPTION
    See synopsis. The link specified will have more details about the types of notifications.

    .PARAMETER details
    A hash of notification specific details based on the notification type.
    
    .PARAMETER label
    Friendly name for the notification.

    .PARAMETER type
    The notification type to send. Valid options are: webhook, email, pagerduty, sms, managed, technicalContactsEmail, atomHopper

    .PARAMETER metadata
    A hashtable with the metadata values

    .EXAMPLE
    Test-AddCloudMonitoringNotification -label "Sample Webhook" -details @{uri="https://webhook.sample.com/alert"} -type "webhook"
    Adds a webhook sample notification

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notifications.html#POST_TestNotification_test-notification_service-notifications
#>
}

function Test-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationId
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/$notificationId/test")

    try {
        Invoke-RestMethod -URI $notificationUri -Headers (Get-HeaderDictionary)
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Tests an existing monitoring notification.

    .DESCRIPTION
    See synopsis.

    .PARAMETER notificationId
    The id of the notification to test.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notifications.html#POST_TestNotificationId_notifications__notificationId__test_service-notifications
#>
}

function Update-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationId,
        [Parameter(Mandatory=$false)]
        [string] $details,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [ValidateSet("webhook", "email", "pagerduty", "sms", "managed", "technicalContactsEmail", "atomHopper")]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/notifications/$notificationId")
    Set-Variable -Name jsonBody -Value $null

    if($metadata) {
        $metaDataType = $metadata.GetType()

        if($metaDataType.name -ne "Hashtable" -and $metaDataType.BaseType.Name -ne "Array") {
            Write-Host "The data type passed is not of type Array or Hashtable."
            return
        }
    }

    $jsonBody = Convert-CloudMonitoringNotification -details $details -label $label -type $type -metadata $metadata

    try {
        Invoke-RestMethod -URI $notificationUri -Body $jsonBody -ContentType application/json -Headers (Get-HeaderDictionary) -Method PUT
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Updates an existing monitoring notification.

    .DESCRIPTION
    See synopsis. The link specified will have more details about the types of notifications.

    .PARAMETER notificationId
    The id of the notification to update.

    .PARAMETER details
    A hash of notification specific details based on the notification type.
    
    .PARAMETER label
    Friendly name for the notification.

    .PARAMETER type
    The notification type to send. Valid options are: webhook, email, pagerduty, sms, managed, technicalContactsEmail, atomHopper

    .PARAMETER metadata
    A hashtable with the metadata values

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-notifications.html#POST_TestNotification_test-notification_service-notifications
#>
}
