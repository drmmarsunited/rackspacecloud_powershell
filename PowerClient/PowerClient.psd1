#
# Manifest for PowerClient
#

@{

# Script module or binary module file associated with this manifest
RootModule = 'IdentityProvider.psm1'

# Version number of this module.
ModuleVersion = '2.1'

# ID used to uniquely identify this module
GUID = '29125ff3-f79a-4812-8573-92468eeecd11'

# Author of this module
Author = 'Mitch Robins (mitch.robins)'

# Company or vendor of this module
# CompanyName = ''

# Copyright statement for this module
# Copyright = ''

# Description of the functionality provided by this module
Description = 'PowerShell module for OpenStack Cloud API interaction (PowerClient)'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '2.0'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('Authentication.psm1')

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
ModuleList = @(
    'Authentication.psm1',
    'IdentityProvider.psm1',
    '.\Providers\Rackspace.psm1'
)

# List of all files packaged with this module
FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
PrivateData = @{ 
    identityProvider = "Rackspace";
    cloudUsername = "";
    cloudAPIKey = "";
    cloudDDI = "";
}

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}