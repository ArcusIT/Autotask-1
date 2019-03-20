﻿#Requires -Version 4.0
<#

.COPYRIGHT
Copyright (c) Office Center Hønefoss AS. All rights reserved. Based on code from Jan Egil Ring (Crayon). Licensed under the MIT license.
See https://github.com/officecenter/Autotask/blob/master/LICENSE.md for license information.

#>
Function Get-Task
{


<#
.SYNOPSIS
This function get one or more Task through the Autotask Web Services API.
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

DepartmentID
 

Status
 

PriorityLabel
 

TaskType
 

CreatorType
 

CompletedByType
 

LastActivityPersonType
 

Entities that have fields that refer to the base entity of this CmdLet:

BillingItem
 ExpenseItem
 NotificationHistory
 ServiceCallTask
 TaskNote
 TaskPredecessor
 TaskSecondaryResource
 TimeEntry

.INPUTS
Nothing. This function only takes parameters.
.OUTPUTS
[Autotask.Task[]]. This function outputs the Autotask.Task that was returned by the API.
.EXAMPLE
Get-Task -Id 0
Returns the object with Id 0, if any.
 .EXAMPLE
Get-Task -TaskName SomeName
Returns the object with TaskName 'SomeName', if any.
 .EXAMPLE
Get-Task -TaskName 'Some Name'
Returns the object with TaskName 'Some Name', if any.
 .EXAMPLE
Get-Task -TaskName 'Some Name' -NotEquals TaskName
Returns any objects with a TaskName that is NOT equal to 'Some Name', if any.
 .EXAMPLE
Get-Task -TaskName SomeName* -Like TaskName
Returns any object with a TaskName that matches the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-Task -TaskName SomeName* -NotLike TaskName
Returns any object with a TaskName that DOES NOT match the simple pattern 'SomeName*'. Supported wildcards are * and %.
 .EXAMPLE
Get-Task -DepartmentID <PickList Label>
Returns any Tasks with property DepartmentID equal to the <PickList Label>. '-PickList' is any parameter on .
 .EXAMPLE
Get-Task -DepartmentID <PickList Label> -NotEquals DepartmentID 
Returns any Tasks with property DepartmentID NOT equal to the <PickList Label>.
 .EXAMPLE
Get-Task -DepartmentID <PickList Label1>, <PickList Label2>
Returns any Tasks with property DepartmentID equal to EITHER <PickList Label1> OR <PickList Label2>.
 .EXAMPLE
Get-Task -DepartmentID <PickList Label1>, <PickList Label2> -NotEquals DepartmentID
Returns any Tasks with property DepartmentID NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.
 .EXAMPLE
Get-Task -Id 1234 -TaskName SomeName* -DepartmentID <PickList Label1>, <PickList Label2> -Like TaskName -NotEquals DepartmentID -GreaterThan Id
An example of a more complex query. This command returns any Tasks with Id GREATER THAN 1234, a TaskName that matches the simple pattern SomeName* AND that has a DepartmentID that is NOT equal to NEITHER <PickList Label1> NOR <PickList Label2>.

.LINK
New-Task
 .LINK
Set-Task

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
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CreatorResourceID', 'PhaseID', 'ProjectID', 'CompletedByResourceID', 'LastActivityResourceID')]
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
    [ValidateSet('TaskNote:TaskID', 'TaskPredecessor:PredecessorTaskID', 'TaskPredecessor:SuccessorTaskID', 'TaskSecondaryResource:TaskID', 'BillingItem:TaskID', 'ServiceCallTask:TaskID', 'ExpenseItem:TaskID', 'TimeEntry:TaskID', 'NotificationHistory:TaskID')]
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

# Allocation Code Name
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $AllocationCodeID,

# Resource
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $AssignedResourceID,

# Resource Role Name
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $AssignedResourceRoleID,

# Can Client Portal User Complete Task
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $CanClientPortalUserCompleteTask,

# Task Complete Date
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $CompletedDateTime,

# Task Creation Date
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $CreateDateTime,

# Task Creator
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $CreatorResourceID,

# Task Department Name
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $DepartmentID,

# Task Description
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,8000)]
    [string[]]
    $Description,

# Task End Datetime
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $EndDateTime,

# Task Estimated Hours
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [float[]]
    $EstimatedHours,

# Task External ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $ExternalID,

# Hours to be Scheduled
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [float[]]
    $HoursToBeScheduled,

# Task ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [long[]]
    $id,

# Is Visible in Client Portal
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $IsVisibleInClientPortal,

