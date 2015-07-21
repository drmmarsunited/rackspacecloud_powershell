#
# Function for interacting with Cloud Monitoring Alarms
#

function Add-CloudMonitoringAlarm {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Mandatory=$true)]
        [string] $checkId,
        [Parameter(Mandatory=$true)]
        [string] $notificationPlanId,
        [Parameter(Mandatory=$false)]
        [string] $criteria,
        [Parameter(Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name alarmURI -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/alarms")
    Set-Variable -Name jsonBody -Value $null
    Set-Variable -Name result -Value $null

    if($metadata) {
        $metaDataType = $metadata.GetType().BaseType.Name

        if( -not( @("Array", "Hashtable") -match $metaDataType) ) {
        Write-Host "The data type passed is not of type Array or Hashtable."
        return
    }

    $jsonBody = `
    (   Convert-ClouldMonitorAlarmParameters -checkId $checkId -notificationPlanId $notificationPlanId -criteria $criteria
            -disabled $disabled -label $label -metadata $metadata
    )

    Write-Debug "URI: `"$alarmURI`""
    Write-Debug "JSON Body: $jsonBody"
    try {
        $result = (Invoke-RestMethod -Name $alarmUri -Body $body -Headers (Get-HeaderDictionary) -Method Post)
    } catch {
        Write-Host "Generic Error Here"
    }

    return $result
<#
    .SYNOPSIS
    Add an alarm to the specified check.

    .DESCRIPTION
    See synopsis.
    
    .PARAMETER entityId
    The ID of the entity to which the check belongs.
        
    .PARAMETER checkId
    The ID of the check to alert on.
        
    .PARAMETER notificationPlanId
    The id of the notification plan to execute when the state changes.
        
    .PARAMETER criteria
    The alarm DSL for describing alerting conditions and their output states. The 
    criteria is optional. If you don't provide this attribute, the state of your 
    alarm depends entirely on the success or failure of the check. Omitting the 
    criteria attribute is a convenient shortcut for setting a simple alarm with a 
    notification plan. For example, if you set a PING check on a server, an alert is
    triggered only if no pings are returned, whereas adding criteria would enable 
    the alarm to trigger based on metrics such as if the ping round trip time went 
    past a certain threshold.
        
    .PARAMETER disabled
    Disable processing and alerts on this alarm
        
    .PARAMETER label
    A friendly label for an alarm.
        
    .PARAMETER metadata
    An array or hashtable with the metadata values

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-alarms.html#POST_createAlarm_entities__entityId__alarms_service-alarms
#>
}

function Convert-ClouldMonitorAlarmParameters {
    param (
        [Parameter(Mandatory=$false)]
        [string] $checkId,
        [Parameter(Mandatory=$false)]
        [string] $notificationPlanId,
        [Parameter(Mandatory=$false)]
        [string] $criteria,
        [Parameter(Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    $body = New-Object -TypeName PSObject

    if($checkId) { $body | Add-Member -MemberType NoteProperty -Name check_id -Value $checkId }
    if($notificationPlanId) { $body | Add-Member -MemberType NoteProperty -Name notification_plan_id -Value $notificationPlanId }
    if($criteria) { $body | Add-Member -MemberType NoteProperty -Name criteria -Value $criteria }
    if($disabled) { $body | Add-Member -MemberType NoteProperty -Name disabled -Value $disabled }
    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($metadata) { $body |Add-Member -MemberType NoteProperty -Name metadata -Value $metadata }

    return (ConvertTo-Json $body)

<#
    .SYNOPSIS
    Converts the alarm parameters to consumable json

    .DESCRIPTION
    See synopsis.
        
    .PARAMETER notificationPlanId
    The id of the notification plan to execute when the state changes.
        
    .PARAMETER criteria
    The alarm DSL for describing alerting conditions and their output states. 
        
    .PARAMETER disabled
    Disable processing and alerts on this alarm
        
    .PARAMETER label
    A friendly label for an alarm.
        
    .PARAMETER metadata
    An array or hashtable with the metadata values
#>
}

function Delete-CloudMonitoringAlarm {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $alarmId
    )

    Set-Variable -Name alarmUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/alarms/$alarmId")
    
    Write-Debug "URI: `"$alarmURI`""
    try {
        Invoke-RestMethod -URI $alarmUri -Headers (Get-HeaderDictionary) -Method Delete
    } catch {
        Write-Host "Handle Error here".
    }
<#
    .SYNOPSIS
    Deletes a cloud monitoring alarm.

    .DESCRIPTION
    See synopsis.
    
    .PARAMETER entityId
    The entityId to which the alarm is related to.

    .PARAMETER alarmId
    The id of the alarm to delete

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-alarms.html#DELETE_deleteAlarm_entities__entityId__alarms__alarmId__service-alarms
#>
}

function Get-CloudMonitoringAlarm {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$false)]
        [string[]] $alarmId
    )

    Set-Variable -Name alarmUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/alarms"​)
    Set-Variable -Name alarmIdArray -Value $null
    Set-Variable -Name results -Value $null
    
    if($alarmId) {
        $alarmIdArray = [System.Collections.Generic.List[System.Object]] $alarmId
        $alarmUri += "?id=${$alarmIdArray.Item(0)}"
        $alarmIdArray.RemoveAt(0)

        foreach($a in $alarmIdArray) {
            $alarmUri += "&$a"
        }
    }

    Write-Debug "URI: `"$alarmURI`""
    try {
        $results = (Invoke-RestMethod -Uri $alarmUri -Headers (Get-HeaderDictionary))
    } catch {
        Write-Message "Generic Error here"
    }

    if($alarmId.Length) { $results = $results.values }
    return $results
<#
    .SYNOPSIS
    Gets a cloud monitoring alarm.

    .DESCRIPTION
    Gets a cloud monitoring alarm. If none are specified, this behaves the same as Get-CloudMonitoringAlarms
    
    .PARAMETER entityId
    The entityId to which the alarm is related to.

    .PARAMETER alarmId
    The id of the alarm to get. If not specified, all alarms associated with the entity are returned.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-alarms.html#GET_listAlarms_entities__entityId__alarms_service-alarms
#>
}

function Get-CloudMonitoringAlarms {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId
    )

    return (Get-CloudMonitoringAlarms -entityId $entityId).values
<#
    .SYNOPSIS
    Gets all cloud monitoring alarms associated with the entity.

    .DESCRIPTION
    See synopsis
    
    .PARAMETER entityId
    The entityId to which the alarm is related to.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-alarms.html#GET_listAlarms_entities__entityId__alarms_service-alarms
#>
}

function Update-CloudMonitoringAlaram {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $alarmId,
        [Parameter(Mandatory=$true)]
        [string] $checkId,
        [Parameter(Mandatory=$false)]
        [string] $notificationPlanId,
        [Parameter(Mandatory=$false)]
        [string] $criteria,
        [Parameter(Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name alarmURI -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/alarms/$alarmId")
    Set-Variable -Name jsonbody -Value `
        (Convert-ClouldMonitorAlarmParameters -checkId $checkId -notificationPlanId $notificationPlanId -criteria $criteria
            -disabled $disabled -label $label -metadata $metadata)
    Set-Variable -Name result -Value $null
    
    Write-Debug "URI: `"$alarmURI`""
    Write-Debug "JSON Body: $jsonBody"
    try {
        $result = (Invoke-RestMethod -Name $alarmUri -Body $jsonBody -Headers (Get-HeaderDictionary) -Method PUT)
    } catch {
        Write-Host "Generic Error Here"
    }

    return $result
<#
    .SYNOPSIS
    Updates an alarm.

    .DESCRIPTION
    See synopsis.
    
    .PARAMETER entityId
    The ID of the entity to which the check belongs.
        
    .PARAMETER alarmId
    The ID of the alarm to update.

    .PARAMETER checkId
    The ID of the check to alert on.
        
    .PARAMETER notificationPlanId
    The id of the notification plan to execute when the state changes.
        
    .PARAMETER criteria
    The alarm DSL for describing alerting conditions and their output states. The 
    criteria is optional. If you don't provide this attribute, the state of your 
    alarm depends entirely on the success or failure of the check. Omitting the 
    criteria attribute is a convenient shortcut for setting a simple alarm with a 
    notification plan. For example, if you set a PING check on a server, an alert is
    triggered only if no pings are returned, whereas adding criteria would enable 
    the alarm to trigger based on metrics such as if the ping round trip time went 
    past a certain threshold.
        
    .PARAMETER disabled
    Disable processing and alerts on this alarm
        
    .PARAMETER label
    A friendly label for an alarm.
        
    .PARAMETER metadata
    An array or hashtable with the metadata values

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-alarms.html#PUT_updateAlarm_entities__entityId__alarms__alarmId__service-alarms
#>
}

function Test-AddCloudMonitoringAlarm {
    param (
        [Parameter(Mandatory=$true)]
        [string] $entityId,
        [Parameter(Mandatory=$true)]
        [string] $checkId,
        [Parameter(Mandatory=$true)]
        [string] $notificationPlanId,
        [Parameter(Mandatory=$false)]
        [string] $criteria,
        [Parameter(Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name alarmURI -Scope Private -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/test-alarm")
    Set-Variable -Name jsonBody -Value $null
    Set-Variable -Name result -Value $null

    if($metadata) {
        $metaDataType = $metadata.GetType().BaseType.Name

        if( -not( @("Array", "Hashtable") -match $metaDataType) ) {
        Write-Host "The data type passed is not of type Array or Hashtable."
        return
    }

    $jsonBody = ( `
        Convert-ClouldMonitorAlarmParameters -checkId $checkId -notificationPlanId $notificationPlanId -criteria $criteria
            -disabled $disabled -label $label -metadata $metadata
    )

    Write-Debug "URI: `"$alarmURI`""
    Write-Debug "JSON Body: $jsonBody"
    try {
        $result = (Invoke-RestMethod -Name $alarmUri -Body $body -Headers (Get-HeaderDictionary) -Method PUT)
    } catch {
        Write-Host "Generic Error Here"
    }

    return $result
<#
    .SYNOPSIS
    Test adds an alarm to the specified check.

    .DESCRIPTION
    See synopsis.
    
    .PARAMETER entityId
    The ID of the entity to which the check belongs.
        
    .PARAMETER checkId
    The ID of the check to alert on.
        
    .PARAMETER notificationPlanId
    The id of the notification plan to execute when the state changes.
        
    .PARAMETER criteria
    The alarm DSL for describing alerting conditions and their output states. The 
    criteria is optional. If you don't provide this attribute, the state of your 
    alarm depends entirely on the success or failure of the check. Omitting the 
    criteria attribute is a convenient shortcut for setting a simple alarm with a 
    notification plan. For example, if you set a PING check on a server, an alert is
    triggered only if no pings are returned, whereas adding criteria would enable 
    the alarm to trigger based on metrics such as if the ping round trip time went 
    past a certain threshold.
        
    .PARAMETER disabled
    Disable processing and alerts on this alarm
        
    .PARAMETER label
    A friendly label for an alarm.
        
    .PARAMETER metadata
    An array or hashtable with the metadata values

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-alarms.html#POST_alarmsTest_entities__entityId__test-alarm_service-alarms
#>
}
