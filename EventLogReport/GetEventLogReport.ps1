#################################################################################################
# This Powershell script includes three options for EPS data collection:
#
# Option 1) Scan the event log(s) of the local Windows host to determine the Events Per Second 
#           (EPS) rate.
# Option 2) Scan a list of IP addresses provided by the user. The remote systems Event Log(s) are 
#           scanned to determine the Events Per Second (EPS) rate of each host in the list.
# Option 3) Scan the local domain where the script is run to determine the Events Per Second (EPS) 
#           rate of all Windows hosts within the domain.
#
# Note: PowerShell must be run as local admin & users must run Set-ExecutionPolicy RemoteSigned
#       To use Option 3 for domain scans, Powershell domain cmdlets need to be installed.
#
# Pre-requisites: This script requires Powershell 3.0 or 4.0. Powershell is the property of
#                Microsoft. For more information on Powershell or downloads, see the following
#                website: https://technet.microsoft.com/en-us/scriptcenter/dd742419.aspx
#
#
# Authors:  Jamie Wheaton // William Delong
# 
#
#################################################################################################
#
#
#################################################################################################
#Function will scan the Event Log(s) & determine the Events Per Second (EPS).
#
#@param $Agent          ->  The Computer / IP
#@param $LogName        ->  The Event Log that will be evaluated (Security, Application, System)
#@param $RemoteComputer ->  The value to tell if the computer is remote or local  
#
#################################################################################################

function Get-EventLogInfo { param($Agent, $LogName, $RemoteComputer, $OS)

    $LogInfo = @{}        

     try {     
                          
        # Just localhost
        If (!$RemoteComputer) {         

            $TotalLogEvents = (Get-WinEvent -ListLog $LogName).RecordCount

            $LogSize = (Get-WinEvent -ListLog $LogName).FileSize / 1000000 # Set to MB
            
            $LogSize = [math]::Round(($LogSize), 1)
     
            $OldestEventTime = (Get-WinEvent $LogName -Oldest -maxevents 1).TimeCreated        

            $NewestEventTime = (Get-WinEvent $LogName -maxevents 1).TimeCreated
        
            $TotalTime = (Get-Date).Subtract($OldestEventTime).TotalSeconds

            $AvgEventsPerSecond = $TotalLogEvents / $TotalTime       
        
            $AvgEventsPerSecond = [math]::Round($AvgEventsPerSecond, 5) 
                                                  
        }
        
        # Remote box
        Else {

            if ($OS -like "*Server 2003*" -or $OS -like "*Windows XP*"){

                Write-Host "$OS is an old Operating System, Collecting $LogName Event Log Information via WMI, this may take some time"

                $wmi_eventlogsummary = Get-WmiObject -Class Win32_NTEventLogFile -computername $Agent -Credential $Global:Cred -filter "LogFileName = '$LogName'"
                
                $TotalLogEvents = $wmi_eventlogsummary.NumberOfRecords

                $LogSize = ($wmi_eventlogsummary.FileSize / 1MB)
     
                $wmi_eventlogdata = Get-WMIobject -ComputerName $computer -Credential $cred -query "Select * from Win32_NTLogEvent Where Logfile = 'application'"

                $getwmioldevent =  $wmi_eventlogdata| select -last 1

                $getwminewest = $wmi_eventlogdata | select -first 1
                
                $OldestEventTime = [management.managementDateTimeConverter]::ToDateTime($getwmioldevent.TimeGenerated)        

                $NewestEventTime = [management.managementDateTimeConverter]::ToDateTime($getwminewest.TimeGenerated)


                }

            else {

            $TotalLogEvents = (Get-WinEvent -ListLog $LogName -ComputerName $Agent -Credential $Global:Cred).RecordCount

            $LogSize = ((Get-WinEvent -ListLog $LogName -ComputerName $Agent -Credential $Global:Cred).FileSize / 1MB) # Set to MB
            
            #$LogSize = [math]::Round(($LogSize), 1)
     
            if ($TotalLogEvents -eq 0) {
            
                Write-Log $ERROR_LOG "There are 0 $LogName Events"
             
                   $OldestEventTime = 0
                   $NewestEventTime = 0
                   $TotalTime = 0
                   $AvgEventsPerSecond = 0
                   $AvgEventsPerSecond = 0

                } 

                else {

                        $OldestEventTime = (Get-WinEvent $LogName -ComputerName $Agent -Credential $Global:Cred -Oldest -Maxevents 1).TimeCreated        
    
                        $NewestEventTime = (Get-WinEvent $LogName -ComputerName $Agent -Credential $Global:Cred -Maxevents 1).TimeCreated
                                                
                        $TotalTime = (Get-Date).Subtract($OldestEventTime).TotalSeconds
                        
                        $AvgEventsPerSecond = $TotalLogEvents / $TotalTime       
        
                        $AvgEventsPerSecond = [math]::Round($AvgEventsPerSecond, 5) 
                

                     }

            }

                              
        }
        
        

        $LogInfo.Add("StartTime", $OldestEventTime)
        $LogInfo.Add("EndTime", $NewestEventTime)

        $LogInfo.Add("LogSize", $LogSize)
        #$LogInfo.Add("OSVersion", $OSVersion)

        $LogInfo.Add("TotalEvents", $TotalLogEvents)

        $LogInfo.Add("AverageEvents", $AvgEventsPerSecond)

        Return $LogInfo
                                
     }
     
     catch {

        Write-Log $ERROR_LOG "Unable to scan $Agent event logs"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        continue
    }
}


