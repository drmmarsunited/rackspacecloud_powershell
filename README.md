<h1>Rackspace Cloud API Powershell Client</h1>

<h2>Introduction</h2>

This is a “work in progress” Powershell API client for Rackspace’s public cloud environment.  It is setup to work with Rackspace’s “NextGen” servers, based on Openstack.  The plan is to port this management client to be able to be implemented in ANY Openstack environment, however, no timeframe has been established on this milestone yet.  As with any 3rd party script, please use this module at your own risk.

<h2>Prerequisites</h2>

<b>Rackspace Cloud Account</b>
    
* Username
    
* DDI (account number)
    
* API Key

<b>Windows Management Framework 3.0</b>
    
* [Download WMF 3.0 Here] (http://www.microsoft.com/en-us/download/details.aspx?id=34595)

<h2>How to Install</h2>

The way this script is built is as a Powershell module. By default, PowerShell looks in the paths specified in the $env:PSModulePath environment variable when searching for available modules on a system. This contains two paths out of the box

1.	<b>System Location</b>
    
    a.	 %windir%\System32\WindowsPowerShell\v1.0\Modules 

2.	<b>Currently logged on user location</b>
    
    a.	%UserProfile%\Documents\WindowsPowerShell\Modules

For the sake of ease, place the “RSCloud” folder in the 2nd listed folder above.  Once you’ve placed the folder in its new location, edit the “RSCloud.psm1” with Notepad (or you’re preferred text editor). In this file, the following lines need to be edited with you Rackspace cloud account information:

1.	Set-Variable -Name CloudUsername -Value "Your Username Here" -Scope Global
2.	Set-Variable -Name CloudAPIKey -Value "Your API key here" -Scope Global
3.	Set-Variable -Name CloudDDI -Value "Your account number/DDI here" -Scope Global 

After editing the file, please save it!  You can then launch Powershell, and run “Get-Modules – ListAvailable” to verify that the module is in the list and the commands it offers.

<2>Additional Information</h2>

Help for the commands are going to be built into the module shortly.  Outside of that, I will be maintaining a small wiki here: https://github.com/drmmarsunited/rackspacecloud_powershell/wiki 


This is NOT a Rackspace sponsored project. I am a Solutions Engineer with Rackspace and am writing this script as a personal project and eventual contribution into OpenStack.

