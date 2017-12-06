﻿<#

.COPYRIGHT
Copyright (c) Office Center Hønefoss AS. All rights reserved. Based on code from Jan Egil Ring (Crayon). Licensed under the MIT license.
See https://github.com/officecenter/OCH-Public/blob/master/LICENSE for license information.

#>

Function Get-AtwsInvoiceTemplate
{
  <#
      .SYNOPSIS
      This function get a InvoiceTemplate through the Autotask Web Services API.
      .DESCRIPTION
      This function get a InvoiceTemplate through the Autotask Web Services API.
      .EXAMPLE
      Get-AtwsInvoiceTemplate [-ParameterName] [Parameter value]
      Use Get-Help Get-AtwsInvoiceTemplate
      .NOTES
      NAME: Get-AtwsInvoiceTemplate
  #>
	  [CmdLetBinding(DefaultParameterSetName='Filter')]
    Param
    (
                [Parameter(
          Mandatory = $true,
          ValueFromRemainingArguments = $true,
          ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Filter ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [long]
         $id
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $DisplayTaxCategory
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $DisplayTaxCategorySuperscripts
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $DisplaySeparateLineItemForEachTax
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [ValidateSet('None','All by Billing Code','Labor by Contract','Labor by Project','Labor by Project & Phase','Labor by Resource','Labor by Role','Labor by Task/Ticket','Labor by Task/Ticket & Work Type','Labor by Work Type','All by Grouping Description')]

        [String]
         $GroupBy
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [ValidateSet('Do not itemize','Itemize within each group','Itemize at end of invoice')]

        [String]
         $ItemizeItemsInEachGroup
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [ValidateSet('Item Type, then Date','Item Type, then Item','Item Type, then Task/Ticket Number, then Date','Task/Ticket Number, then Date, then Item Type','Date, then Item Type, then Item')]

        [String]
         $SortBy
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $ItemizeServicesAndBundles
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $DisplayZeroAmountRecurringServicesAndBundles
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $DisplayRecurringServiceContractLabor
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $DisplayFixedPriceContractLabor
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [string]
         $RateCostExpression
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [string]
         $CoveredByRecurringServiceFixedPricePerTicketContractLabel
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [string]
         $CoveredByBlockRetainerContractLabel
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [string]
         $NonBillableLaborLabel
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [ValidateSet('A4: 8.25" x 11.75 (210 mm x 297 mm)','Letter: 8.5" x 11" (215.9 mm x 279.4 mm)')]

        [String]
         $PageLayout
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [Int]
         $PaymentTerms
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [Int]
         $PageNumberFormat
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [ValidateSet('MM/dd/yyyy','MM/dd/yy','dd/MM/yyyy','dd/MM/yy','yyyy/MM/dd','yy/MM/dd','MM-dd-yyyy','MM-dd-yy','dd-MM-yyyy','dd-MM-yy','yyyy-MM-dd','yy-MM-dd','MM.dd.yyyy','MM.dd.yy','dd.MM.yyyy','dd.MM.yy','yyyy.MM.dd','yy.MM.dd')]

        [String]
         $DateFormat
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [ValidateSet('X,XXX.XX','X.XXX,XX')]

        [String]
         $NumberFormat
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [ValidateSet('hh:mm tt','h:mm tt','HH:mm')]

        [String]
         $TimeFormat
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [string]
         $Name
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $ShowGridHeader
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [boolean]
         $ShowVerticalGridLines
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [string]
         $CurrencyPositiveFormat
 ,

        [Parameter(
          Mandatory = $False,
          ParameterSetName = 'By_parameters'
        )]
         [string]
         $CurrencyNegativeFormat

    )



          

  Begin
  { 
    If (-not($global:atws.Url))
    {
      Throw [ApplicationException] 'Not connected to Autotask WebAPI. Run Connect-AutotaskWebAPI first.'
    }
    Write-Verbose ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)

  }   

  Process
  {     

    If (-not($Filter))
    {
        $Fields = $Atws.GetFieldInfo('InvoiceTemplate')
        
        Foreach ($Parameter in $PSBoundParameters.GetEnumerator())
        {
            $Field = $Fields | Where-Object {$_.Name -eq $Parameter.Key}
            If ($Field.IsPickList)
            {
              $PickListValue = $Field.PickListValues | Where-Object {$_.Label -eq $Parameter.Value}
              $Value = $PickListValue.Value
            }
            Else
            {
              $Value = $Parameter.Value
            }
            $Filter += $Parameter.Key
            $Filter += '-eq'
            $Filter += $Value
        }
        
    }

    Get-AtwsData -Entity InvoiceTemplate -Filter $Filter }   

  End
  {
    Write-Verbose ('{0}: End of function' -F $MyInvocation.MyCommand.Name)

  }


        
}