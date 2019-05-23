﻿#Requires -Version 4.0
#Version 1.6.2.8
<#

.COPYRIGHT
Copyright (c) Office Center Hønefoss AS. All rights reserved. Based on code from Jan Egil Ring (Crayon). Licensed under the MIT license.
See https://github.com/officecenter/Autotask/blob/master/LICENSE.md for license information.

#>
Function Get-AtwsAccount
{


<#
.SYNOPSIS
This function get one or more Account through the Autotask Web Services API.
.DESCRIPTION
This function creates a query based on any parameters you give and returns any resulting objects from the Autotask Web Services Api. By default the function returns any objects with properties that are Equal (-eq) to the value of the parameter. To give you more flexibility you can modify the operator by using -NotEquals [ParameterName[]], -LessThan [ParameterName[]] and so on.

Possible operators for all parameters are:
 -NotEquals
 -GreaterThan
 -GreaterThanOrEqual
 -LessThan
 -LessThanOrEquals 

Additional operators for [String] parameters are:
 -Like (supports * or % as wildcards)
 -NotLike
 -BeginsWith
 -EndsWith
 -Contains

Properties with picklists are:

AccountType
 

KeyAccountIcon
 

TerritoryID
 

MarketSegmentID
 

CompetitorID
 

BillToAddressToUse
 

InvoiceMethod
 

Entities that have fields that refer to the base entity of this CmdLet:

Account
 AccountAlert
 AccountLocation
 AccountNote
 AccountPhysicalLocation
 AccountTeam
 AccountToDo
 BillingItem
 Contact
 Contract
 ContractServiceUnit
 ExpenseItem
 InstalledProduct
 Invoice
 NotificationHistory
 Opportunity
 Product
 ProductVendor
 Project
 PurchaseOrder
 Quote
 SalesOrder
 Service
 ServiceCall
 Subscription
 SurveyResults
 Ticket

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.Account[]]. This function outputs the Autotask.Account that was returned by the API.
.EXAMPLE
Get-AtwsAccount -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-AtwsAccount -AccountName SomeName
Returns the object with AccountName 'SomeName', if any.
 .EXAMPLE
Get-AtwsAccount -AccountName 'Some Name'
Returns the object with AccountName 'Some Name', if any.
 .EXAMPLE
Get-AtwsAccount -AccountName 'Some Name' -NotEquals AccountName
Returns any objects with a AccountName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-AtwsAccount -AccountName SomeName* -Like AccountName
Returns any object with a AccountName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsAccount -AccountName SomeName* -NotLike AccountName
Returns any object with a AccountName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label>
Returns any Accounts with property AccountType equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label> -NotEquals AccountType 
Returns any Accounts with property AccountType NOT equal to the <PickList Label>.
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label1>, <PickList Label2>
Returns any Accounts with property AccountType equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-AtwsAccount -AccountType <PickList Label1>, <PickList Label2> -NotEquals AccountType
Returns any Accounts with property AccountType NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-AtwsAccount -Id 1234 -AccountName SomeName* -AccountType <PickList Label1>, <PickList Label2> -Like AccountName -NotEquals AccountType -GreaterThan Id
An example of a more complex query. This command returns any Accounts with Id GREATER THAN 1234, a AccountName that matches the simple pattern SomeName* AND that has a AccountType that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-AtwsAccount
 .LINK
Set-AtwsAccount

#>

  [CmdLetBinding(DefaultParameterSetName='Filter', ConfirmImpact='None')]
  Param
  (
# A filter that limits the number of objects that is returned from the API
    [Parameter(
      Mandatory = $true,
      ValueFromRemainingArguments = $true,
      ParameterSetName = 'Filter'
    )]
    [ValidateNotNullOrEmpty()]
    [String[]]
    $Filter,

# Follow this external ID and return any external objects
    [Parameter(
      ParameterSetName = 'Filter'
    )]
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Alias('GetRef')]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('OwnerResourceID', 'ParentAccountID', 'TaxRegionID', 'CountryID', 'BillToCountryID', 'QuoteTemplateID', 'InvoiceTemplateID', 'CurrencyID', 'BillToAccountPhysicalLocationID')]
    [String]
    $GetReferenceEntityById,

# Return entities of selected type that are referencing to this entity.
    [Parameter(
      ParameterSetName = 'Filter'
    )]
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Alias('External')]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('SalesOrder:AccountID', 'Project:AccountID', 'Invoice:AccountID', 'Service:VendorAccountID', 'Contact:AccountID', 'Account:ParentAccountID', 'AccountTeam:AccountID', 'NotificationHistory:AccountID', 'Contract:AccountID', 'Contract:BillToAccountID', 'ServiceCall:AccountID', 'Subscription:VendorID', 'BillingItem:AccountID', 'BillingItem:VendorID', 'Ticket:AccountID', 'InstalledProduct:AccountID', 'InstalledProduct:VendorID', 'ContractServiceUnit:VendorAccountID', 'AccountPhysicalLocation:AccountID', 'PurchaseOrder:VendorID', 'PurchaseOrder:PurchaseForAccountID', 'ProductVendor:VendorID', 'Product:DefaultVendorID', 'ExpenseItem:AccountID', 'AccountAlert:AccountID', 'AccountNote:AccountID', 'Quote:AccountID', 'Opportunity:AccountID', 'SurveyResults:AccountID', 'AccountToDo:AccountID', 'AccountLocation:AccountID')]
    [String]
    $GetExternalEntityByThisEntityId,

