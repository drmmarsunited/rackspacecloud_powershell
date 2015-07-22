#
# Function for interacting with Cloud Monitoring Entities
#

function Add-CloudMonitoringCheck {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=0, Mandatory=$true)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [String] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [Object] $metadata,
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

    Set-Variable -Name checkUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/checks")
    Set-Variable -Name jsonBody -Value $null
    
    if($details) {
        $detailsDataType = $details.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $detailsDataType) ) {
            Write-Host "The data details passed is not of type Array or Hashtable."
            return
        }
    }

    if($metadata) {
        $metaDataType = $metadata.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $metaDataType) ) {
            Write-Host "The data metadata passed is not of type Array or Hashtable."
            return
        }
    }

    $jsonBody = ( `
        Convert-CloudMonitoringCheckParameters -type $type -details $details -disabled $disabled -label $label -metadata $metadata -period $period `
        -timeout $timeout -monitoring_zones_poll $monitoring_zones_poll -target_alias $target_alias -target_hostname $target_hostname -target_resolver $target_resolver
    )
    

    Write-Debug "URI: `"$checkUri`""
    Write-Debug "Body: `n$jsonBody"
    #try {
        Invoke-RestMethod -URI $checkUri -Body $jsonBody -ContentType application/json -Headers (Get-HeaderDictionary) -Method Post
    #} catch {
    #    Write-Host "Generic Error message that needs to be fixed here"
    #}
<#
    .SYNOPSIS
    Adds a cloud monitoring check to the specified entity.

    .DESCRIPTION
    See synopsis.

    .PARAMETER entityId
    The entity to add the check for.
        
    .PARAMETER type
    The type of check
        
    .PARAMETER details
    Details specific to the check type.
        
    .PARAMETER disabled
    Disables the check.
        
    .PARAMETER label
    A friendly label for a check.
        
    .PARAMETER metadata
    Arbitrary key/value pairs. Supports Arrays and Hashtables.

    .PARAMETER period
    The period in seconds for a check. The value must be greater than the minimum period set on your account.
        
    .PARAMETER timeout
    The timeout in seconds for a check. This has to be less than the period.
        
    .PARAMETER monitoring_zones_poll
    List of monitoring zones to poll from. Note: This argument is only required for remote (non-agent) checks. Used in remote checks only.
        
    .PARAMETER target_alias
    A key in the entity's 'ip_addresses' hash used to resolve this check to an IP address. This parameter is mutually exclusive with target_hostname.
    Used in remote checks only.
        
    .PARAMETER target_hostname
    The hostname this check should target. This parameter is mutually exclusive with target_alias. Used in remote checks only.
     
    .PARAMETER target_resolver
    Determines how to resolve the check target. Used in remote checks only.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-checks.html#POST_createCheck_entities__entityId__checks_service-checks
#>
}

function Convert-CloudMonitoringCheckParameters {
    param (
        [Parameter(Position=0, Mandatory=$false)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [String] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [Object] $metadata,
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
        [string] $target_resolver
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
<#
    .SYNOPSIS
    Converts the arguments to a consumable json body.

    .DESCRIPTION
    See synopsis.
        
    .PARAMETER type
    The type of check
        
    .PARAMETER details
    Details specific to the check type.
        
    .PARAMETER disabled
    Disables the check.
        
    .PARAMETER label
    A friendly label for a check.
        
    .PARAMETER metadata
    Arbitrary key/value pairs. Supports Arrays and Hashtables.

    .PARAMETER period
    The period in seconds for a check. The value must be greater than the minimum period set on your account.
        
    .PARAMETER timeout
    The timeout in seconds for a check. This has to be less than the period.
        
    .PARAMETER monitoring_zones_poll
    List of monitoring zones to poll from. Note: This argument is only required for remote (non-agent) checks. Used in remote checks only.
        
    .PARAMETER target_alias
    A key in the entity's 'ip_addresses' hash used to resolve this check to an IP address. This parameter is mutually exclusive with target_hostname.
    Used in remote checks only.
        
    .PARAMETER target_hostname
    The hostname this check should target. This parameter is mutually exclusive with target_alias. Used in remote checks only.
     
    .PARAMETER target_resolver
    Determines how to resolve the check target. Used in remote checks only.
#>
}

function Get-CloudMonitoringCheck {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=0, Mandatory=$false)]
        [string] $checkTypeId
    )

    Set-Variable -Name checkUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/checks/$checkTypeId")
    Set-Variable -Name results -Value $null

    Write-Debug "URI: `"$checkUri`""
    try {
        $results = Invoke-RestMethod -URI $checkUri -Headers (Get-HeaderDictionary)
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }

    return $results
<#
    .SYNOPSIS
    Returns information on the specific check type associated with the entity.

    .DESCRIPTION
    Returns information on the specific check type associated with the entity. If no check type is passed, 
    then all checks are returned. This is the same behavior as Get-CloudMonitoringChecks

    .PARAMETER entityId
    Use this parameter to specify the entity which to look up the checks for.

    .PARAMETER checkTypeId
    Use this parameter to specify the check to view. Not passing this parameter results in all checks returned.

    .EXAMPLE
    Get-CloudMonitoringEntityCheck -entityId entityId1
    Returns information on the all the checks contained within the specified entity.

    .EXAMPLE
    Get-CloudMonitoringEntityCheck -entityId entityId1 -checkTypeId checkId
    Returns information on the specific check.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-checks.html#GET_listChecks_entities__entityId__checks_service-checks
#>
}

function Get-CloudMonitoringChecks {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId
    )

    return (Get-CloudMonitoringCheck -entityId $entityId).values

<#
    .SYNOPSIS
    Returns all the monitoring checks for the specified entity

    .DESCRIPTION
    See synopsis

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

    Set-Variable -Name checkUri -Value ((Get-IdentityMonitoringURI) + "/check_types/$checkTypeId")
    Set-Variable -Name results -Value $null

    if($checkTypeId) { $checkUri += "/$checkTypeId" }

    Write-Debug "URI: `"$checkUri`""
    try {
        $results = (Invoke-RestMethod -Uri $checkUri -Headers (Get-HeaderDictionary))
    } catch {

    }

    if(-not $results.values) { return $result }
    return $results.values

