﻿#Requires -Version 4.0
<#

.COPYRIGHT
Copyright (c) Office Center Hønefoss AS. All rights reserved. Based on code from Jan Egil Ring (Crayon). Licensed under the MIT license.
See https://github.com/officecenter/Autotask/blob/master/LICENSE.md for license information.

#>
Function Get-BusinessLocation
{


<#
.SYNOPSIS
This function get one or more BusinessLocation through the Autotask Web Services API.
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

FirstDayOfWeek
 

DateFormat
 

TimeFormat
 

NumberFormat
 

TimeZoneID
 

Entities that have fields that refer to the base entity of this CmdLet:

Department

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.BusinessLocation[]]. This function outputs the Autotask.BusinessLocation that was returned by the API.
.EXAMPLE
Get-BusinessLocation -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-BusinessLocation -BusinessLocationName SomeName
Returns the object with BusinessLocationName 'SomeName', if any.
 .EXAMPLE
Get-BusinessLocation -BusinessLocationName 'Some Name'
Returns the object with BusinessLocationName 'Some Name', if any.
 .EXAMPLE
Get-BusinessLocation -BusinessLocationName 'Some Name' -NotEquals BusinessLocationName
Returns any objects with a BusinessLocationName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-BusinessLocation -BusinessLocationName SomeName* -Like BusinessLocationName
Returns any object with a BusinessLocationName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-BusinessLocation -BusinessLocationName SomeName* -NotLike BusinessLocationName
Returns any object with a BusinessLocationName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-BusinessLocation -FirstDayOfWeek <PickList Label>
Returns any BusinessLocations with property FirstDayOfWeek equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-BusinessLocation -FirstDayOfWeek <PickList Label> -NotEquals FirstDayOfWeek 
Returns any BusinessLocations with property FirstDayOfWeek NOT equal to the <PickList Label>.
 .EXAMPLE
Get-BusinessLocation -FirstDayOfWeek <PickList Label1>, <PickList Label2>
Returns any BusinessLocations with property FirstDayOfWeek equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-BusinessLocation -FirstDayOfWeek <PickList Label1>, <PickList Label2> -NotEquals FirstDayOfWeek
Returns any BusinessLocations with property FirstDayOfWeek NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-BusinessLocation -Id 1234 -BusinessLocationName SomeName* -FirstDayOfWeek <PickList Label1>, <PickList Label2> -Like BusinessLocationName -NotEquals FirstDayOfWeek -GreaterThan Id
An example of a more complex query. This command returns any BusinessLocations with Id GREATER THAN 1234, a BusinessLocationName that matches the simple pattern SomeName* AND that has a FirstDayOfWeek that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-BusinessLocation
 .LINK
Set-BusinessLocation

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
    [ValidateSet('CountryID', 'HolidaySetID')]
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
    [ValidateSet('Department:PrimaryLocationID')]
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

# Business Location ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [long[]]
    $id,

# Name
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,100)]
    [string[]]
    $Name,

# Address1
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,100)]
    [string[]]
    $Address1,

# Address2
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,100)]
    [string[]]
    $Address2,

# City
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $City,

# State
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,25)]
    [string[]]
    $State,

# Postal Code
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,20)]
    [string[]]
    $PostalCode,

# Additional Address Info
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,100)]
    [string[]]
    $AdditionalAddressInfo,

# Country ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $CountryID,

# Holiday Set ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $HolidaySetID,

# No Hours On Holidays
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $NoHoursOnHolidays,

# Default
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $Default,

# First Day Of Week
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $FirstDayOfWeek,

# Date Format
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,50)]
    [string[]]
    $DateFormat,

# Time Format
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,50)]
    [string[]]
    $TimeFormat,

# Number Format
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,50)]
    [string[]]
    $NumberFormat,

# Time Zone ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int[]]
    $TimeZoneID,

# SundayBusinessHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SundayBusinessHoursStartTime,

# SundayBusinessHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SundayBusinessHoursEndTime,

# SundayExtendedHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SundayExtendedHoursStartTime,

# SundayExtendedHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SundayExtendedHoursEndTime,

# MondayBusinessHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $MondayBusinessHoursStartTime,

# MondayBusinessHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $MondayBusinessHoursEndTime,

# MondayExtendedHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $MondayExtendedHoursStartTime,

# MondayExtendedHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $MondayExtendedHoursEndTime,

# TuesdayBusinessHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $TuesdayBusinessHoursStartTime,

# TuesdayBusinessHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $TuesdayBusinessHoursEndTime,

# TuesdayExtendedHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $TuesdayExtendedHoursStartTime,

# TuesdayExtendedHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $TuesdayExtendedHoursEndTime,

# WednesdayBusinessHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $WednesdayBusinessHoursStartTime,

# WednesdayBusinessHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $WednesdayBusinessHoursEndTime,

# WednesdayExtendedHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $WednesdayExtendedHoursStartTime,

# WednesdayExtendedHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $WednesdayExtendedHoursEndTime,

# ThursdayBusinessHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $ThursdayBusinessHoursStartTime,

# ThursdayBusinessHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $ThursdayBusinessHoursEndTime,

# ThursdayExtendedHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $ThursdayExtendedHoursStartTime,

# ThursdayExtendedHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $ThursdayExtendedHoursEndTime,

# FridayBusinessHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $FridayBusinessHoursStartTime,

# FridayBusinessHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $FridayBusinessHoursEndTime,

# FridayExtendedHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $FridayExtendedHoursStartTime,

# FridayExtendedHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $FridayExtendedHoursEndTime,

# SaturdayBusinessHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SaturdayBusinessHoursStartTime,

# SaturdayBusinessHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SaturdayBusinessHoursEndTime,

# SaturdayExtendedHoursStartTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SaturdayExtendedHoursStartTime,

