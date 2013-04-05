<h1>PowerClient - Rackspace Cloud API Powershell Client</h1>

<h2>Introduction</h2>

This is a “work in progress” Powershell API client for Rackspace’s public cloud environment.  It is setup to work with Rackspace’s “NextGen” servers, based on Openstack.  The plan is to port this management client to be able to be implemented in ANY Openstack environment, however, no timeframe has been established on this milestone yet.  As with any 3rd party script, please use this module at your own risk.

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

For the sake of ease, place the “PowerClient” folder in the 2nd listed folder above.  Once you’ve placed the folder in its new location, edit the “RSCloud.psm1” with Notepad (or you’re preferred text editor). In this file, the following lines need to be edited with you Rackspace cloud account information:

1.	Set-Variable -Name CloudUsername -Value "Your Username Here" -Scope Global
2.	Set-Variable -Name CloudAPIKey -Value "Your API key here" -Scope Global
3.	Set-Variable -Name CloudDDI -Value "Your account number/DDI here" -Scope Global 

After editing the file, please save it!  You can then launch Powershell, and run "Import-Module PowerClient". At this point, you should be able to run all the commands listed in the wiki (link below) at your leisure. <b>It would also help you to extend your Powershell window and screen buffer size to the maximum your screen can support for easiest reading.</b>

<h2>Additional Information / ProTips</h2>

Help for individual commands are built into the module and can be viewed by using normal Powershell cmdlets, for example "Get-Help Get-CloudServers".  To get more information, I will be maintaining a small wiki with supported command overviews, future work plans, and more help. It can be found here: 

https://github.com/drmmarsunited/rackspacecloud_powershell/wiki 

<h3>Protips!</h3>

* Protip #1 - Maxmize your window and screen buffer sizes to get the most output possible in your Powershell window.




<b>This is NOT a Rackspace sponsored project. I am a Solutions Engineer with Rackspace and am writing this script as a personal project and eventual contribution into OpenStack.</b>

