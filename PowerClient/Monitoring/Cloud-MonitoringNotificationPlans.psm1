function Add-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [string] $criticalState,
        [Parameter(Mandatory=$false)]
        [string] $warningState,
        [Parameter(Mandatory=$false)]
        [string] $okState,
        [Parameter(Mandatory=$false)]
        [object] $metadata
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-MonitoringUri) + "/notification_plans" )
    Set-Variable -Name jsonBody -Value $null

    $jsonBody = (Convert-CloudMonitoringNotificationPlan -label $label -criticalState $criticalState -warningState $warningState -okState $okState -metadata $metaData)

    try {
        Invoke-RestMethod -URI notificationPlanUri -Body $jsonBody -Headers (Get-HeaderDictionary) -Method POST
    } catch {
        Write-Host "Generic Error here"
    }
}

function Convert-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [string[]] $criticalState,
        [Parameter(Mandatory=$false)]
        [string[]] $warningState,
        [Parameter(Mandatory=$false)]
        [string[]] $okState,
        [Parameter(Mandatory=$false)]
        [object] $metadata
    )

    $body = New-Object -TypeName PSObject

    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($criticalState) { $body | Add-Member -MemberType NoteProperty -Name critical_state -Value $criticalState }
    if($warningState) { $body | Add-Member -MemberType NoteProperty -Name warning_state -Value $warningState }
    if($okState) { $body | Add-Member -MemberType NoteProperty -Name ok_state -Value $okState }
    if($metadata) { $body | Add-Member -MemberType NoteProperty -Name metadata -Value $metadata }

    return (ConvertTo-Json $body)
}

function Get-CloudMonitoringNotificationPlan {
    param(
        [Parameter(Mandatory=$true)]
        [string []] $notificationPlanId
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-MonitoringUri) + "/notification_plans" )
    Set-Variable -Name notificationPlanArray -Value $null
    Set-Variable -Name result -Value $null

    if($notificationPlanId) { 
        $notificationPlanArray = [System.Collections.Generic.List[System.Object]] $notificationPlanId
        $notificationPlanUri += "?${notificationPlanArray.Item(0)}" 
        $notificationPlanArray.RemoveAt(0)

        foreach($n in $notificationPlanArray) {
            $notificationPlanUri += "&$n"
        }
    }

    try {
        $result = (Invoke-RestMethod -URI notificationPlanUri -Headers (Get-HeaderDictionary))
    } catch {
        Write-Host "Generic Error Here"
    }

    if($notificationPlanId.Length -gt 1) {$result = $result.values}
    return $result
}

function Get-CloudMonitoringNotificationPlans {
    param ()

    return (Get-CloudMonitoringNotificationPlan).values
}

function Update-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationPlanId,
        [Parameter(Mandatory=$false)]
        [string] $label,
        [Parameter(Mandatory=$false)]
        [string[]] $criticalState,
        [Parameter(Mandatory=$false)]
        [string[]] $warningState,
        [Parameter(Mandatory=$false)]
        [string[]] $okState,
        [Parameter(Mandatory=$false)]
        [object] $metadata
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-MonitoringUri) + "/notification_plans/$notificationPlanId" )
    Set-Variable -Name jsonBody -Value $null

    $jsonBody = (Convert-CloudMonitoringNotificationPlan -label $label -criticalState $criticalState -warningState $warningState -okState $okState -metadata $metaData)

    try {
        Invoke-RestMethod -URI notificationPlanUri -Body $jsonBody -Headers (Get-HeaderDictionary) -Method PUT
    } catch {
        Write-Host "Generic Error here"
    }
}

function Delete-CloudMonitoringNotificationPlan {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationPlanId
    )

    Set-Variable -Name notificationPlanUri -Value ((Get-MonitoringUri) + "/notification_plans/$notificationPlanId" )

    try {
        Invoke-RestMethod -URI notificationPlanUri -Body $jsonBody -Headers (Get-HeaderDictionary) -Method DELETE
    } catch {
        Write-Host "Generic Error here"
    }
}