<#

    .COPYRIGHT
    Copyright (c) Office Center Hønefoss AS. All rights reserved. Licensed under the MIT license.
    See https://github.com/officecenter/Autotask/blob/master/LICENSE.md  for license information.

#>

Function Import-AtwsNestedModule {
  <#
      .SYNOPSIS
      This function re-loads the module with the correct parameters for full functionality
      .DESCRIPTION
      This function is a wrapper that is included for backwards compatibility with previous module behavior.
      These parameters should be passed to Import-Module -Variable directly, but previously the module 
      consisted of two, nested modules. Now there is a single module with all functionality.
      .INPUTS
      A PSCredential object. Required. 
      A string used as ApiTrackingIdentifier. Required. 
      .OUTPUTS
      Nothing.
      .EXAMPLE
      Connect-AtwsWebAPI -Credential $Credential -ApiTrackingIdentifier $String
      .NOTES
      NAME: Connect-AtwsWebAPI
  #>
	
  [cmdletbinding()]
  Param
  (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]    
    [Web.Services.Protocols.SoapHttpClientProtocol]
    $Connection,
    
    [ValidatePattern('[a-zA-Z0-9]')]
    [ValidateLength(1, 8)]
    [String]
    $Prefix = 'Atws',

    [String[]]
    $RefreshEntity
  )
    
  Begin { 
    Write-Verbose ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
    
    # The module is already loaded. It has to be, or this function would not be in
    # the users scope.
    $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
    
    $ModuleName = '{0}-{1}' -F $Prefix, $MyInvocation.MyCommand.Module.Name
    
    # Set us up for cache maintenance
    $Script:Atws = $Connection
    
  }
  
  Process { 
    # Get all function files as file objects
    # Private functions can only be called internally in other functions in the module 
    $PrivateFunction = @( Get-ChildItem -Path $ModuleBase\Private\*.ps1 -ErrorAction SilentlyContinue ) 

    # Public functions will be exported with Prefix prepended to the Noun of the function name
    $PublicFunction = @( Get-ChildItem -Path $ModuleBase\Nested\Public\*.ps1 -ErrorAction SilentlyContinue ) 

    # Static functions will be exported with Prefix prepended to the Noun of the function name
    $StaticFunction = @( Get-ChildItem -Path $ModuleBase\Nested\Static\*.ps1 -ErrorAction SilentlyContinue )   
      
    #Loop through necessary script files and source them
    Foreach ($Import in @($PrivateFunction + $PublicFunction))
    {
      Write-Verbose "Importing $Import"
      try
      {
        . $Import.fullname
      }
      catch
      {
        throw "Could not import function $($Import.fullname): $_"
      }
    }


    # Dynamic functions will be exported with Prefix prepended to the Noun of the function name
    $DynamicCache = '{0}\WindowsPowershell\Cache\{1}\Dynamic' -f $([environment]::GetFolderPath('MyDocuments')), $Connection.CI
    If (-not(Test-Path $DynamicCache)) {
       # No personal dynamic cache yet. Refresh  ALL dynamic entities.
      $RefreshEntity = '*'
    }
    
    # Refresh any entities the caller has ordered'
    # We only consider entities that are dynamic
    If ($RefreshEntity)
    { 
      $Entities = Get-FieldInfo -Dynamic
      $EntitiesToProcess = @()
    
      Foreach ($String in $RefreshEntity)
      {
        $EntitiesToProcess += $Entities.GetEnumerator().Where({$_.Key -like $String})
      }
      
      # Prepare Index for progressbar
      $Index = 0
      $ProgressParameters = @{
        Activity = 'Updating diskcache for requested entities.'
        Id = 10
      }
      Foreach ($EntityToProcess in $EntitiesToProcess)
      {
        $Index++
        $PercentComplete = $Index / $EntitiesToProcess.Count * 100
      
        # Add parameters for @splatting
        $ProgressParameters['PercentComplete'] = $PercentComplete
        $ProgressParameters['Status'] = 'Entity {0}/{1} ({2:n0}%)' -F $Index, $EntitiesToProcess.Count, $PercentComplete
        $ProgressParameters['CurrentOperation'] = 'Getting fieldinfo for {0}' -F $EntityToProcess.Name
      
        Write-Progress @ProgressParameters
      
        $null = Get-FieldInfo -Entity $EntityToProcess.Key -UpdateCache
      }
    
      # Recreate functions that have been updated
      Import-AtwsCmdLet -Entities $EntitiesToProcess
    
    }
    
    # Get any dynamic functions
    $DynamicFunction = @( Get-ChildItem -Path $DynamicCache\*.ps1 -ErrorAction SilentlyContinue )     
        
    # Import the functions as a module
    $ModuleFunctions = Get-Content @($PrivateFunction + $PublicFunction + $StaticFunction + $DynamicFunction) -Raw
    
    $FunctionScriptBlock = [ScriptBlock]::Create($($ModuleFunctions))
    
    $ExportFunctions = @($PublicFunction.Basename + $StaticFunction.Basename + $DynamicFunction.Basename)
        
    New-Module -Name $ModuleName -ScriptBlock $FunctionScriptBlock -Function $ExportFunctions | Import-Module -Global  -Prefix $Prefix  -Force
    
    $Command = 'Set-{0}Connection' -F $Prefix
    
    . $Command -Connection $Connection
    
  }
  
  End {
    Write-Verbose ('{0}: End of function' -F $MyInvocation.MyCommand.Name)
    
    # Clean up the connection info in this script scope
    Remove-Variable -Name Atws -Scope Script -Force -ErrorAction SilentlyContinue
  }
 
}
