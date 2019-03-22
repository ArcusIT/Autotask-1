<#
    .COPYRIGHT
    Copyright (c) Office Center Hønefoss AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/officecenter/Autotask/blob/master/LICENSE.md  for license information.
#>


# Special consideration for -Verbose, as there is no $PSCmdLet context to check if Import-Module was called using -Verbose
# and $VerbosePreference is not inherited from Import-Module for some reason.

# Remove comments
$ParentCommand = ($MyInvocation.Line -split '#')[0]

# Store Previous preference
$OldPreference = $VerbosePreference
If ($ParentCommand -like '*-Verbose*') {
  $VerbosePreference = 'Continue'
}


# Get all function files as file objects
# Private functions can only be called internally in other functions in the module 
$PrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue ) 
$PublicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue ) 

foreach ($Import in @($PrivateFunctions + $PublicFunctions )) {
  Write-Verbose "Importing $Import"
  try {
    . $Import.fullname
  }
  catch {
    throw "Could not import function $($Import.fullname): $_"
  }
}

# Explicitly export public functions
Export-ModuleMember -Function $PublicFunctions.Basename

# Restore Previous preference
If ($OldPreference -ne $VerbosePreference) {
  $VerbosePreference = $OldPreference
}