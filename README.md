<h1>PowerClient - Rackspace Cloud API Powershell Client</h1>

<h2>Introduction</h2>

PowerClient is a Powershell API client for Rackspace’s public cloud environment.  It is setup to work with Rackspace’s “NextGen” servers, based on Openstack.  The plan is to port this management client to be able to be implemented in ANY Openstack environment, however, no timeframe has been established on this milestone yet.  

This module is utilizing standard function definitions, and can be added to as needed, if you want to enable your own custom cmdlets.  Here is an example of one entire cmdlet, including help documentation for it:



```Powershell

function Get-CloudServerImages {
    
    Param(
        [Parameter (Position=1, Mandatory=$true)]
        [string] $Region
    )

    ## Setting variables needed to execute this function
    Set-Variable -Name DFWImageURI -Value "https://dfw.servers.api.rackspacecloud.com/v2/$CloudDDI/images/detail.xml"
    Set-Variable -Name ORDImageURI -Value "https://ord.servers.api.rackspacecloud.com/v2/$CloudDDI/images/detail.xml"

## Using conditional logic to route requests to the relevant API per data center
if ($Region -eq "DFW"){
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Making the call to the API for a list of available server images and storing data into a variable
    [xml]$ServerImageListDFWStep0 = (Invoke-RestMethod -Uri $DFWImageURI  -Headers $HeaderDictionary)
    [xml]$ServerImageListDFWFinal = ($ServerImageListDFWStep0.innerxml)

    ## Since the response body is XML, we can use dot notation to show the information needed without further parsing.
    $ServerImageListDFWFinal.Images.Image | Sort-Object Name | ft $ImageListTable -AutoSize
    }

## See first "if" block for notes on each line##
elseif ($Region -eq "ORD"){

    Get-AuthToken

    [xml]$ServerImageListORDStep0 = (Invoke-RestMethod -Uri $ORDImageURI  -Headers $HeaderDictionary)
    [xml]$ServerImageListORDFinal = ($ServerImageListORDStep0.innerxml)

    $ServerImageListORDFinal.Images.Image | Sort-Object Name | ft $ImageListTable -AutoSize
    }

else {
    
    ## Sending a text error if the region has been misspelled
    Send-RegionError
    }
<#
 .SYNOPSIS
 The Get-CloudServerImages cmdlet will pull down a list of all Rackspace Cloud Server image snapshots on your account, including Rackspace's base OS images.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER Region
 Use this parameter to indicate the region in which you would like to execute this request.  Valid choices are "DFW" or "ORD" (without the quotes).

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages -Region DFW
 This example shows how to get a list of all available images in your account within the DFW region.

  .EXAMPLE
 PS C:\Users\Administrator> Get-CloudServerImages ORD
 This example shows how to get a list of all available images in your account within the ORD region, but without specifying the parameter name itself.  Both examples work interchangably. Example output:

 
 PS C:\Users\mitch.robins> Get-CloudServerImages ord

Image ID                             Image Name                                                                       Image Status Image Last Updated  
--------                             ----------                                                                       ------------ ------------------  
c94f5e59-0760-467a-ae70-9a37cfa6b94e Arch 2012.08                                                                     ACTIVE       2013-02-07T20:50:25Z
03318d19-b6e6-4092-9b5c-4758ee0ada60 CentOS 5.6                                                                       ACTIVE       2013-02-07T20:51:03Z
acf05b3c-5403-4cf0-900c-9b12b0db0644 CentOS 5.8                                                                       ACTIVE       2013-02-27T16:56:09Z
a3a2c42f-575f-4381-9c6d-fcd3b7d07d17 CentOS 6.0                                                                       ACTIVE       2013-02-27T16:57:56Z
0cab6212-f231-4abd-9c70-608d0d0e04ba CentOS 6.2                                                                       ACTIVE       2013-02-27T16:58:45Z
c195ef3b-9195-4474-b6f7-16e5bd86acd0 CentOS 6.3                                                                       ACTIVE       2013-02-27T16:59:31Z
...

.LINK
http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Images-d1e4427.html
#>
}
```


As with any 3rd party script, please use this module at your own risk.

<h2>Prerequisites</h2>

<b>Rackspace Cloud Account</b>
    
* Username
    
* DDI (account number)
    
* API Key

<b>.NET & Windows Management Framework 3.0, Respectively</b>
    
* [Download .NET Here] (http://www.microsoft.com/en-us/download/details.aspx?id=17851)

* [Download WMF 3.0 Here] (http://www.microsoft.com/en-us/download/details.aspx?id=34595)
 
<b>Powershell Execution Policy</b>

* This script is not yet signed.  In order for this module to be properly imported, please run "Set-ExecutionPolicy Unrestricted" as a local/domain admin on your server. <b> Please note, if you have UAC enabled, you must run Powershell "as an administrator" to be able to manipulate execution policy.</b>

<h2>How to Install</h2>

The way this script is built as a Powershell module. Start by downloading as a ZIP file [HERE] (https://github.com/drmmarsunited/rackspacecloud_powershell/archive/master.zip). By default, PowerShell looks in the paths specified in the $env:PSModulePath environment variable when searching for available modules on a system. This contains two paths out of the box

1.	<b>System Location</b>
    
    a.	 %windir%\System32\WindowsPowerShell\v1.0\Modules 

2.	<b>Currently logged on user location</b>
    
    a.	%UserProfile%\Documents\WindowsPowerShell\Modules

For the sake of ease, place the “PowerClient” folder in the 2nd listed folder above.  Once you’ve placed the folder in its new location, edit the “RSCloud.psm1” with Notepad (or you’re preferred text editor). In this file, the following lines need to be edited with you Rackspace cloud account information (please your information between the double quotes):

```Powershell

## Define Global Variables Needed for API Comms ##

Set-Variable -Name CloudUsername -Value "" -Scope Global
Set-Variable -Name CloudAPIKey -Value "" -Scope Global
Set-Variable -Name CloudDDI -Value "" -Scope Global
```

After editing the file, please save it!  You can then launch Powershell, and run "Import-Module PowerClient". At this point, you should be able to run all the commands listed in the wiki (link below) at your leisure. <b>It would also help you to extend your Powershell window and screen buffer size to the maximum your screen can support for easiest reading.</b>

<h2>Additional Information / ProTips</h2>

Help for individual commands are built into the module and can be viewed by using normal Powershell cmdlets, for example "Get-Help Get-CloudServers".  To get more information, I will be maintaining a small wiki with supported command overviews, future work plans, and more help. It can be found here: 

https://github.com/drmmarsunited/rackspacecloud_powershell/wiki 

<h3>Protips!</h3>

* Protip #1 - Maxmize your window and screen buffer sizes to get the most output possible in your Powershell window.




<b>This is NOT a Rackspace sponsored project. I am a Solutions Engineer with Rackspace and am writing this script as a personal project and eventual contribution into OpenStack.</b>

