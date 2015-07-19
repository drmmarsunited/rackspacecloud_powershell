#
# Functions for authentication to the OpenStack API
#

Set-Variable -Name CloudUsername -Scope Script  -Value "" 
Set-Variable -Name CloudAPIKey -Scope Script    -Value ""
Set-Variable -Name CloudDDI -Scope Script       -Value ""
Set-Variable -Name accessToken -Scope Script    -Value $null
Set-Variable -Name headers -Scope Script        -Value $null


function Get-AccessToken {
    param ()

    Test-AccessToken
    return $script:accessToken

<#
    .SYNOPSIS
    Returns the access token.

    .DESCRIPTION
    Tests the current access token and, if necessary, acquires a new token before
    returning the access token
#>
}

function Get-CloudUsername
{
    return $script:CloudUsername

<#
    .SYNOPSIS
    Returns the username associated with the current authentication scope 
#>
}

function Get-CloudAPIKey {
    return $script:CloudAPIKey

<#
    .SYNOPSIS
    Returns the API Key associated with the current authentication scope 
#>
}

function Get-CloudDDI {
    return $script:CloudDDI

<#
    .SYNOPSIS
    Returns the DDI associated with the current authentication scope 
#>
}

function Get-HeaderDictionary {
    return $script:headers
<#
    .SYNOPSIS
    Sets the authentication token usable for additional API commands.

    .DESCRIPTION
    Checks the current access token and, if null or expired, refreshes the token.
#>
}

function Request-AuthToken() {
        
    ## Setting variables needed for function execution
    Set-Variable -Name AuthURI -Value (Get-IdentityAuthURI)
    Set-Variable -Name AuthBody -Value (Get-IdentityAuthBody)

    try {
        $script:accessToken = (Invoke-RestMethod -Uri $AuthURI -Body $AuthBody -ContentType application/json -Method Post)
    } catch {
        #Figure out how to handle the error (e.g. incorrect login) gracefully.
        Write-Error "Reach the error message. Figure out how to handle this gracefully"
    }

    $accessTokenId = $script:accessToken.access.token.id

    ## Headers in powershell need to be defined as a dictionary object, so here I'm creating a dictionary object with the newly granted token. It's global, as it's needed in every future request.
    Set-Variable -Name headers -Scope Script -Value (new-object "System.Collections.Generic.Dictionary``2[[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]")
    $script:headers.Add("X-Auth-Token", $accessTokenId)
<#
    .SYNOPSIS
    Requests a new token.

    .DESCRIPTION
    Requests a new token and updates the script variables with the token and header values.    
#>
}

function Set-AccountAuthentication
{

    param(
        [Parameter(Position=0, Mandatory=$false)]
        [string] $CloudUsername,
        [Parameter(Position=0, Mandatory=$false)]
        [string] $CloudAPIKey,
        [Parameter(Position=0, Mandatory=$false)]
        [string] $CloudDDI
    )

    $script:CloudUsername = $CloudUsername
    $script:CloudAPIKey = $CloudAPIKey
    $script:CloudDDI = $CloudDDI

<#
    .SYNOPSIS
    (Re)Set the desired authentication credentials

    .DESCRIPTION
    (Re)set the desired authentication credentials. Requires passing in parameters to specify which parameters are being set.

    .PARAMETER CloudUsername
    The account username. Use -CloudUserName to set.

    .PARAMETER CloudAPIKey
    The account API key. Use -CloudAPIKey to set.

    .PARAMETER CloudDDI
    The CloudDDI variable is your account number or tenant ID. For Rackspace customers, this can be found at the top right 
    of your screen when logged into the Rackspace Cloud Control Panel. Use -CloudDDI to set.

    .EXAMPLE
    Set-AccountAuthentication -CloudUserName sampleUser
    This example sets only the username. Similar usage can be achieved to set only the API Key or DDI.
    
    .EXAMPLE
    Set-AccountAuthentication -CloudUserName sampleUser -CloudAPIKey 1234567890 -CloudDDI 09876543
    This example sets all three authentication credentials.  
#>
}

function Test-AccessToken {
    ## Check for current authentication token and retrieves a new one if needed
    if ((Get-Date) -ge $script:accessToken.access.token.expires) {
        Write-Verbose "Token invalid or expired. Aquiring new token."
        Request-AuthToken
    }

<#
    .SYNOPSIS
    Tests the authentication to determine if it has expired or is invalid.

    .DESCRIPTION
    Checks the current access token and, if null or expired, refreshes the token.
#>
}