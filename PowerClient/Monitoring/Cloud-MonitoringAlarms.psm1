#
# Function for interacting with Cloud Monitoring Alarms
#

function Add-CloudMonitoringAlarm {
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

    Set-Variable -Name alarmURI -Scope Private -Value (Get-IdentityMonitoringAlarmURI)
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
    

    try {
        $result = (Invoke-RestMethod -Name $alarmUri -Body $body -Headers (Get-HeaderDictionary) -Method Post)
    } catch {
        Write-Host "Generic Error Here"
    }

    return $result
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
    if($notificationPlanId) { $body | Add-Member -MemberType NoteProperty -Name notification_plan_id 	 -Value $notificationPlanId }
    if($criteria) { $body | Add-Member -MemberType NoteProperty -Name criteria -Value $criteria }
    if($disabled) { $body | Add-Member -MemberType NoteProperty -Name disabled -Value $disabled }
    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($metadata) { $body |Add-Member -MemberType NoteProperty -Name metadata -Value $metadata }

    return (ConvertTo-Json $body)

<#
#>
}

function Delete-CloudMonitoringAlarm {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $alarmId
    )

    Set-Variable -Name alarmUri -Scope Private -Value (Get-IdentityMonitoringAlarmURI)
    
    try {
        Invoke-RestMethod -URI $private:alarmUri -Headers (Get-HeaderDictionary) -Method Delete
    } catch {
        Write-Host "Handle Error here".
    }
}

function Get-CloudMonitoringAlarms {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$false)]
        [string[]] $alarmId
    )

    Set-Variable -Name alarmUri -Value (Get-IdentityMonitoringAlarmURI)
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

    try {
        $results = (Invoke-RestMethod -Uri $alarmUri -Headers (Get-HeaderDictionary))
    } catch {
        Write-Message "Generic Error here"
    }

    if($alarmId.Length) { $results = $results.values }
    return $results
}

function Get-CloudMonitoringAlarms {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $entityId
    )

    return (Get-CloudMonitoringAlarms -entityId $entityId).values
}

function Update-CloudMonitoringAlaram {
    param (
        [Parameter(Mandatory=$true)]
        [string] $entityId,
        [Parameter(Mandatory=$true)]
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

    Set-Variable -Name alarmURI -Scope Private -Value (Get-IdentityMonitoringAlarmURI)
    Set-Variable -Name body -Value `
        (Convert-ClouldMonitorAlarmParameters -checkId $checkId -notificationPlanId $notificationPlanId -criteria $criteria
            -disabled $disabled -label $label -metadata $metadata)
    Set-Variable -Name result -Value $null
    
    try {
        $result = (Invoke-RestMethod -Name $alarmUri -Body $body -Headers (Get-HeaderDictionary) -Method PUT)
    } catch {
        Write-Host "Generic Error Here"
    }

    return $result
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

    Set-Variable -Name alarmURI -Scope Private -Value (Get-IdentityMonitoringAlarmURI)
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

    try {
        $result = (Invoke-RestMethod -Name $alarmUri -Body $body -Headers (Get-HeaderDictionary) -Method PUT)
    } catch {
        Write-Host "Generic Error Here"
    }

    return $result
}