#################################################################################################
#Function will generate output info for the given log events per second

#@param $TotalLogEvents ->  The total # of events for the given log

#################################################################################################

function Get-ProfileSuggestion { param($AvgEventsPerSecond)

    try {

         #Profile sugestion
         $LogStatsAndInfo = ""


        If ($AvgEventsPerSecond -GE 0 -and $AvgEventsPerSecond -LE 100) {
         
            $LogStatsAndInfo += "MSRPC (0-100) EPS or WinCollect Default (Endpoint) (0-50) EPS`n"         
         }
         
        # Above High Hate
         If ($AvgEventsPerSecond -GT 625) { 
            
            $LogStatsAndInfo += "Suggested Profile: High Event Rate Server (251-625) EPS"
            #$LogStatsAndInfo += "NOTE: Log Event Rate Higher Then Profile Range`n" 
             
         }
         
         #- High Event Rate Server 1250-1875 (416-625)
         ElseIf  ($AvgEventsPerSecond -GE 250) { 
         
            $LogStatsAndInfo += "High Event Rate Server (251-625) EPS"
         }
         
         #- Typical Server 500-750 (166-250)
         ElseIf  ($AvgEventsPerSecond -GE 50) { 
          
            $LogStatsAndInfo += "Typical Server (51-250) EPS"
         }
         
         #- Default (Endpoint) 100-150 (33-50)
         ElseIf  ($AvgEventsPerSecond -GE 0) { 

            $LogStatsAndInfo += "WinCollect Default (Endpoint) (0-50) EPS"
         }
         
         # Negitive or unreadble and cant be determined 
         Else {
         
            Write-Log $ERROR_LOG "Unable to Suggest Profile"
            
            exit
         }        
 
         
         $LogStatsAndInfo

    
    }

    catch {

        Write-Log $ERROR_LOG "Unable to get profile suggestion"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit
    }
}

#################################################################################################
#Function will test connection

#@param $Cred     ->  The Event Log
#@param $Computer ->  The avg events per second for the given log

#################################################################################################

function Test-HostConnection { param($Computer)    

    try {

        if ((Test-Connection -ComputerName $Computer -count 1 -quiet)) {

            return $true
        }

        else {


            Write-Log $ERROR_LOG "Unable to contact $Computer. Please verify its network connectivity and try again"

            $Global:ConnectionIssues = $Global:ConnectionIssues + 1

            return $false
        }        
    }

    catch {

        Write-Log $ERROR_LOG "Unable conect to Host"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit

    }
}