# SaturdayExtendedHoursEndTime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $SaturdayExtendedHoursEndTime,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'CountryID', 'HolidaySetID', 'NoHoursOnHolidays', 'Default', 'FirstDayOfWeek', 'DateFormat', 'TimeFormat', 'NumberFormat', 'TimeZoneID', 'SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $NotEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'CountryID', 'HolidaySetID', 'NoHoursOnHolidays', 'Default', 'FirstDayOfWeek', 'DateFormat', 'TimeFormat', 'NumberFormat', 'TimeZoneID', 'SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $IsNull,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'CountryID', 'HolidaySetID', 'NoHoursOnHolidays', 'Default', 'FirstDayOfWeek', 'DateFormat', 'TimeFormat', 'NumberFormat', 'TimeZoneID', 'SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $IsNotNull,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'CountryID', 'HolidaySetID', 'FirstDayOfWeek', 'DateFormat', 'TimeFormat', 'NumberFormat', 'TimeZoneID', 'SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $GreaterThan,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'CountryID', 'HolidaySetID', 'FirstDayOfWeek', 'DateFormat', 'TimeFormat', 'NumberFormat', 'TimeZoneID', 'SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'CountryID', 'HolidaySetID', 'FirstDayOfWeek', 'DateFormat', 'TimeFormat', 'NumberFormat', 'TimeZoneID', 'SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $LessThan,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('id', 'Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'CountryID', 'HolidaySetID', 'FirstDayOfWeek', 'DateFormat', 'TimeFormat', 'NumberFormat', 'TimeZoneID', 'SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $LessThanOrEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'DateFormat', 'TimeFormat', 'NumberFormat')]
    [String[]]
    $Like,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'DateFormat', 'TimeFormat', 'NumberFormat')]
    [String[]]
    $NotLike,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'DateFormat', 'TimeFormat', 'NumberFormat')]
    [String[]]
    $BeginsWith,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'DateFormat', 'TimeFormat', 'NumberFormat')]
    [String[]]
    $EndsWith,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Name', 'Address1', 'Address2', 'City', 'State', 'PostalCode', 'AdditionalAddressInfo', 'DateFormat', 'TimeFormat', 'NumberFormat')]
    [String[]]
    $Contains,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('SundayBusinessHoursStartTime', 'SundayBusinessHoursEndTime', 'SundayExtendedHoursStartTime', 'SundayExtendedHoursEndTime', 'MondayBusinessHoursStartTime', 'MondayBusinessHoursEndTime', 'MondayExtendedHoursStartTime', 'MondayExtendedHoursEndTime', 'TuesdayBusinessHoursStartTime', 'TuesdayBusinessHoursEndTime', 'TuesdayExtendedHoursStartTime', 'TuesdayExtendedHoursEndTime', 'WednesdayBusinessHoursStartTime', 'WednesdayBusinessHoursEndTime', 'WednesdayExtendedHoursStartTime', 'WednesdayExtendedHoursEndTime', 'ThursdayBusinessHoursStartTime', 'ThursdayBusinessHoursEndTime', 'ThursdayExtendedHoursStartTime', 'ThursdayExtendedHoursEndTime', 'FridayBusinessHoursStartTime', 'FridayBusinessHoursEndTime', 'FridayExtendedHoursStartTime', 'FridayExtendedHoursEndTime', 'SaturdayBusinessHoursStartTime', 'SaturdayBusinessHoursEndTime', 'SaturdayExtendedHoursStartTime', 'SaturdayExtendedHoursEndTime')]
    [String[]]
    $IsThisDay
  )

  Begin
  { 
    $EntityName = 'BusinessLocation'
    
    # Enable modern -Debug behavior
    If ($PSCmdlet.MyInvocation.BoundParameters['Debug'].IsPresent) {$DebugPreference = 'Continue'}
    
    Write-Debug ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
        
    # Set up TimeZone offset handling
    If (-not($script:ESTzone)) {
      $script:ESTzone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Eastern Standard Time")
    }
    
    If (-not($script:ESToffset)) {
      $Now = Get-Date
      $ESTtime = [System.TimeZoneInfo]::ConvertTimeFromUtc($Now.ToUniversalTime(), $ESTzone)

      $script:ESToffset = (New-TimeSpan -Start $ESTtime -End $Now).TotalHours
    }
  }


  Process
  {
    If ($PSCmdlet.ParameterSetName -eq 'Get_all')
    { $Filter = @('id', '-ge', 0)}
    ElseIf (-not ($Filter)) {
      Write-Debug ('{0}: Query based on parameters, parsing' -F $MyInvocation.MyCommand.Name)
      
      $Fields = Get-FieldInfo -Entity $EntityName
 
      Foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
        $Field = $Fields | Where-Object {$_.Name -eq $Parameter.Key}
        If ($Field -or $Parameter.Key -eq 'UserDefinedField') { 
          If ($Parameter.Value.Count -gt 1) {
            $Filter += '-begin'
          }
          Foreach ($ParameterValue in $Parameter.Value) {   
            $Operator = '-or'
            $ParameterName = $Parameter.Key
            If ($Field.IsPickList) {
              If ($Field.PickListParentValueField) {
                $ParentField = $Fields.Where{$_.Name -eq $Field.PickListParentValueField}
                $ParentLabel = $PSBoundParameters.$($ParentField.Name)
                $ParentValue = $ParentField.PickListValues | Where-Object {$_.Label -eq $ParentLabel}
                $PickListValue = $Field.PickListValues | Where-Object {$_.Label -eq $ParameterValue -and $_.ParentValue -eq $ParentValue.Value}                
              }
              Else { 
                $PickListValue = $Field.PickListValues | Where-Object {$_.Label -eq $ParameterValue}
              }
              $Value = $PickListValue.Value
            }
            ElseIf ($ParameterName -eq 'UserDefinedField') {
              $Filter += '-udf'              
              $ParameterName = $ParameterValue.Name
              $Value = $ParameterValue.Value
            }
            ElseIf ($ParameterValue.GetType().Name -eq 'DateTime')  {
              $Value = ConvertTo-AtwsDate -ParameterName $ParameterName -DateTime $ParameterValue
            }            
            Else {
              $Value = $ParameterValue
            }
            $Filter += $ParameterName
            If ($Parameter.Key -in $NotEquals) { 
              $Filter += '-ne'
              $Operator = '-and'
            }
            ElseIf ($Parameter.Key -in $GreaterThan)
            { $Filter += '-gt'}
            ElseIf ($Parameter.Key -in $GreaterThanOrEquals)
            { $Filter += '-ge'}
            ElseIf ($Parameter.Key -in $LessThan)
            { $Filter += '-lt'}
            ElseIf ($Parameter.Key -in $LessThanOrEquals)
            { $Filter += '-le'}
            ElseIf ($Parameter.Key -in $Like) { 
              $Filter += '-like'
              $Value = $Value -replace '\*', '%'
            }
            ElseIf ($Parameter.Key -in $NotLike) { 
              $Filter += '-notlike'
              $Value = $Value -replace '\*', '%'
            }
            ElseIf ($Parameter.Key -in $BeginsWith)
            { $Filter += '-beginswith'}
            ElseIf ($Parameter.Key -in $EndsWith)
            { $Filter += '-endswith'}
            ElseIf ($Parameter.Key -in $Contains)
            { $Filter += '-contains'}
            ElseIf ($Parameter.Key -in $IsThisDay)
            { $Filter += '-isthisday'}
            ElseIf ($Parameter.Key -in $IsNull -and $Parameter.Key -eq 'UserDefinedField')
            {
              $Filter += '-IsNull'
              $IsNull = $IsNull.Where({$_ -ne 'UserDefinedField'})
            }
            ElseIf ($Parameter.Key -in $IsNotNull -and $Parameter.Key -eq 'UserDefinedField')
            {
              $Filter += '-IsNotNull'
              $IsNotNull = $IsNotNull.Where({$_ -ne 'UserDefinedField'})
            }
            Else
            { $Filter += '-eq'}
            
            # Add Value to expression, unless this is a UserDefinedfield AND UserDefinedField has been
            # specified for -IsNull or -IsNotNull
            If ($Filter[-1] -notin @('-IsNull','-IsNotNull'))
            {$Filter += $Value}

            If ($Parameter.Value.Count -gt 1 -and $ParameterValue -ne $Parameter.Value[-1]) {
              $Filter += $Operator
            }
            ElseIf ($Parameter.Value.Count -gt 1) {
              $Filter += '-end'
            }
            
          }
            
        }
      }
      # IsNull and IsNotNull are special. They are the only operators that does not require a value to work
      If ($IsNull.Count -gt 0) {
        If ($Filter.Count -gt 0) {
          $Filter += '-and'
        }
        Foreach ($PropertyName in $IsNull) {
          $Filter += $PropertyName
          $Filter += '-isnull'
        }
      }
      If ($IsNotNull.Count -gt 0) {
        If ($Filter.Count -gt 0) {
          $Filter += '-and'
        }
        Foreach ($PropertyName in $IsNotNull) {
          $Filter += $PropertyName
          $Filter += '-isnotnull'
        }
      }  
    }
    Else {
      Write-Debug ('{0}: Passing -Filter raw to Get function' -F $MyInvocation.MyCommand.Name)
    } 

    $Result = Get-AtwsData -Entity $EntityName -Filter $Filter

    Write-Verbose ('{0}: Number of entities returned by base query: {1}' -F $MyInvocation.MyCommand.Name, $Result.Count)
    
    # Datetimeparameters
    $DateTimeParams = $Fields.Where({$_.Type -eq 'datetime'}).Name
    
    # Expand UDFs by default
    Foreach ($Item in $Result)
    {
      # Any userdefined fields?
      If ($Item.UserDefinedFields.Count -gt 0)
      { 
        # Expand User defined fields for easy filtering of collections and readability
        Foreach ($UDF in $Item.UserDefinedFields)
        {
          # Make names you HAVE TO escape...
          $UDFName = '#{0}' -F $UDF.Name
          Add-Member -InputObject $Item -MemberType NoteProperty -Name $UDFName -Value $UDF.Value
        }  
      }
      
      # Adjust TimeZone on all DateTime properties
      Foreach ($DateTimeParam in $DateTimeParams) {
      
        # Get the datetime value
        $ParameterValue = $Item.$DateTimeParam
                
        # Skip if parameter is empty
        If (-not ($ParameterValue)) {
          Continue
        }
        
        $TimePresent = $ParameterValue.Hour -gt 0 -or $ParameterValue.Minute -gt 0 -or $ParameterValue.Second -gt 0 -or $ParameterValue.Millisecond -gt 0 
                
        # If this is a DATE it should not be touched
        If ($DateTimeParam -like "*DateTime" -or $TimePresent) {

          # This is DATETIME 
          # We need to adjust the timezone difference 

          # Yes, you really have to ADD the difference
          $ParameterValue = $ParameterValue.AddHours($script:ESToffset)
            
          # Store the value back to the object (not the API!)
          $Item.$DateTimeParam = $ParameterValue
        }
      }
    }
    
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