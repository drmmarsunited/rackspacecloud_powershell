function Add-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $details,
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$true)]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/notifications")

    return (Private-AddCloudMonitoringNotification -notificationUri $notificationUri -details $details -label $label -type $type -metadata $metadata)
}

function Private-AddCloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationUri,
        [Parameter(Mandatory=$true)]
        [string] $details,
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$true)]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name jsonBody -Value $null

    if($metadata) {
        $metaDataType = $metadata.GetType().BaseType.Name

        if( -not( @("Array", "Hashtable") -match $metaDataType) ) {
        Write-Host "The data type passed is not of type Array or Hashtable."
        return
    }

    $jsonBody = Convert-CloudMonitoringNotification -details $details -label $label -type $type -metadata $metadata

    try {
        return (Invoke-RestMethod -URI $notificationUri -Body $jsonBody -Headers (Get-HeaderDictionary) -Method POST)
    } catch {
        Write-Host "Generic Error Message"
    }
}

function Convert-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $details,
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$true)]
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
}

function Delete-CloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $notificationId
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/notifications/$notificationId")
    
    try {
        Invoke-RestMethod -URI $notificationUri -Headers (Get-HeaderDictionary) -Method DELETE
    } catch {
        Write-Host "Warning message here"
    }
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
        Write-Host "Generic Error Here"
    }

    if($notificationId.Length -gt 1) {$result = $result.values}
    return $result

<#

#>
}

function Get-CloudMonitoringNotifications {
    param ( )

    return (Get-CloudMonitoringNotification).values

<#

#>
}

function Test-AddCloudMonitoringNotification {
    param (
        [Parameter(Mandatory=$true)]
        [string] $details,
        [Parameter(Mandatory=$true)]
        [string] $label,
        [Parameter(Mandatory=$true)]
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/test-notification")

    return (Private-AddCloudMonitoringNotification -notificationUri $notificationUri -details $details -label $label -type $type -metadata $metadata)
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
        Write-Host "Generic Error Here"
    }
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
        [string] $type,
        [Parameter(Mandatory=$false)]
        [Object] $metadata
    )

    Set-Variable -Name notificationUri -Value ((Get-IdentityMonitoringURI) + "/notifications/$notificationId")
    Set-Variable -Name jsonBody -Value $null

    if($metadata) {
        $metaDataType = $metadata.GetType().BaseType.Name

        if( -not( @("Array", "Hashtable") -match $metaDataType) ) {
        Write-Host "The data type passed is not of type Array or Hashtable."
        return
    }

    $jsonBody = Convert-CloudMonitoringNotification -details $details -label $label -type $type -metadata $metadata

    try {
        Invoke-RestMethod -URI $notificationUri -Body $jsonBody -Headers (Get-HeaderDictionary) -Method PUT
    } catch {
        Write-Host "Generic Error Message"
    }

}