#################################################################################################
#Function Create a log report for the each computer in the computer list

#@param $LogName            ->  The Event Log
#@param $AvgEventsPerSecond ->  The avg events per second for the given log
#@param $TotalLogEvents     ->  The total # of events for the given log

#################################################################################################

function Create-LogReport { param($Computerlist, $ComputerCount, $ComputerListType, $OS)    

    try {
        
        $Report = @{}
        $ProgressCount = 0;        

        if ($ComputerListType -NE $LOCALHOST_OPT) {

            $Global:Cred = Get-Credential -Message "Enter an account which has access to the Windows Event Logs"
        }

                                 
        ForEach ($Computer in $Computerlist) {
            
            $ProgressCount = $ProgressCount + 1

            $RemoteComputer = $false

            if($ProgressCount -EQ 1) {
                
                Write-Log $INFO_LOG "Calculating & Processing Log EPS For Computer List" 
            } 

            if ($ComputerListType -NE $LOCALHOST_OPT) {

                $RemoteComputer = $true
            
                $Login = Test-HostConnection $Computer

                if (!$Login) {
                    continue                
                }
            }
            
            # Get Server OS if not already gathered
            if ($ComputerListType -eq $FILE_OPT) {
                Write-Log $INFO_LOG "Getting OS Information for $Computer"
                $OS = (Get-WmiObject Win32_OperatingSystem -computername $Computer -Credential $Global:Cred).Caption
                Write-Log $INFO_LOG "$OS"
            }
            
            if ($ComputerListType -eq $LOCALHOST_OPT) {
                Write-Log $INFO_LOG "Getting OS Information for $Computer"
                $OS = (Get-WmiObject Win32_OperatingSystem).Caption
                Write-Log $INFO_LOG "$OS"
            }
            
            if ($ComputerListType -eq $DOMAIN_OPT) {
                Write-Log $INFO_LOG "Getting OS Information for $Computer"
                #$OS = (Get-WmiObject Win32_OperatingSystem -computername $Computer -Credential $Global:Cred).Caption

                $GetADComputerList = Get-ADComputer -Credential $Global:Cred -Filter {enabled -eq "true"} -Properties OperatingSystem | Select DNSHostname, OperatingSystem

                #$GetADOS = Get-ADComputer -Credential $Global:Cred -Filter {enabled -eq "true"} -Properties OperatingSystem | Select 
                
                #$ComputerList = $GetADComputerList.DNSHostName


                $OS = ($GetADComputerList -match $Computer).OperatingSystem
                Write-Log $INFO_LOG "$OS"
            } 
                                                                              
            
            # Retrieve the Application Event log info
            $ApplicationInfo = Get-EventLogInfo $Computer Application $RemoteComputer $OS
            $ApplicationEPS = $ApplicationInfo.AverageEvents
            $ApplicationFirstEventTime = $ApplicationInfo.StartTime
            $ApplicationLastEventTime = $ApplicationInfo.EndTime
            $ApplicationTotalEvents = $ApplicationInfo.TotalEvents
            $ApplicationEventLogSize = $ApplicationInfo.LogSize
            

            # Retrieve the Security Event log info
            $SecurityInfo = Get-EventLogInfo $Computer Security $RemoteComputer $OS
            $SecurityEPS = $SecurityInfo.AverageEvents
            $SecurityFirstEventTime = $SecurityInfo.StartTime
            $SecurityLastEventTime = $SecurityInfo.EndTime
            $SecurityTotalEvents = $SecurityInfo.TotalEvents
            $SecurityEventLogSize = $SecurityInfo.LogSize
            

            # Retrieve the System Event log info
            $SystemInfo = Get-EventLogInfo $Computer System $RemoteComputer $OS
            $SystemEPS = $SystemInfo.AverageEvents
            $SystemFirstEventTime = $SystemInfo.StartTime
            $SystemLastEventTime = $SystemInfo.EndTime
            $SystemTotalEvents = $SystemInfo.TotalEvents
            $SystemEventLogSize = $SystemInfo.LogSize


            $TotalEPS = [math]::Round(($ApplicationEPS + $SecurityEPS + $SystemEPS), 5)
            $ProfileSuggestion = Get-ProfileSuggestion $TotalEPS
            #$ComputerOS = (Get-ADComputer -Filter *).OperatingSystem
            $ComputerOS = "$OS"


            $Box = @{"ProfileSuggestion" = $ProfileSuggestion; "TotalEPS" = $TotalEPS; "OSVersion" = $ComputerOS;
                     "ApplicationEPS" = $ApplicationEPS; "ApplicationFirstEventTime" = $ApplicationFirstEventTime; "ApplicationLastEventTime" = $ApplicationLastEventTime; "ApplicationTotalEvents" = $ApplicationTotalEvents; "ApplicationEventLogSize" = $ApplicationEventLogSize;
                     "SecurityEPS" = $SecurityEPS; "SecurityFirstEventTime" = $SecurityFirstEventTime; "SecurityLastEventTime" = $SecurityLastEventTime; "SecurityTotalEvents" = $SecurityTotalEvents; "SecurityEventLogSize" = $SecurityEventLogSize; 
                     "SystemEPS" = $SystemEPS; "SystemFirstEventTime" = $SystemFirstEventTime; "SystemLastEventTime" = $SystemLastEventTime; "SystemTotalEvents" = $SystemTotalEvents; "SystemEventLogSize" = $SystemEventLogSize;}
            
            $Report.Add($Computer, $Box)                          

            $PercentComplete = $ProgressCount / $ComputerCount * 100
            $PercentComplete = [math]::Round($PercentComplete, 0)

            Write-Progress -Activity "Processing Computer List -  $PercentComplete% Complete" -status "Calculating EPS for Computer: $Computer" -percentComplete $PercentComplete
        }

        Write-Log $INFO_LOG "Event Log ESP Report Calculations Complete"

        Return $Report
     
    }

    catch {

        Write-Log $ERROR_LOG "Unable to Create Log Report"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit
    }
}


