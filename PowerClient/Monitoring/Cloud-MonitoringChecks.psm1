function Add-CloudMonitoringCheck {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [boolean] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [hashtable] $metadata,
        [Parameter(Position=5, Mandatory=$false)]
        [int] $period,
        [Parameter(Position=6, Mandatory=$false)]
        [int] $timeout,
        [Parameter(Mandatory=$false)]
        [string[]] $monitoring_zones_poll,
        [Parameter(Mandatory=$false)]
        [string] $target_alias,
        [Parameter(Mandatory=$false)]
        [string] $target_hostname,
        [Parameter(Mandatory=$false)]
        [ValidateSet("IPv4", "IPv6")]
        [string] $target_resolver,
    )

    Set-Variable -Name checkUri -Scope Private -Value (Get-IdentityMonitoringEntityCheckURI)
    Set-Variable -Name jsonBody -Scope Private -Value ( `
        Convert-CloudMonitoringEntityCheckParameters -type $type -details $details -disabled $disabled -label $label -metadata $metadata -period $period `
        -timeout $timeout -monitoring_zones_poll $monitoring_zones_poll -target_alias $target_alias -target_hostname $target_hostname -target_resolver $target_resolver
    )
    
    try {
        Invoke-RestMethod -URI $private:checkUri -Headers (Get-HeaderDictionary) -Body $private:jsonBody -Method Post
    } catch {
        Write-Host "Useful Error message here"
    }


}

function Convert-CloudMonitoringCheckParameters {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [boolean] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [hashtable] $metadata,
        [Parameter(Position=5, Mandatory=$false)]
        [int] $period,
        [Parameter(Position=6, Mandatory=$false)]
        [int] $timeout,
        [Parameter(Mandatory=$false)]
        [string[]] $monitoring_zones_poll,
        [Parameter(Mandatory=$false)]
        [string] $target_alias,
        [Parameter(Mandatory=$false)]
        [string] $target_hostname,
        [Parameter(Mandatory=$false)]
        [ValidateSet("IPv4", "IPv6")]
        [string] $target_resolver,
    )

    $body = New-Object -TypeName PSObject

    if($type) { $body | Add-Member -MemberType NoteProperty -Name type -Value $type }
    if($details) { $body | Add-Member -MemberType NoteProperty -Name details -Value $details }
    if($disabled) { $body | Add-Member -MemberType NoteProperty -Name disabled -Value $disabled }
    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($metadata) { $body | Add-Member -MemberType NoteProperty -Name metadata -Value $metadata }
    if($period) { $body | Add-Member -MemberType NoteProperty -Name period -Value $period }
    if($timeout) { $body | Add-Member -MemberType NoteProperty -Name timeout -Value $timeout }
    if($monitoring_zones_poll) { $body | Add-Member -MemberType NoteProperty -Name monitoring_zones_poll -Value $monitoring_zones_poll }
    if($target_alias) { $body | Add-Member -MemberType NoteProperty -Name target_alias -Value $target_alias }
    if($target_hostname) { $body | Add-Member -MemberType NoteProperty -Name target_hostname -Value $target_hostname }
    if($target_resolver) { $body | Add-Member -MemberType NoteProperty -Name target_resolver -Value $target_resolver }

    return (ConvertTo-Json $body)
}

function Delete-CloudMonitoringCheck {
    param (
        [Parameter(Position=0, Mandatory=$false)]
        [string] $checkTypeId
    )

    Set-Variable -Name checkUri -Scope Private -Value (Get-IdentityMonitoringCheckType)
    
    try {
        Invoke-RestMethod -Uri checkUri -Headers (Get-HeaderDictionary) -Method Delete
    } catch {
        Write-Host "Handle Error Message here"
    }
}

function Get-CloudMonitoringCheck {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$false)]
        [string] $checkTypeId
    )

    Set-Variable -Name checkUri -Scope Private -Value (Get-IdentityMonitoringEntityCheckURI)
    Set-Variable -Name results -Scope Private -Value $null

    try {
        $private:results = Invoke-RestMethod -URI $private:checkUri -Headers (Get-HeaderDictionary)
    } catch {
        Write-Host "Handle Error Message here"
    }

    return $results
}

function Get-CloudMonitoringChecks {
    param (
        [Parameter(Mandatory=$true)]
        [string] $entityId
    )

    return (Get-CloudMonitoringEntityCheck -entityId $entityId).values

<#
    .SYNOPSIS
    

    .DESCRIPTION
    

    .PARAMETER entityId
    Use this parameter to specify the entity which to look up the checks for.

    .EXAMPLE
    Get-CloudMonitoringEntityChecks -entityId entityId1
    Returns information on the all the checks contained within the specified entity.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-checks.html#GET_listChecks_entities__entityId__checks_service-checks
#>
}

