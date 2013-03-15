Rackspace Cloud API Powershell Client

Introduction
This is a “work in progress” Powershell API client for Rackspace’s public cloud environment.  It is setup to work with Rackspace’s “NextGen” servers, based on Openstack.  The plan is to port this management client to be able to be implemented in ANY Openstack environment, however, no timeframe has been established on this milestone yet.  As with any 3rd party script, please use this module at your own risk.

Prerequisites
•	Rackspace Cloud Account
    o    Username
    o	DDI (account number)
    o	API Key

•	Windows Management Framework 3.0
    o	http://www.microsoft.com/en-us/download/details.aspx?id=34595 

How to Install
The way this script is built is as a Powershell module. By default, PowerShell looks in the paths specified in the $env:PSModulePath environment variable when searching for available modules on a system. This contains two paths out of the box

1.	System Location
    a.	 %windir%\System32\WindowsPowerShell\v1.0\Modules 
2.	Currently logged on user location 
    a.	%UserProfile%\Documents\WindowsPowerShell\Modules

For the sake of ease, place the “RSCloud” folder in the 2nd listed folder above.  Once you’ve placed the folder in its new location, edit the “RSCloud.psm1” with Notepad (or you’re preferred text editor). In this file, the following lines need to be edited with you Rackspace cloud account information:

1.	Set-Variable -Name CloudUsername -Value "Your Username Here" -Scope Global
2.	Set-Variable -Name CloudAPIKey -Value "Your API key here" -Scope Global
3.	Set-Variable -Name CloudDDI -Value "Your account number/DDI here" -Scope Global 

After editing the file, please save it!  You can then launch Powershell, and run “Get-Modules – ListAvailable” to verify that the module is in the list and the commands it offers.

Additional Information
Help for the commands are going to be built into the module shortly.  Outside of that, I will be maintaining a small wiki here: https://github.com/drmmarsunited/rackspacecloud_powershell/wiki 