#################################################################################################
#Function will generate output info for the given log. Avg, Suggested Profile, etc...

#@param $LogName            ->  The Event Log
#@param $AvgEventsPerSecond ->  The avg events per second for the given log
#@param $TotalLogEvents     ->  The total # of events for the given log

#################################################################################################

function Export-LogReport { param($Computerlist, $ComputerCount, $ComputerListType)    

    try {
        
        $Report = Create-LogReport $Computerlist $ComputerCount $ComputerListType

        $OutputTable = foreach ($box in $Report.GetEnumerator()) { 

            New-Object PSObject -Property ([ordered]@{
            "Server" = $box.Name; "OS Version" = $box.Value.OSVersion; 
            "Application (EPS)" = $box.Value.ApplicationEPS; "Application 1st Event" = $box.Value.ApplicationFirstEventTime; "Application last Event" = $box.Value.ApplicationLastEventTime; "Application total events" = $box.Value.ApplicationTotalEvents; "Application Log Size (MB)" = $box.Value.ApplicationEventLogSize;
            "Security (EPS)" = $box.Value.SecurityEPS; "Security 1st Event" = $box.Value.SecurityFirstEventTime; "Security last Event" = $box.Value.SecurityLastEventTime; "Security total events" = $box.Value.SecurityTotalEvents; "Security Log Size (MB)" = $box.Value.SecurityEventLogSize; 
            "System (EPS)" = $box.Value.SystemEPS; "System 1st Event" = $box.Value.SystemFirstEventTime; "System last Event" = $box.Value.SystemLastEventTime; "System total events" = $box.Value.SystemTotalEvents; "System Log Size (MB)" = $box.Value.SystemEventLogSize;
            "Total (EPS)" = $box.Value.TotalEPS; "Profile Suggestion (3 Sec Polling Interval)" = $box.Value.ProfileSuggestion;})

        }


        Write-Log $INPUT_LOG "Select Event Log Export Location..."

        $ExportFolder = Select-ExportLocation "Event Log Summary Report Export Location" "Desktop"
        
        $ExportLocation = $ExportFolder + "\Event-Log-Summary-Report-" + $(get-date -f yyyyMMddhhmmss) + ".csv"            
                
        Write-Log $INFO_LOG "Exporting Log Events to: $ExportLocation"

        $OutputTable | Export-CSV $ExportLocation -NoTypeInformation -Force
    
    }

    catch {

        Write-Log $ERROR_LOG "Unable to Export Log Report"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit
    }
}