function Get-CloudMonitoringCheckTypes {
    param (
        [Parameter(Position=0, Mandatory=$false)]
        [string] $checkTypeId
    )

    Set-Variable -Name checkUri -Scope Private -Value (Get-IdentityMonitoringCheckType)
    Set-Variable -Name results -Scope Private -Value $null

    if($checkTypeId) { $private:checkUri += "/$checkTypeId" }

    try {
        $private:results = (Invoke-RestMethod -Uri checkUri -Headers (Get-HeaderDictionary))
    } catch {

    }

    if(-not $private:results) { $private:reuslts = $private:reuslts.values }
    return $private:results

<#
    .SYNOPSIS
    

    .DESCRIPTION
    

    .PARAMETER $checkTypeId
    Optional parameter to specify the the check type for more information on.

    .EXAMPLE
    Get-CloudMonitoringEntityCheckTypes
    Returns information on all the check types.

    .EXAMPLE
    Get-CloudMonitoringEntityCheckTypes -checkTypeId agent.mssql_plan_cache
    Returns information on the checks related to that specific check type.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-check-types.html
#>
}

function Test-AddCloudMonitoringCheck {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [boolean] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [hashtable] $metadata,
        [Parameter(Position=5, Mandatory=$false)]
        [int] $period,
        [Parameter(Position=6, Mandatory=$false)]
        [int] $timeout,
        [Parameter(Mandatory=$false)]
        [string[]] $monitoring_zones_poll,
        [Parameter(Mandatory=$false)]
        [string] $target_alias,
        [Parameter(Mandatory=$false)]
        [string] $target_hostname,
        [Parameter(Mandatory=$false)]
        [ValidateSet("IPv4", "IPv6")]
        [string] $target_resolver,
        [Parameter(Mandatory=$false)]
        [boolean] $asDebug
    )

    Set-Variable -Name checkUri -Scope Private -Value (Get-IdentityMonitoringEntityCheckURI)
    Set-Variable -Name jsonBody -Scope Private -Value ( `
        Convert-CloudMonitoringEntityCheckParameters -type $type -details $details -disabled $disabled -label $label -metadata $metadata -period $period `
        -timeout $timeout -monitoring_zones_poll $monitoring_zones_poll -target_alias $target_alias -target_hostname $target_hostname -target_resolver $target_resolver
    )
    
    if($asDebug) { $pviate:checkUri += '?debug'

    try {
        Invoke-RestMethod -URI $private:checkUri -Headers (Get-HeaderDictionary) -Body $private:jsonBody -Method Post
    } catch {
        Write-Host "Useful Error message here"
    }
}

function Test-CloudMonitoringCheckInline {
        param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [boolean] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [hashtable] $metadata,
        [Parameter(Position=5, Mandatory=$false)]
        [int] $period,
        [Parameter(Position=6, Mandatory=$false)]
        [int] $timeout,
        [Parameter(Mandatory=$false)]
        [string[]] $monitoring_zones_poll,
        [Parameter(Mandatory=$false)]
        [string] $target_alias,
        [Parameter(Mandatory=$false)]
        [string] $target_hostname,
        [Parameter(Mandatory=$false)]
        [ValidateSet("IPv4", "IPv6")]
        [string] $target_resolver
    )

    Set-Variable -Name checkUri -Scope Private -Value (Get-IdentityMonitoringEntityCheckURI)
    Set-Variable -Name jsonBody -Scope Private -Value ( `
        Convert-CloudMonitoringEntityCheckParameters -type $type -details $details -disabled $disabled -label $label -metadata $metadata -period $period `
        -timeout $timeout -monitoring_zones_poll $monitoring_zones_poll -target_alias $target_alias -target_hostname $target_hostname -target_resolver $target_resolver
    )

    try {
        Invoke-RestMethod -URI $private:checkUri -Headers (Get-HeaderDictionary) -Body $private:jsonBody -Method Post
    } catch {
        Write-Host "Useful Error message here"
    }

}

function Update-CloudMonitoringCheck {
    param (
        [Parameter(Position=0, Mandatory=$false)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [boolean] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [hashtable] $metadata,
        [Parameter(Position=5, Mandatory=$false)]
        [int] $period,
        [Parameter(Position=6, Mandatory=$false)]
        [int] $timeout,
        [Parameter(Mandatory=$false)]
        [string[]] $monitoring_zones_poll,
        [Parameter(Mandatory=$false)]
        [string] $target_alias,
        [Parameter(Mandatory=$false)]
        [string] $target_hostname,
        [Parameter(Mandatory=$false)]
        [ValidateSet("IPv4", "IPv6")]
        [string] $target_resolver
    )

    Set-Variable -Name checkUri -Scope Private -Value (Get-IdentityMonitoringEntityCheckURI)
    Set-Variable -Name jsonBody -Scope Private -Value ( `
        Convert-CloudMonitoringEntityCheckParameters -type $type -details $details -disabled $disabled -label $label -metadata $metadata -period $period `
        -timeout $timeout -monitoring_zones_poll $monitoring_zones_poll -target_alias $target_alias -target_hostname $target_hostname -target_resolver $target_resolver
    )

    try {
        Invoke-RestMethod -URI $private:checkUri -Headers (Get-HeaderDictionary) -Body $private:jsonBody -Method Put
    } catch {
        Write-Host "Useful Error message here"
    }
}