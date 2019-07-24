﻿#Requires -Version 4.0
#Version 1.6.2.16
<#

.COPYRIGHT
Copyright (c) Office Center Hønefoss AS. All rights reserved. Based on code from Jan Egil Ring (Crayon). Licensed under the MIT license.
See https://github.com/officecenter/Autotask/blob/master/LICENSE.md for license information.

#>
Function New-AtwsProductTier
{


<#
.SYNOPSIS
This function creates a new ProductTier through the Autotask Web Services API. All required properties are marked as required parameters to assist you on the command line.
.DESCRIPTION
The function supports all properties of an [Autotask.ProductTier] that can be updated through the Web Services API. The function uses PowerShell parameter validation  and supports IntelliSense for selecting picklist values. Any required paramterer is marked as Mandatory in the PowerShell function to assist you on the command line.

If you need very complicated queries you can write a filter directly and pass it using the -Filter parameter. To get the ProductTier with Id number 0 you could write 'New-AtwsProductTier -Id 0' or you could write 'New-AtwsProductTier -Filter {Id -eq 0}.

'New-AtwsProductTier -Id 0,4' could be written as 'New-AtwsProductTier -Filter {id -eq 0 -or id -eq 4}'. For simple queries you can see that using parameters is much easier than the -Filter option. But the -Filter option supports an arbitrary sequence of most operators (-eq, -ne, -gt, -ge, -lt, -le, -and, -or, -beginswith, -endswith, -contains, -like, -notlike, -soundslike, -isnotnull, -isnull, -isthisday). As you can group them using parenthesis '()' you can write arbitrarily complex queries with -Filter. 

To create a new ProductTier you need the following required fields:
 -ProductID
 -UnitCost
 -UnitPrice

Entities that have fields that refer to the base entity of this CmdLet:

PriceListProductTier

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.ProductTier]. This function outputs the Autotask.ProductTier that was created by the API.
.EXAMPLE
$Result = New-AtwsProductTier -ProductID [Value] -UnitCost [Value] -UnitPrice [Value]
Creates a new [Autotask.ProductTier] through the Web Services API and returns the new object.
 .EXAMPLE
$Result = Get-AtwsProductTier -Id 124 | New-AtwsProductTier 
Copies [Autotask.ProductTier] by Id 124 to a new object through the Web Services API and returns the new object.
 .EXAMPLE
Get-AtwsProductTier -Id 124 | New-AtwsProductTier | Set-AtwsProductTier -ParameterName <Parameter Value>
Copies [Autotask.ProductTier] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsProductTier to modify the object.
 .EXAMPLE
$Result = Get-AtwsProductTier -Id 124 | New-AtwsProductTier | Set-AtwsProductTier -ParameterName <Parameter Value> -Passthru
Copies [Autotask.ProductTier] by Id 124 to a new object through the Web Services API, passes the new object to the Set-AtwsProductTier to modify the object and returns the new object.

.LINK
Remove-AtwsProductTier
 .LINK
Get-AtwsProductTier
 .LINK
Set-AtwsProductTier

#>

  [CmdLetBinding(SupportsShouldProcess = $True, DefaultParameterSetName='By_parameters', ConfirmImpact='Low')]
  Param
  (
# An array of objects to create
    [Parameter(
      ParameterSetName = 'Input_Object',
      ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [Autotask.ProductTier[]]
    $InputObject,

# Product ID
    [Parameter(
      Mandatory = $true,
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int]
    $ProductID,

# Up To Unit Count
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [decimal]
    $UpToUnitCount,

# Unit Cost
    [Parameter(
      Mandatory = $true,
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [decimal]
    $UnitCost,

# Unit Price
    [Parameter(
      Mandatory = $true,
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [decimal]
    $UnitPrice
  )
 
  Begin
  { 
    $EntityName = 'ProductTier'
           
    # Enable modern -Debug behavior
    If ($PSCmdlet.MyInvocation.BoundParameters['Debug'].IsPresent) {$DebugPreference = 'Continue'}
    
    Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
    
    $ProcessObject = @()
  }

  Process
  {
    $Fields = Get-AtwsFieldInfo -Entity $EntityName
    
    If ($InputObject)
    {
      Write-Verbose ('{0}: Copy Object mode: Setting ID property to zero' -F $MyInvocation.MyCommand.Name)  
      
      $CopyNo = 1

      Foreach ($Object in $InputObject) 
      { 
        # Create a new object and copy properties
        $NewObject = New-Object Autotask.$EntityName
        
        # Copy every non readonly property
        $FieldNames = $Fields.Where({$_.Name -ne 'id'}).Name
        If ($PSBoundParameters.ContainsKey('UserDefinedFields')) {
          $FieldNames += 'UserDefinedFields'
        }
        Foreach ($Field in $FieldNames)
        {
          $NewObject.$Field = $Object.$Field
        }
        If ($NewObject -is [Autotask.Ticket])
        {
          Write-Verbose ('{0}: Copy Object mode: Object is a Ticket. Title must be modified to avoid duplicate detection.' -F $MyInvocation.MyCommand.Name)  
          $Title = '{0} (Copy {1})' -F $NewObject.Title, $CopyNo
          $CopyNo++
          $NewObject.Title = $Title
        }
        $ProcessObject += $NewObject
      }   
    }
    Else
    {
      Write-Debug ('{0}: Creating empty [Autotask.{1}]' -F $MyInvocation.MyCommand.Name, $EntityName) 
      $ProcessObject += New-Object Autotask.$EntityName    
    }
    
    Foreach ($Parameter in $PSBoundParameters.GetEnumerator())
    {
      $Field = $Fields | Where-Object {$_.Name -eq $Parameter.Key}
      If ($Field -or $Parameter.Key -eq 'UserDefinedFields')
      { 
        If ($Field.IsPickList)
        {
          If($Field.PickListParentValueField)
          {
            $ParentField = $Fields.Where{$_.Name -eq $Field.PickListParentValueField}
            $ParentLabel = $PSBoundParameters.$($ParentField.Name)
            $ParentValue = $ParentField.PickListValues | Where-Object {$_.Label -eq $ParentLabel}
            $PickListValue = $Field.PickListValues | Where-Object {$_.Label -eq $Parameter.Value -and $_.ParentValue -eq $ParentValue.Value}                
          }
          Else 
          { 
            $PickListValue = $Field.PickListValues | Where-Object {$_.Label -eq $Parameter.Value}
          }
          $Value = $PickListValue.Value
        }
        Else
        {
          $Value = $Parameter.Value
        } 

        Foreach ($Object in $ProcessObject) 
        { 
          $Object.$($Parameter.Key) = $Value
        }
      }
    }   
     
    $Caption = $MyInvocation.MyCommand.Name
    $VerboseDescrition = '{0}: About to create {1} {2}(s). This action cannot be undone.' -F $Caption, $ProcessObject.Count, $EntityName
    $VerboseWarning = '{0}: About to create {1} {2}(s). This action may not be undoable. Do you want to continue?' -F $Caption, $ProcessObject.Count, $EntityName

    If ($PSCmdlet.ShouldProcess($VerboseDescrition, $VerboseWarning, $Caption)) { 
      $Result = New-AtwsData -Entity $ProcessObject
    }
  }

  End
  {
    Write-Debug ('{0}: End of function, returning {1} {2}(s)' -F $MyInvocation.MyCommand.Name, $Result.count, $EntityName)
    Return $Result
  }

}