# Return all objects in one query
    [Parameter(
      ParameterSetName = 'Get_all'
    )]
    [Switch]
    $All,

# Do not add descriptions for all picklist attributes with values
    [Parameter(
      ParameterSetName = 'Filter'
    )]
    [Parameter(
      ParameterSetName = 'Get_all'
    )]
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Switch]
    $NoPickListLabel,

# A single user defined field can be used pr query
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Alias('UDF')]
    [ValidateNotNullOrEmpty()]
    [Autotask.UserDefinedField]
    $UserDefinedField,

# Client ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [long[]]
    $id,

# Client Name
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Alias('Name')]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,100)]
    [string[]]
    $AccountName,

# Address 1
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,128)]
    [string[]]
    $Address1,

# Address 2
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,128)]
    [string[]]
    $Address2,

# City
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,30)]
    [string[]]
    $City,

# County
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,40)]
    [string[]]
    $State,

# Postal Code
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,10)]
    [string[]]
    $PostalCode,

# Country
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,100)]
    [string[]]
    $Country,

# Phone
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,25)]
    [string[]]
    $Phone,

# Alternate Phone 1
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,25)]
    [string[]]
    $AlternatePhone1,

# Alternate Phone 2
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,25)]
    [string[]]
    $AlternatePhone2,

# Fax
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,25)]
    [string[]]
    $Fax,

# Web
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,255)]
    [string[]]
    $WebAddress,

# Client Type
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [String[]]
    $AccountType,

# Key Account Icon
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [String[]]
    $KeyAccountIcon,

# Client Owner
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int[]]
    $OwnerResourceID,

# Territory Name
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [String[]]
    $TerritoryID,

# Market Segment
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [String[]]
    $MarketSegmentID,

# Competitor
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [String[]]
    $CompetitorID,

# Parent Client
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $ParentAccountID,

# Client Number
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $AccountNumber,

# Create Date
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $CreateDate,

# Last Activity Date
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $LastActivityDate,

# Account Active
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $Active,

# TaskFire Active
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $TaskFireActive,

# Client Portal Active
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $ClientPortalActive,

# Tax Region ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $TaxRegionID,

# Tax Exempt
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $TaxExempt,

# Tax ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $TaxID,

# Additional Address Information
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,100)]
    [string[]]
    $AdditionalAddressInformation,

# Country ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $CountryID,

# Bill To Address to Use
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [String[]]
    $BillToAddressToUse,

# Bill To Attention
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $BillToAttention,

# Bill To Address Line 1
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,150)]
    [string[]]
    $BillToAddress1,

# Bill To Address Line 2
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,150)]
    [string[]]
    $BillToAddress2,

# Bill To City
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $BillToCity,

# Bill To County
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,128)]
    [string[]]
    $BillToState,

# Bill To Postal Code
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $BillToZipCode,

# Bill To Country ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $BillToCountryID,

# Bill To Additional Address Information
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,100)]
    [string[]]
    $BillToAdditionalAddressInformation,

# Transmission Method
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [String[]]
    $InvoiceMethod,

# Invoice non contract items to Parent Client
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $InvoiceNonContractItemsToParentAccount,

# Quote Template ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $QuoteTemplateID,

# Quote Email Message ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $QuoteEmailMessageID,

# Invoice Template ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $InvoiceTemplateID,

# Invoice Email Message ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $InvoiceEmailMessageID,

# Currency ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $CurrencyID,

# Bill To Account Physical Location ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $BillToAccountPhysicalLocationID,

