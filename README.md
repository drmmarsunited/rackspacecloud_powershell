<h1>PowerClient - Rackspace Cloud API Powershell Client</h1>

<h2> Latest Update(s)</h2>

As of July 16th 2015, this client has been updated to use JSON requests ONLY.  All XML references have been removed at this time.  Several new updates have been introduced:

* Dynamic endpoint URL retrieval from service catalog returned with auth token
* Cloud Server password resets now have their own cmdlet: Update-CloudServerPassword

I have also introduced a global variable called "$Result" that will give you the raw JSON output of the last API request that occurred by the client.

<h2>Who am I and why should you use this client?</h2>

My name is Mitch Robins and I am currently a sales engineer in the SMB segement for Rackspace. Having 15+ years in the IT trenches with Windows (from desktop support to solutions architecture), this was the perfect opportunity to be able to contribute to the Windows community to help with cloud management and adoption. The idea for this client was born out of just that notion.  There was a need for a Windows native API client, and we were in a good position to create something to enable the community at large could use. Over the last few months, we've spent quite a bit of personal and Rackspace sponsored time in getting this tool developed to specifically fill this gap and make life easier for Windows users.  

<h2>What is PowerClient?</h2>

For Rackspace Cloud and Openstack deployments, there is a fantastic CLI called "NovaClient".  It's Python based and works natively within just about any Linux distribution you can think of, and can even be adapted to work in Windows.  However, if you're a systems administrator or work in IT operations as an "uptime czar" like me, you know just how convoluted the process can be of implementing native Linux tools within Windows.  That type of setup just doesn't fly for managing a PRODUCTION deployment.  You want to be able to use natively supported and functional tools, without the potential headache of having something fail because it wasn't meant for use within the Windows eco-system. Enter PowerClient.

PowerClient is a Powershell based API client for Rackspace’s public cloud environment.  It is setup to work with Rackspace’s “Next Gen” servers, powered by Openstack.  The roadmap of this client is to port it for use with ANY Openstack environment, however, no timeframe has been established on this milestone yet.  

This Powershell module utilizes standard function definitions, and can be added to as needed, if you want to enable your own custom cmdlets (please contribute as you see fit!).  Here is an example of one entire cmdlet, including it's help documentation:



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


As with any 3rd party script/module, please use this module at your own risk, even though I have tested it against my own personal account many times.

<h2>Are there any prerequisites I need to run PowerClient?</h2>

There are a few requirements to make sure that PowerClient runs smoothly for you on the PC/server of your choice:

<b>Rackspace Cloud Account</b>

All of the fullowing information can be obtained from the [Rackspace Cloud Control Panel] (https://mycloud.rackspace.com/):
    
* Username
    
* DDI (account number)
    
* API Key

<b>.NET & Windows Management Framework 3.0, Respectively</b>
    
* [Download .NET Here] (http://www.microsoft.com/en-us/download/details.aspx?id=17851)

* [Download WMF 3.0 Here] (http://www.microsoft.com/en-us/download/details.aspx?id=34595)
 
<b>Powershell Execution Policy</b>

* This script is not yet signed.  In order for this module to be properly imported, please run "Set-ExecutionPolicy RemoteSigned" (more secure) OR "Set-ExecutionPolicy Unrestricted", as a local/domain admin on your server. <b> Please note, if you have UAC enabled, you must run Powershell "as an administrator" to be able to manipulate execution policy.</b>

<h2>How does PowerClient get installed?</h2>

The way this script is built is as a Powershell module. Start by downloading as a ZIP file [HERE] (https://github.com/drmmarsunited/rackspacecloud_powershell/archive/master.zip). By default, PowerShell looks in the paths specified in the $env:PSModulePath environment variable when searching for available modules on a system. This contains two paths out of the box

1.    <b>System Location</b>
    
    a.     %windir%\System32\WindowsPowerShell\v1.0\Modules 

2.	<b>Currently logged on user location</b>
    
    a.	%UserProfile%\Documents\WindowsPowerShell\Modules

For the sake of ease, place the “PowerClient” folder in the 2nd listed folder above. Once done, please invoke the following cmdlets to set the authentication for the program.

```Powershell
Set-AccountAuthentication -CloudUsername 'username' -CloudAPIKey 'key' -CloudDDI ddi
Set-CoreAccountAuthentication -CloudUsername 'username' -CloudAPIKey 'key' -CloudDDI ddi
```

Having to set two authentication commands prior to using the module is not ideal. Additional work will be done moving forward to simplify this process.

<h2>Are there any other sources for information or tips for PowerClient?</h2>

Help for individual commands are built into the module and can be viewed by using normal Powershell cmdlets, for example "Get-Help Get-CloudServers".  To get more information, I will be maintaining a small wiki with supported command overviews, future work plans, and more help. It can be found here: 

https://github.com/drmmarsunited/rackspacecloud_powershell/wiki 

<h3>Pro tips!</h3>

* Pro tip #1 - Maximize your window and screen buffer sizes to get the most output possible in your Powershell window.
* Pro tip #2 - Towards the top of the module, every command has an alias that is commented out.  You can uncomment these lines to make using this module even easier for yourself and other administrators.
