#
# Module manifest for module 'module'
#
# Generated by: 
#
# Generated on: 
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = 'Module.psd1'

# Version number of this module.
ModuleVersion = '1.2'

# ID used to uniquely identify this module
GUID = 'aab9ae6a-1392-4814-849f-fc69e124dadd'

# Author of this module
Author = 'Karsten Bott'

# Company or vendor of this module
CompanyName = 'DELLEMC'

# Copyright statement for this module
Copyright = '(c) 2014 . All rights reserved.'

# Description of the functionality provided by this module
Description = 'OS_DPE_SHELL is a Powershell Scripting extension to DELLEMC´s AVAMAR Openstack Data Protection Extension'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()



# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @(
'.\Formats\OS_DPE_SHELL.OSProject.Format.ps1xml',
'.\Formats\OS_DPE_SHELL.DPEInstance.Format.ps1xml',
'.\Formats\OS_DPE_SHELL.DPEProtectionProvider.Format.ps1xml',
'.\Formats\OS_DPE_SHELL.OSUser.Format.ps1xml',
'.\Formats\OS_DPE_SHELL.DPEBackup.Format.ps1xml',
'.\Formats\OS_DPE_SHELL.DPETask.Format.ps1xml',
'.\Formats\OS_DPE_SHELL.DPEJob.Format.ps1xml'
'.\Formats\OS_DPE_SHELL.DPEDataset.Format.ps1xml')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('.\os_dpe_shell.psm1')

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @('os_dpe_shell.psd1',
'os_dpe_shell.psm1')

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = 'https://github.com/bottkars/os_dpe_shell/wiki'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