# Survey Account Rating
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [double[]]
    $SurveyAccountRating,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'Active', 'TaskFireActive', 'ClientPortalActive', 'TaxRegionID', 'TaxExempt', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'InvoiceNonContractItemsToParentAccount', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'UserDefinedField')]
    [String[]]
    $NotEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'Active', 'TaskFireActive', 'ClientPortalActive', 'TaxRegionID', 'TaxExempt', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'InvoiceNonContractItemsToParentAccount', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'UserDefinedField')]
    [String[]]
    $IsNull,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'Active', 'TaskFireActive', 'ClientPortalActive', 'TaxRegionID', 'TaxExempt', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'InvoiceNonContractItemsToParentAccount', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'UserDefinedField')]
    [String[]]
    $IsNotNull,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'UserDefinedField')]
    [String[]]
    $GreaterThan,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'UserDefinedField')]
    [String[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'UserDefinedField')]
    [String[]]
    $LessThan,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountType', 'KeyAccountIcon', 'OwnerResourceID', 'TerritoryID', 'MarketSegmentID', 'CompetitorID', 'ParentAccountID', 'AccountNumber', 'CreateDate', 'LastActivityDate', 'TaxRegionID', 'TaxID', 'AdditionalAddressInformation', 'CountryID', 'BillToAddressToUse', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToCountryID', 'BillToAdditionalAddressInformation', 'InvoiceMethod', 'QuoteTemplateID', 'QuoteEmailMessageID', 'InvoiceTemplateID', 'InvoiceEmailMessageID', 'CurrencyID', 'BillToAccountPhysicalLocationID', 'SurveyAccountRating', 'UserDefinedField')]
    [String[]]
    $LessThanOrEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [String[]]
    $Like,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [String[]]
    $NotLike,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [String[]]
    $BeginsWith,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [String[]]
    $EndsWith,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AccountName', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'Country', 'Phone', 'AlternatePhone1', 'AlternatePhone2', 'Fax', 'WebAddress', 'AccountNumber', 'TaxID', 'AdditionalAddressInformation', 'BillToAttention', 'BillToAddress1', 'BillToAddress2', 'BillToCity', 'BillToState', 'BillToZipCode', 'BillToAdditionalAddressInformation', 'UserDefinedField')]
    [String[]]
    $Contains,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('CreateDate', 'LastActivityDate', 'UserDefinedField')]
    [String[]]
    $IsThisDay
  )

  Begin
  { 
    $EntityName = 'Account'
    
    # Enable modern -Debug behavior
    If ($PSCmdlet.MyInvocation.BoundParameters['Debug'].IsPresent) {$DebugPreference = 'Continue'}
    
    Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
  }


  Process
  {
    If ($PSCmdlet.ParameterSetName -eq 'Get_all')
    { 
      $Filter = @('id', '-ge', 0)
    }
    ElseIf (-not ($Filter)) {
    
      Write-Debug ('{0}: Query based on parameters, parsing' -F $MyInvocation.MyCommand.Name)
      
      # Convert named parameters to a filter definition that can be parsed to QueryXML
      $Filter = ConvertTo-AtwsFilter -BoundParameters $PSBoundParameters -EntityName $EntityName
    }
    Else {
      
      Write-Debug ('{0}: Query based on manual filter, parsing' -F $MyInvocation.MyCommand.Name)
              
      $Filter = . Update-AtwsFilter -FilterString $Filter
    } 

    $Result = Get-AtwsData -Entity $EntityName -Filter $Filter

    Write-Verbose ('{0}: Number of entities returned by base query: {1}' -F $MyInvocation.MyCommand.Name, $Result.Count)
    
    # Datetimeparameters
    $Fields = Get-AtwsFieldInfo -Entity $EntityName
    
    # Should we return an indirect object?
    if ( ($Result) -and ($GetReferenceEntityById))
    {
      Write-Debug ('{0}: User has asked for external reference objects by {1}' -F $MyInvocation.MyCommand.Name, $GetReferenceEntityById)
      
      $Field = $Fields.Where({$_.Name -eq $GetReferenceEntityById})
      $ResultValues = $Result | Where-Object {$null -ne $_.$GetReferenceEntityById}
      If ($ResultValues.Count -lt $Result.Count)
      {
        Write-Warning ('{0}: Only {1} of the {2}s in the primary query had a value in the property {3}.' -F $MyInvocation.MyCommand.Name, 
          $ResultValues.Count,
          $EntityName,
        $GetReferenceEntityById) -WarningAction Continue
      }
      $Filter = 'id -eq {0}' -F $($ResultValues.$GetReferenceEntityById -join ' -or id -eq ')
      $Result = Get-Atwsdata -Entity $Field.ReferenceEntityType -Filter $Filter
    }
    ElseIf ( ($Result) -and ($GetExternalEntityByThisEntityId))
    {
      Write-Debug ('{0}: User has asked for {1} that are referencing this result' -F $MyInvocation.MyCommand.Name, $GetExternalEntityByThisEntityId)
      $ReferenceInfo = $GetExternalEntityByThisEntityId -Split ':'
      $Filter = '{0} -eq {1}' -F $ReferenceInfo[1], $($Result.id -join (' -or {0}id -eq ' -F $ReferenceInfo[1]))
      $Result = Get-Atwsdata -Entity $ReferenceInfo[0] -Filter $Filter
     }
    # Do the user want labels along with index values for Picklists?
    ElseIf ( ($Result) -and -not ($NoPickListLabel))
    {
      Foreach ($Field in $Fields.Where{$_.IsPickList})
      {
        $FieldName = '{0}Label' -F $Field.Name
        Foreach ($Item in $Result)
        {
          $Value = ($Field.PickListValues.Where{$_.Value -eq $Item.$($Field.Name)}).Label
          Add-Member -InputObject $Item -MemberType NoteProperty -Name $FieldName -Value $Value -Force
          
        }
      }
    }
  }

  End
  {
    Write-Debug ('{0}: End of function' -F $MyInvocation.MyCommand.Name)
    If ($Result)
    {
      Return $Result
    }
  }


}