#################################################################################################
#Function will generate a Folder Select Dialog

#@param $Description ->  The Description of the Dialog
#@param $RootFolder  ->  The location that the folder selection begins

#################################################################################################

function Get-FileName { param($RootFolder) 
    
    try {
    
         $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
         $OpenFileDialog.initialDirectory = $RootFolder
         $OpenFileDialog.Title = "Select Computer List"
         $OpenFileDialog.filter = "All files (*.*)| *.*"
         $OpenFileDialog.ShowDialog() | Out-Null
         $OpenFileDialog.filename
    
    }
    
    catch {
     
        Write-Log $ERROR_LOG "Unable to Select File"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit
        
     }
}          
        

#################################################################################################
#Function will generate a Folder Select Dialog

#@param $Description ->  The Description of the Dialog
#@param $RootFolder  ->  The location that the folder selection begins

#################################################################################################

function Select-ExportLocation { param($Description, $RootFolder) 

     try {
     
        $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $objForm.Rootfolder = $RootFolder
        $objForm.Description = $Description        
        $Show = $objForm.ShowDialog()

        if ($Show -EQ "OK") {
            
            return $objForm.SelectedPath
        }
        
        else {           
            
            Write-Log $ERROR_LOG "Operation cancelled by user"

            Write-Log $ERROR_LOG $Error[0]

            $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

            Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

            exit
            
        } 

        
     }
     
     catch {
     
        Write-Log $ERROR_LOG "Unable to Select Folder"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit
        
     }
}


#################################################################################################
#Function will generate a Drop Down Menu based on the given Drop Down Options

#@param $DropDownOptions ->  The Event Log that will be evaluated (Security, Application, System)
#@param $Title           ->  The Title of the Drop Down Menu

#################################################################################################

function Get-InputFromDropDown { param($DropDownOptions, $Title)

     try {
     
        function Return-DropDown {
            $script:Choice = $DropDown.SelectedItem.ToString()
            $Form.Close()
        }

        $Form = New-Object System.Windows.Forms.Form

        $Form.width = 300
        $Form.height = 150
        $Form.Text = "Select $Title"

        $DropDown = new-object System.Windows.Forms.ComboBox
        $DropDown.Location = new-object System.Drawing.Size(100,10)
        $DropDown.Size = new-object System.Drawing.Size(130,30)

        ForEach ($Item in $DropDownOptions) {
         [void] $DropDown.Items.Add($Item)
        }

        $Form.Controls.Add($DropDown)

        $DropDownLabel = new-object System.Windows.Forms.Label
        $DropDownLabel.Location = new-object System.Drawing.Size(10,10) 
        $DropDownLabel.size = new-object System.Drawing.Size(100,20) 
        $DropDownLabel.Text = "Options:"
        $Form.Controls.Add($DropDownLabel)

        $Button = new-object System.Windows.Forms.Button
        $Button.Location = new-object System.Drawing.Size(100,50)
        $Button.Size = new-object System.Drawing.Size(100,20)
        $Button.Text = "Submit"
        $Button.Add_Click({Return-DropDown})
        $form.Controls.Add($Button)

        $DropDown.SelectedIndex =  0
        
        $Form.Add_Shown({$Form.Activate()})
        [void] $Form.ShowDialog()

        $Choice
     }
     
    catch {

        Write-Log $ERROR_LOG "Unable to generate input drop down"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit

    }
}


