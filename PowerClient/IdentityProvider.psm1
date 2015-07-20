#
# Functions relating to managing the service endpoints for Openstack providers.
#
# Developer Note: 
# I am not sure if this is the best idea for this, but I'd like to abstract this outside of
# other functions should the API significantly change and/or other OpenStack providers send
# a radically different response token. Building for simplicity now and will abstratc later.
#

#-------------------------------------------------------------------------------------------

#Declare Module Variables
Set-Variable -Name OpenStackProvider -Scope Script -Value $null

#-------------------------------------------------------------------------------------------


function Get-IdentityAuthBody {
    return (Get-ProviderAuthBody)

<#
    .SYNOPSIS
    Returns a JSON string to use for authentication against the OpenStack provider's API.

    .DESCRIPTION
    Invokes the Identity Provider specified in the main module manifest and uses its config
    to return the JSON authenticaiton body used for authentication against the provider's API.
#>
}

function Get-IdentityAuthURI {
    return (Get-ProviderURI)

<#

    .SYNOPSIS
    Returns the URI to use for authentication against the OpenStack provider's API.

    .DESCRIPTION
    Invokes the Identity Provider specified in the main module manifest and uses its config
    to return the URI used for authentication against the provider's API.
#>
}

function Get-IdentityMonitoringURI {
    return (Get-ProviderMonitoringURI -accessToken (Get-AccessToken))

<#
    .SYNOPSIS
    Returns the URI for the monitoring endpoint.
#>
}

function Initialize-Identity {
    param()

    Set-PSDebug -Strict

    $private:PrivateData  = $MyInvocation.MyCommand.Module.PrivateData
    
    $username = $PrivateData['cloudUsername']
    $api = $PrivateData['cloudAPIKey']
    $ddi = $PrivateData['cloudDDI']
    $script:OpenStackProvider = $PrivateData['identityProvider']
    
    Set-AccountAuthentication -CloudUserName $username -CloudAPIKey $api -CloudDDI $ddi

    Write-Verbose "Attempting to import provider .\Providers\${OpenStackProvider}.psm1"
    if(Test-path .\Providers\${OpenStackProvider}.psm1) { Import-Module ".\Providers\${OpenStackProvider}.psm1" }
    else { 
        Write-Host -ForegroundColor Red -BackgroundColor Black `
        "Cannot find an implmentation for OpenStack provider `"${OpenStackProvider}`". All futher actions will fail... miserably." 

        Write-Host -ForegroundColor Red -BackgroundColor Black "Please consult the installation manual for more details."
    }

    Set-PSDebug -Off

<#
    .SYNOPSIS
    Initializes the identity provider.

    .DESCRIPTION
    Initializes the identity provider based off the data in the manifest. This function should be
    invoked at the end of the file.
#>
}


#Initialize Module Variables and import identity
Initialize-Identity