<#
    .SYNOPSIS
    Returns information on the check types.

    .DESCRIPTION
    This function is overloaded. Not passing in a check type ID returns all checks. Otherwise,
    the function works as expected.

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

function Remove-CloudMonitoringCheck {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $checkTypeId
    )

    Set-Variable -Name checkUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/checks/$checkTypeId")
    
    Write-Debug "URI: `"$checkUri`""
    try {
        Invoke-RestMethod -Uri $checkUri -Headers (Get-HeaderDictionary) -Method Delete
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Deletes the specified check

    .DESCRIPTION
    See synopsis

    .PARAMETER entityId
    Use this parameter to specify the entity to which the check belongs.

    .PARAMETER checkTypeId
    Use this parameter to specify the check to delete.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-checks.html#DELETE_deleteCheck_entities__entityId__checks__checkId__service-checks
#>
}

function Test-AddCloudMonitoringCheck {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $type,
        [Parameter(Position=2, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=3, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=4, Mandatory=$false)]
        [String] $label,
        [Parameter(Position=5, Mandatory=$false)]
        [Object] $metadata,
        [Parameter(Position=6, Mandatory=$false)]
        [int] $period,
        [Parameter(Position=7, Mandatory=$false)]
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
        [switch] $asDebug
    )

    Set-Variable -Name checkUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/test-check")
    Set-Variable -Name jsonBody -Value $null
    
    if($details) {
        $detailsDataType = $details.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $detailsDataType) ) {
            Write-Host "The data details passed is not of type Array or Hashtable."
            return
        }
    }

    if($metadata) {
        $metaDataType = $metadata.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $metaDataType) ) {
            Write-Host "The data metadata passed is not of type Array or Hashtable."
            return
        }
    }

    $jsonBody = ( `
        Convert-CloudMonitoringCheckParameters -type $type -details $details -disabled $disabled -label $label -metadata $metadata -period $period `
        -timeout $timeout -monitoring_zones_poll $monitoring_zones_poll -target_alias $target_alias -target_hostname $target_hostname -target_resolver $target_resolver
    )
    
    if($asDebug) { $checkUri += '?debug=true' }

    Write-Debug "URI: `"$checkUri`""
    Write-Debug "Body: `n$jsonBody"
    try {
        Invoke-RestMethod -URI $checkUri -Body $jsonBody -ContentType application/json -Headers (Get-HeaderDictionary) -Method Post
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Tests a cloud monitoring check to the specified entity instead of adding it.

    .DESCRIPTION
    See synopsis.

    .PARAMETER entityId
    The entity to add the check for.
        
    .PARAMETER type
    The type of check
        
    .PARAMETER details
    Details specific to the check type.
        
    .PARAMETER disabled
    Disables the check.
        
    .PARAMETER label
    A friendly label for a check.
        
    .PARAMETER metadata
    Arbitrary key/value pairs. Supports Arrays and Hashtables.

    .PARAMETER period
    The period in seconds for a check. The value must be greater than the minimum period set on your account.
        
    .PARAMETER timeout
    The timeout in seconds for a check. This has to be less than the period.
        
    .PARAMETER monitoring_zones_poll
    List of monitoring zones to poll from. Note: This argument is only required for remote (non-agent) checks. Used in remote checks only.
        
    .PARAMETER target_alias
    A key in the entity's 'ip_addresses' hash used to resolve this check to an IP address. This parameter is mutually exclusive with target_hostname.
    Used in remote checks only.
        
    .PARAMETER target_hostname
    The hostname this check should target. This parameter is mutually exclusive with target_alias. Used in remote checks only.
     
    .PARAMETER target_resolver
    Determines how to resolve the check target. Used in remote checks only.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-checks.html#POST_checkTestNew_entities__entityId__test-check_service-checks
#>
}

