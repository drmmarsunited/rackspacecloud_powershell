#
# Rackspace specific implementation for Openstack API.
#

#Create the variables the functions below use.
Set-Variable -Name identityURI -Scope Script -Value 'https://identity.api.rackspacecloud.com/v2.0/tokens.xml'
Set-Variable -Name authBody -Scope Script -Value "{{`"auth`":{{`"RAX-KSKEY:apiKeyCredentials`":{{`"username`":`"{0}`", `"apiKey`":`"{1}`"}}}}}}"


function Get-ProviderAuthBody {
    $private:result = [string]::Format($script:authBody, (Get-CloudUsername), (Get-CloudAPIKey))
    Write-Verbose "Using auth body of: $result"
    return $result
<#
    .SYNOPSIS
    Returns the a JSON body to use for authentication.
#>
}

function Get-ProviderURI {
    return $script:identityURI
<#
    .SYNOPSIS
    Returns the URI used for Authentication with Rackspace
#>
}

function Get-ProviderMonitoringURI {
    param (
        [Parameter(Position=0,Mandatory=$true)
        [xml] $accessToken
    )
    
    $endpoint = $accessToken.access.serviceCatalog.service |where {$_.type -match 'rax:monitor'}

    if(-not $endpoint) {throw [System.IO.IOException] "Could not find a valid monitoring endpoint"

    return $endpoint.endpoint.publicURL

<#
    .SYNOPSIS
    Return the URI to use for the monitoring operations.

    .DESCRIPTION
    Parses the token provided and determines the approprite uri for the monitoring endpoint. If
    the endpoint is not found, an IO exception is thrown.
#>
}
