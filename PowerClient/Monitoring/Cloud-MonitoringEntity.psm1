#
# Function for interacting with Cloud Monitoring Entities
#

function Add-CloudMonitoringEntity {
    param (
        [Parameter (Mandatory=$false)]
        [string] $label,
        [Parameter (Mandatory=$false)]
        [string] $agent_id,
        [Parameter (Mandatory=$false)]
        [hashtable] $ip_addresses,
        [Parameter (Mandatory=$false)]
        [string] $managed,
        [Parameter (Mandatory=$false)]
        [Object] $metadata,
        [Parameter (Mandatory=$false)]
        [string] $uri
    )

    Set-Variable -Name entityUri -Value ((Get-IdentityMonitoringURI) + "/entities")
    Set-Variable -Name jsonBody -Value $null
    
    if($metadata) {
        $metaDataType = $metadata.GetType().BaseType.Name

        if( -not( @("Array", "Hashtable") -match $metaDataType) ) {
        Write-Host "The data type passed is not of type Array or Hashtable."
        return
    }

    $jsonBody = (Convert-ClouldMonitorEntityParameters -label $label -agent_id $agent_id -ip_addresses $ip_addresses -managed $managed -metadata $metadata -uri $uri)

    Write-Debug "URI: `"$entityUri`""
    Write-Debug "JSON Body: $jsonBody"
    try {
        Invoke-RestMethod -URI $entityURI -Body $jsonBody -Headers (Get-HeaderDictionary) -Method POST
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Creates an entity

    .DESCRIPTION
    Builds a JSON body based off the specified parameters and adds the entity. Please refer to the documentation in the
    specified link for more information on this parameter.
    
    .PARAMETER label
    The label of the entity.

    .PARAMETER agent_id
    The agent ID of the entity

    .PARAMETER ip_addresses
    The IP addresses associated with the entity

    .PARAMETER managed
    Indicate if the entity is managed.

    .PARAMETER metadata
    An array or hashtable with the metadata values

    .PARAMETER uri
    The URI for the entity.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-entities.html#POST_addEntity_entities_service-entities
#>
}

function Convert-ClouldMonitorEntityParameters {
    param (
        [Parameter (Mandatory=$false)]
        [string] $label,
        [Parameter (Mandatory=$false)]
        [string] $agent_id,
        [Parameter (Mandatory=$false)]
        [hashtable] $ip_addresses,
        [Parameter (Mandatory=$false)]
        [boolean] $managed,
        [Parameter (Mandatory=$false)]
        [Object] $metadata,
        [Parameter (Mandatory=$false)]
        [string] $uri
    )

    $body = New-Object -TypeName PSObject

    if($label) { $body | Add-Member -MemberType NoteProperty -Name label -Value $label }
    if($agent_id) { $body | Add-Member -MemberType NoteProperty -Name agent_id -Value $agent_id }
    if($ip_addresses) { $body | Add-Member -MemberType NoteProperty -Name ip_addresses -Value $ip_addresses }
    if($managed) { $body | Add-Member -MemberType NoteProperty -Name managed -Value $managed }
    if($metadata) { $body |Add-Member -MemberType NoteProperty -Name metadata -Value $metadata }
    if($uri) { $body |Add-Member -MemberType NoteProperty -Name uri -Value $uri }

    return (ConvertTo-Json $body)

<#
    .SYNOPSIS
    Returns a Json Body for use in processing.

    .DESCRIPTION
    Builds a PSObject and then converts the result to JSON.

    .PARAMETER label
    The label of the entity.

    .PARAMETER agent_id
    The agent ID of the entity

    .PARAMETER ip_addresses
    The IP addresses associated with the entity

    .PARAMETER managed
    Indicate if the entity is managed.

    .PARAMETER metadata
    An array or hashtable with the metadata values

    .PARAMETER uri
    The URI for the entity.
#>
}

function Delete-CloudMonitoringEntity {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId
    )

    Set-Variable -Name entityURI -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId")
    
    Write-Debug "URI: `"$entityURI`""
    try {
        $result = (Invoke-RestMethod -URI $entityURI -Headers (Get-HeaderDictionary) -Method Delete)
        Write-Host "Entity deleted successfully"
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }

<#
    .SYNOPSIS
    Deletes the specific entity

    .DESCRIPTION
    Removes the specific entity.
    
    .PARAMETER entityId
    The entity to delete

    .EXAMPLE
    Delete-CloudMonitoringEntity -entityId 'abcdegfh'
    "Entity deleted successfully"

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-entities.html#DELETE_deleteEntity_entities__entityId__service-entities
#>
}

function Get-CloudMonitoringEntities {
    param (
        [Parameter (Mandatory=$false)]
        [string[]] $agentId,
        [Parameter (Mandatory=$false)]
        [string[]] $id
    )
    
    Set-PSDebug -Strict

    Set-Variable -Name entityURI -Value ((Get-IdentityMonitoringURI) + "/entities")
    Set-Variable -Name appendToURI -Value $false
    Set-Variable -Name workingArrayList -Value $null
    Set-Variable -Name result -Value $null

    if($agentId) {
        $appendToURI = $true

        $workingArrayList = [System.Collections.Generic.List[System.Object]] $agentId
        $entityURI += "?agent_id${workingArrayList.Item(0)}"
        $workingArrayList.RemoveAt(0)

        foreach($w in $workingArrayList) {
            $entityURI += "&agent_id=$w"
        }
    }
    elseif($id) {
        $workingArrayList = [System.Collections.Generic.List[System.Object]] $id

        if(-not $appendToURI) { 
            $entityURI += "?id=${workingArrayList.Item(0)}"
            $workingArrayList.RemoveAt(0)
        }

        foreach($w in $workingArrayList) {
            $entityURI += "&id=$w"
        }
    }

    Write-Debug "URI: `"$entityURI`""
    try {
        $result = (Invoke-RestMethod -URI $entityURI -Headers (Get-HeaderDictionary))
    } catch {
        Write-Host -ForegroundColor Red "Generic Error Message"
    } finally {
        Set-PSDebug -Off
    }

    return $result.values
    
<#
    .SYNOPSIS
    Returns the entities associated with the specified account.

    .DESCRIPTION
    The body of this function uses existing authentication functions and builds the necessary Powershell 
    RestMethod request to return the list of entities. Depending on the parameters passed in, the entities can
    be filtered based off the agent and/or id.
    
    .PARAMETER agentId
    Array of strings representing the filter parameters.

    .PARAMETER id
    Array of ids representing the filter parameters.

    .EXAMPLE
    Get-CloudMonitoringEntities
    Returns all entities

    .EXAMPLE
    Get-CloudMonitoringEntities -agent_id 'agent1','agent2' -id '1','2','3'
    This should return all the entities that meet those criteria. However, it appears the agent parameter is bugged and
    not operational

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-entities.html#GET_listEntities_entities_service-entities
#>
}

function Get-CloudMonitoringEntity {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $entityId
    )

    #This functionality is already built in for us in a different fashion.
    Get-CloudMonitoringEntities -id $entityId

<#
    .SYNOPSIS
    Returns the entity associated with the specified account.

    .DESCRIPTION
    This is supposed to be the implementation of the GET request for /entities/{entityId}, but the results are identical
    to what's returned when passing /entities?id=$entityId, so this method just calles the other.
    
    .PARAMETER entityId
    The entity to pass through to lookup.

    .EXAMPLE
    Get-CloudMonitoringEntity -entityId 'abcdegfh'
    Returns information on that specific entity.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-entities.html#GET_getEntityId_entities__entityId__service-entities
#>
}

function Update-ClouldMonitoringEntity {
    param (
        [Parameter (Position=0, Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string] $entityId,
        [Parameter (Mandatory=$false)]
        [string] $label,
        [Parameter (Mandatory=$false)]
        [string] $agent_id,
        [Parameter (Mandatory=$false)]
        [hashtable] $ip_addresses,
        [Parameter (Mandatory=$false)]
        [string] $managed,
        [Parameter (Mandatory=$false)]
        [Object] $metadata,
        [Parameter (Mandatory=$false)]
        [string] $uri
    )

    Set-Variable -Name entityUri -Value ((Get-IdentityMonitoringURI) + "/entities/$entityId")
    Set-Variable -Name jsonBody -Value $null
    
    if($metadata) {
        $metaDataType = $metadata.GetType().BaseType.Name

        if( -not( @("Array", "Hashtable") -match $metaDataType) ) {
        Write-Host "The data type passed is not of type Array or Hashtable."
        return
    }
    
    $jsonBody = (Convert-ClouldMonitorEntityParameters -label $label -agent_id $agent_id -ip_addresses $ip_addresses -managed $managed -metadata $metadata -uri $uri)

    $entityUri += "/$entityId"
    Write-Debug "URI: `"$entityUri`""
    Write-Debug "JSON Body: $jsonBody"
    try {
        Invoke-RestMethod -URI $entityURI -Body $jsonBody -Headers (Get-HeaderDictionary) -Method PUT
    } catch {
        Write-Host "Generic Error message that needs to be fixed here"
    }
<#
    .SYNOPSIS
    Updates an entity

    .DESCRIPTION
    Builds a JSON body based off the specified parameters and updates the entity. Please refer to the documentation in the
    specified link for more information on this parameter.
    
    .PARAMETER entityId
    The entity to update

    .PARAMETER label
    The label of the entity.

    .PARAMETER agent_id
    The agent ID of the entity

    .PARAMETER ip_addresses
    The IP addresses associated with the entity

    .PARAMETER managed
    Indicate if the entity is managed.

    .PARAMETER metadata
    An array or hashtable with the metadata values  

    .PARAMETER uri
    The URI for the entity.

    .LINK
    http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/service-entities.html#PUT_updateEntity_entities__entityId__service-entities
#>
}