function Test-CloudMonitoringCheckInline {
        param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $checkTypeId
    )

    Set-Variable -Name checkUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/checks/$checkTypeId/test")

    Write-Debug "URI: `"$checkUri`""
    #try {
        Invoke-RestMethod -URI $checkUri -Headers (Get-HeaderDictionary) -Method Post
    #} catch {
    #    Write-Host "Generic Error message that needs to be fixed here"
    #}
<#
    .SYNOPSIS
    Tests an existing check inline.

    .DESCRIPTION
    This operation does NOT cause the already-created check to be run, but rather creates a duplicate check 
    with the same parameters as the original, and performs the test using that. You can copy the results of 
    a test check response and paste it directly into a test alarm. 

    .PARAMETER entityId
    The entity to use to test the inline check
    
    .PARAMETER checkTypeId
    The checkid to use to test the inline check
        
    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-checks.html#POST_checkExistingTest_entities__entityId__checks__checkId__test_service-checks
#>
}

function Update-CloudMonitoringCheck {
    param (
        [Parameter (Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId,
        [Parameter(Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $checkTypeId,
        [Parameter(Position=0, Mandatory=$false)]
        [string] $type,
        [Parameter(Position=1, Mandatory=$false)]
        [Object] $details,
        [Parameter(Position=2, Mandatory=$false)]
        [boolean] $disabled,
        [Parameter(Position=3, Mandatory=$false)]
        [String] $label,
        [Parameter(Position=4, Mandatory=$false)]
        [Object] $metadata,
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

    Set-Variable -Name checkUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId/checks/$checkTypeId")
    Set-Variable -Name jsonBody -Value $null
    
    if($details) {
        $detailsDataType = $details.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $detailsDataType) ) {
            Write-Host "The data details passed is not of type Array or Hashtable."
            return
        }
    }

    if($metadata) {
        $metaDataType = $metadata.GetType().Name

        if( -not( @("Object[]", "Hashtable") -match $metaDataType) ) {
            Write-Host "The data metadata passed is not of type Array or Hashtable."
            return
        }
    }

    $jsonBody = ( `
        Convert-CloudMonitoringCheckParameters -type $type -details $details -disabled $disabled -label $label -metadata $metadata -period $period `
        -timeout $timeout -monitoring_zones_poll $monitoring_zones_poll -target_alias $target_alias -target_hostname $target_hostname -target_resolver $target_resolver
    )

    Write-Debug "URI: `"$checkUri`""
    Write-Debug "Body: `n$jsonBody"
    try {
        Invoke-RestMethod -URI $checkUri -Body $jsonBody -ContentType application/json -Headers (Get-HeaderDictionary) -Method Put
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Updates a cloud monitoring check.

    .DESCRIPTION
    See synopsis.

    .PARAMETER entityId
    The entity related to the check that needs updating.
    
    .PARAMETER checkTypeId
    The check to update.
        
    .PARAMETER type
    The type of check
        
    .PARAMETER details
    Details specific to the check type.
        
    .PARAMETER disabled
    Disables the check.
        
    .PARAMETER label
    A friendly label for a check.
        
    .PARAMETER metadata
    Arbitrary key/value pairs. Supports Arrays and Hashtables.

    .PARAMETER period
    The period in seconds for a check. The value must be greater than the minimum period set on your account.
        
    .PARAMETER timeout
    The timeout in seconds for a check. This has to be less than the period.
        
    .PARAMETER monitoring_zones_poll
    List of monitoring zones to poll from. Note: This argument is only required for remote (non-agent) checks. Used in remote checks only.
        
    .PARAMETER target_alias
    A key in the entity's 'ip_addresses' hash used to resolve this check to an IP address. This parameter is mutually exclusive with target_hostname.
    Used in remote checks only.
        
    .PARAMETER target_hostname
    The hostname this check should target. This parameter is mutually exclusive with target_alias. Used in remote checks only.
     
    .PARAMETER target_resolver
    Determines how to resolve the check target. Used in remote checks only.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-checks.html#PUT_updateCheck_entities__entityId__checks__checkId__service-checks
#>
}