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

    try {
        Invoke-RestMethod -Uri $suppressionUri -Body $suppressionBody -Headers (Get-HeaderDictionary) -Method Post
    } catch {
        Write-Host "Generic Error Here"
    }
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
}

function Delete-CloudMonitoringSuppression {
    [Parameter(Mandatory=$true)]
    [string] $suppressionId

    Set-Variable -Name suppressionUri -Value ((Get-IdentityMonitoringURI) + "/suppressions​/$suppressionId")

    try {
        Invoke-RestMethod -Uri $suppressionUri -Headers (Get-HeaderDictionary) -Method Delete
    } catch {
        Write-Host "Generic Error Here"
    }
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
        $suppressionArray = [System.Collections.Generic.List[System.Object]] $suppressionId
        $suppressionUri += "?${suppressionArray.Item(0)}" 
        $suppressionArray.RemoveAt(0)

        foreach($s in $suppressionArray) {
            $suppressionUri += "&$s"
        }
    }

    try {
        $result = (Invoke-RestMethod -Uri $suppressionUri -Headers (Get-HeaderDictionary))
    } catch {
        Write-Host "Generic Error Here"
    }

    if($suppressionId.Length -gt 1) {$result = $result.values}
    return $result
}

function Get-CloudMonitoringSuppressionLogs {
    param ()

    Set-Variable -Name suppressionUri -Value ((Get-IdentityMonitoringURI) + '/suppression_logs')

    try {
        Invoke-RestMethod -URI $suppressionUri -Headers (Get-HeaderDictionary)
    } catch {
        Write-Host "Generic Error Here"
    }
}

function Get-CloudMonitoringSuppressions {
    param()

    return (Get-CloudMonitoringSuppression).values
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

    try {
        Invoke-RestMethod -Uri $suppressionUri -Body $suppressionBody -Headers (Get-HeaderDictionary) -Method Put
    } catch {
        Write-Host "Generic Error Here"
    }
}