# Task Last Activity Date Time
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $LastActivityDateTime,

# Phase ID
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $PhaseID,

# Task Priority
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $Priority,

# Project
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int[]]
    $ProjectID,

# Purchase Order Number
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $PurchaseOrderNumber,

# Task Start Date
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [datetime[]]
    $StartDateTime,

# Task Status
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int[]]
    $Status,

# Priority Label
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $PriorityLabel,

# Task Billable
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [boolean[]]
    $TaskIsBillable,

# Task Number
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateLength(1,50)]
    [string[]]
    $TaskNumber,

# Task Type
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [Int[]]
    $TaskType,

# Task Title
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,255)]
    [string[]]
    $Title,

# Creator Type
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $CreatorType,

# Task Completed By
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $CompletedByResourceID,

# Completed By Type
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $CompletedByType,

# Last Activity Person Type
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $LastActivityPersonType,

# Last Activity By
    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [Int[]]
    $LastActivityResourceID,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CanClientPortalUserCompleteTask', 'CompletedDateTime', 'CreateDateTime', 'CreatorResourceID', 'DepartmentID', 'Description', 'EndDateTime', 'EstimatedHours', 'ExternalID', 'HoursToBeScheduled', 'id', 'IsVisibleInClientPortal', 'LastActivityDateTime', 'PhaseID', 'Priority', 'ProjectID', 'PurchaseOrderNumber', 'StartDateTime', 'Status', 'PriorityLabel', 'TaskIsBillable', 'TaskNumber', 'TaskType', 'Title', 'CreatorType', 'CompletedByResourceID', 'CompletedByType', 'LastActivityPersonType', 'LastActivityResourceID')]
    [String[]]
    $NotEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CanClientPortalUserCompleteTask', 'CompletedDateTime', 'CreateDateTime', 'CreatorResourceID', 'DepartmentID', 'Description', 'EndDateTime', 'EstimatedHours', 'ExternalID', 'HoursToBeScheduled', 'id', 'IsVisibleInClientPortal', 'LastActivityDateTime', 'PhaseID', 'Priority', 'ProjectID', 'PurchaseOrderNumber', 'StartDateTime', 'Status', 'PriorityLabel', 'TaskIsBillable', 'TaskNumber', 'TaskType', 'Title', 'CreatorType', 'CompletedByResourceID', 'CompletedByType', 'LastActivityPersonType', 'LastActivityResourceID')]
    [String[]]
    $IsNull,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CanClientPortalUserCompleteTask', 'CompletedDateTime', 'CreateDateTime', 'CreatorResourceID', 'DepartmentID', 'Description', 'EndDateTime', 'EstimatedHours', 'ExternalID', 'HoursToBeScheduled', 'id', 'IsVisibleInClientPortal', 'LastActivityDateTime', 'PhaseID', 'Priority', 'ProjectID', 'PurchaseOrderNumber', 'StartDateTime', 'Status', 'PriorityLabel', 'TaskIsBillable', 'TaskNumber', 'TaskType', 'Title', 'CreatorType', 'CompletedByResourceID', 'CompletedByType', 'LastActivityPersonType', 'LastActivityResourceID')]
    [String[]]
    $IsNotNull,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CompletedDateTime', 'CreateDateTime', 'CreatorResourceID', 'DepartmentID', 'Description', 'EndDateTime', 'EstimatedHours', 'ExternalID', 'HoursToBeScheduled', 'id', 'LastActivityDateTime', 'PhaseID', 'Priority', 'ProjectID', 'PurchaseOrderNumber', 'StartDateTime', 'Status', 'PriorityLabel', 'TaskNumber', 'TaskType', 'Title', 'CreatorType', 'CompletedByResourceID', 'CompletedByType', 'LastActivityPersonType', 'LastActivityResourceID')]
    [String[]]
    $GreaterThan,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CompletedDateTime', 'CreateDateTime', 'CreatorResourceID', 'DepartmentID', 'Description', 'EndDateTime', 'EstimatedHours', 'ExternalID', 'HoursToBeScheduled', 'id', 'LastActivityDateTime', 'PhaseID', 'Priority', 'ProjectID', 'PurchaseOrderNumber', 'StartDateTime', 'Status', 'PriorityLabel', 'TaskNumber', 'TaskType', 'Title', 'CreatorType', 'CompletedByResourceID', 'CompletedByType', 'LastActivityPersonType', 'LastActivityResourceID')]
    [String[]]
    $GreaterThanOrEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CompletedDateTime', 'CreateDateTime', 'CreatorResourceID', 'DepartmentID', 'Description', 'EndDateTime', 'EstimatedHours', 'ExternalID', 'HoursToBeScheduled', 'id', 'LastActivityDateTime', 'PhaseID', 'Priority', 'ProjectID', 'PurchaseOrderNumber', 'StartDateTime', 'Status', 'PriorityLabel', 'TaskNumber', 'TaskType', 'Title', 'CreatorType', 'CompletedByResourceID', 'CompletedByType', 'LastActivityPersonType', 'LastActivityResourceID')]
    [String[]]
    $LessThan,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('AllocationCodeID', 'AssignedResourceID', 'AssignedResourceRoleID', 'CompletedDateTime', 'CreateDateTime', 'CreatorResourceID', 'DepartmentID', 'Description', 'EndDateTime', 'EstimatedHours', 'ExternalID', 'HoursToBeScheduled', 'id', 'LastActivityDateTime', 'PhaseID', 'Priority', 'ProjectID', 'PurchaseOrderNumber', 'StartDateTime', 'Status', 'PriorityLabel', 'TaskNumber', 'TaskType', 'Title', 'CreatorType', 'CompletedByResourceID', 'CompletedByType', 'LastActivityPersonType', 'LastActivityResourceID')]
    [String[]]
    $LessThanOrEquals,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Description', 'ExternalID', 'PurchaseOrderNumber', 'TaskNumber', 'Title')]
    [String[]]
    $Like,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Description', 'ExternalID', 'PurchaseOrderNumber', 'TaskNumber', 'Title')]
    [String[]]
    $NotLike,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Description', 'ExternalID', 'PurchaseOrderNumber', 'TaskNumber', 'Title')]
    [String[]]
    $BeginsWith,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Description', 'ExternalID', 'PurchaseOrderNumber', 'TaskNumber', 'Title')]
    [String[]]
    $EndsWith,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('Description', 'ExternalID', 'PurchaseOrderNumber', 'TaskNumber', 'Title')]
    [String[]]
    $Contains,

    [Parameter(
      ParameterSetName = 'By_parameters'
    )]
    [ValidateSet('CompletedDateTime', 'CreateDateTime', 'EndDateTime', 'LastActivityDateTime', 'StartDateTime')]
    [String[]]
    $IsThisDay
  )

  Begin
  { 
    $EntityName = 'Task'

    Write-Verbose ('{0}: Begin of function' -F $MyInvocation.MyCommand.Name)
        
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
      Write-Verbose ('{0}: Query based on parameters, parsing' -F $MyInvocation.MyCommand.Name)
      
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
              # XML supports sortable datetime format. This way dates should always be read correct by the API.
 
              If ($ParameterValue.Hour -eq 0 -and $ParameterValue.Minute -eq 0 -and $ParameterValue.Second -eq 0 -and $ParameterValue.Millisecond -eq 0) {
                
                # For dates, use Timezone EST
                $OffsetSpan = $ESTzone.BaseUtcOffset
              }
              Else { 
                # Else use local time
                $OffsetSpan = (Get-TimeZone).BaseUtcOffset
              }
              
              # Create the correct text string                           
              $Offset = '{0:00}:{1:00}' -F $OffsetSpan.Hours, $OffsetSpan.Minutes
              If ($OffsetSpan.Hours -ge 0) {
                $Offset = '+{0}' -F $Offset
              }
              $Value = '{0}{1}' -F $(Get-Date $ParameterValue -Format s), $Offset
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
      Write-Verbose ('{0}: Passing -Filter raw to Get function' -F $MyInvocation.MyCommand.Name)
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
        
        # If all TIME parameters are zero, then this is a DATE and should not be touched
        If ($ParameterValue.Hour -ne 0 -or 
            $ParameterValue.Minute -ne 0 -or
            $ParameterValue.Second -ne 0 -or
            $ParameterValue.Millisecond -ne 0) {

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
      Write-Verbose ('{0}: User has asked for external reference objects by {1}' -F $MyInvocation.MyCommand.Name, $GetReferenceEntityById)
      
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
      Write-Verbose ('{0}: User has asked for {1} that are referencing this result' -F $MyInvocation.MyCommand.Name, $GetExternalEntityByThisEntityId)
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
    Write-Verbose ('{0}: End of function' -F $MyInvocation.MyCommand.Name)
    If ($Result)
    {
      Return $Result
    }
  }


}