#########################################################################################
#Function will get the list of computers based on the users selected list type

#@param $ComputerListType   -> The type of computer list   

#########################################################################################

function Get-ComputerList { param($ComputerListType)


    try {

        $ComputerList = @{};

        switch($ComputerListType) {

            $DOMAIN_OPT {
            
                $GetADComputerList = Get-ADComputer -Credential $Global:Cred -Filter {enabled -eq "true"} -Properties OperatingSystem | Select DNSHostname, OperatingSystem
                
                $ComputerList = $GetADComputerList.DNSHostName

                break
                
            } 
         
            $FILE_OPT {
                
                $ComputerList = Get-FileName "Desktop" 
                $ComputerList = Get-Content $ComputerList

                break
            }

            $LOCALHOST_OPT {
                
                $ComputerList = "localhost"

                break
            } 
        }

        Return $ComputerList

    }

    catch {
    
        Write-Log $ERROR_LOG "Unable to determine computer list"

        Write-Log $ERROR_LOG $Error[0]

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Log $ERROR_LOG "Caught on line number: $ErrorLineNumber"

        exit

    }
}



#########################################################################################
#Function will log messages throughout the script execution 

#@param $severity   -> How severe of the input message to log   
#@param $logMessage -> The message that will be logged cast to a string

#########################################################################################

function Write-Log { param($severity, [string]$logMessage)
    
    try {
        
        if ($logMessage.length -GT 200) {
            $logMessage = $logMessage.Substring(0,200) + "..."

        }

        $output = $logMessage + "`n"

        switch($Severity) {
        
            $INFO_LOG {Write-Host $output -Fore Green; break} 
           
            $INPUT_LOG {Write-Host $output -Fore Cyan; break}

            $WARN_LOG {Write-Host $output -Fore Cyan; break}

            $ERROR_LOG {Write-Host $output -Fore Red; break}

            Default {Write-Host "Unable to log based on severity: $Severity" -Fore Cyan; break}
        }

    }

    catch {
        
        Write-Host "Unable to log`n" -Fore Red

        Write-Host $Error[0] -Fore Red

        $ErrorLineNumber = $Error[0].InvocationInfo.scriptlinenumber

        Write-Host "Caught on line number: $ErrorLineNumber" -Fore Red

        exit

    }
}


# Imports the forms
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

#Set severities
$INFO_LOG = "Info"
$INPUT_LOG = "Input"
$WARN_LOG = "Warn"
$ERROR_LOG = "Error"

#Set Computer List Options
#$hostdomain = (Get-ADDomain).DNSRoot
$FILE_OPT = "IP List"
$DOMAIN_OPT = "Domain"
$LOCALHOST_OPT = "Local Host"


Write-Log $INFO_LOG "Starting Script"

# Drop Down Options
[array]$ComputerListTypeOptions = $FILE_OPT, $LOCALHOST_OPT, $DOMAIN_OPT


#Set the function variables
$ComputerListType  = Get-InputFromDropDown $ComputerListTypeOptions "IP List Type"


#Set the function variables
Write-Log $INPUT_LOG "Select Computer List..."

$ComputerList = Get-ComputerList $ComputerListType
$ComputerCount = $ComputerList.Count
$Global:Cred = $Null
$Global:ConnectionIssues = 0 

#Set all errors to terminating
$ErrorActionPreference = "Stop"

Write-Log $INFO_LOG "Selected: $ComputerListType ($ComputerCount Computer(s) Found)"

#Call function
$Time = Measure-Command -Expression {
    $LogReport = Export-LogReport $Computerlist $ComputerCount $ComputerListType
}

$Time = [math]::Round($Time.TotalMinutes, 1)

Write-Log $INFO_LOG "Event Log Report Successfully Calculated & Exported - $ComputerCount Computers - $Time Minutes - $Global:ConnectionIssues Connection Issue(s)"
