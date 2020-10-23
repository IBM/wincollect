#####################################################################
## For Reference only
##
## Pre-Requisites - Assumes WinCollect installer is located on system drive already  (ie. c:\wincollect-7.3.0-24.x64.exe) 
## Set Auth Token parameter if in Managed Mode
#####################################################################

Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false,Position=0)][string]$Authtoken

)



### Function

function Stop-WinCollect{
    
    Write-Host "Stopping WinCollect Service"
    
    Start-Job -Name "StopService" -ScriptBlock {Stop-Service -Name “WinCollect” -Force }

    #give it 5 seconds to stop
    Start-Sleep -Seconds 5

    $SERVICESTATE = (Get-Service -Name WinCollect).Status
    
        if( $SERVICESTATE -eq "Stopping" -or $SERVICESTATE -eq "StopPending")
            {
            # still stopping so force process stop
            Stop-Process -Name "WinCollectSvc" -Force -ErrorAction SilentlyContinue
            Stop-Process -Name "WinCollect" -Force -ErrorAction SilentlyContinue
            write-host "Stopped WinCollect processes"
        
             }

    Start-Sleep -Seconds 5

    $SERVICESTATE = (Get-Service -Name WinCollect).Status
    
        if( $SERVICESTATE -eq "Stopped" )
            {
            Write-Host "Service Stopped `n"
            }

        else {Write-Host "Service not stopped, something is wrong, check status of WinCollect Service" Exit }

    Remove-Job -Name "StopService"
}

function Check-WinCollect {

    # Checking to see if we have a successful install - or as close as we can get


    ## Check to see if service is running

    Write-Host "`nFinal Checks.....`n" 

    
        try {(Get-Service WinCollect).WaitForStatus('Running','00:00:30')
        
            Write-Host "WinCollect Service is running" -ForegroundColor Green

        }
        
        catch {Write-Host "WinCollect Service is not running please check the WinCollect service status" -BackgroundColor Red
        
        }


    #If (-Not((Get-Service WinCollect).Status -eq 'Running')) {Write-Host "WinCollect Service is not running please check the WinCollect service status" -BackgroundColor Red}  else {Write-Host "WinCollect Service running" -BackgroundColor Green}
    
    ## Check for both wincollect.exe and wincollectsvc.exe processes

        
        Check-Process WinCollect

        Check-Process WinCollectSvc

    
    #if (-Not(Get-Process WinCollect)) {Write-Host "WinCollect.exe is not running please check the WinCollect service status" -BackgroundColor Red}  else {Write-Host "WinCollect process is running" -ForegroundColor Green}
    #if (-Not(Get-Process WinCollectSvc)) {Write-Host "WinCollectSvc.exe is not running please check the WinCollect service status" -BackgroundColor Red}  else {Write-Host "WinCollectSvc process is running" -ForegroundColor Green}

    ## Pull out the build number from the install config

    $install_config = (ConvertFrom-StringData([Regex]::Escape([IO.File]::ReadAllText("$InstallPath\config\install_config.txt")) -replace "(\\r)?\\n", [Environment]::NewLine))

    if (-Not($install_config.BuildNumber -eq "24")) {Write-Host "WinCollect is not running at the correct build number please uninstall and try re-installing" -BackgroundColor Red}  else {Write-Host "WinCollect running at 7.3.0 build 24" -ForegroundColor Green}


}

Function Check-Process($processname){        
        
        $timeout = new-timespan -Seconds 10
        $sw = [diagnostics.stopwatch]::StartNew()

        while ($sw.elapsed -lt $timeout){
        
            if (Get-Process $processname -ErrorAction SilentlyContinue){
            Write-Host "$processname process is running" -ForegroundColor Green
            return
            }
 
            start-sleep -seconds 1
            }
 
            write-host "$processname is not running please check the WinCollect service status" -BackgroundColor Red

}

#############################



#Parameters
$ProgramName = "WinCollect"
$AgentConfigBackup = "$env:SystemDrive\AgentConfig_Backup.xml"
$InstallConfigBackup = "$env:SystemDrive\install_config_backup.txt"
$ConfigurationServerPort = "8413"

## Pre-Checks - Don't proceed unless these conditions are met

## Is the installer on the system drive

    # Set the bit version from AMD64 to X64
    
    if ($env:PROCESSOR_ARCHITECTURE -eq "X86") {$bit = "x86"} else {$bit = "x64"}


 if (-Not(Test-Path -Path $env:SystemDrive\wincollect-7.3.0-24.$bit.exe -PathType Any)) 
 
        {
            
        Write-Host "Can't find WinCollect installer, make sure you copy wincollect-7.3.0-24.$bit.exe to $env:SystemDrive  Exiting" -BackgroundColor Red
             
        Exit
             
        }

## Make sure WinCollect is installed

Write-Host "`nWinCollect installation information..."

$InstallPath = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\*\Products\*\InstallProperties" | Where-Object { $_.getValue('DisplayName') -like $ProgramName } | ForEach-Object { $_.getValue('InstallLocation')}

Write-Host "Agent install path: $InstallPath"

if ([string]::IsNullOrEmpty($InstallPath)) 

        {

        Write-host "Can't find WinCollect installation location. Exiting" -BackgroundColor Red

        Exit
        
        }


# Determine if this is a Managed or Stand Alone install

#$install_config = (ConvertFrom-StringData([Regex]::Escape((Get-Content "$InstallPath\config\install_config.txt" | Out-String)) -replace "(\\r)?\\n", [Environment]::NewLine))

$install_config = (ConvertFrom-StringData([Regex]::Escape([IO.File]::ReadAllText("$InstallPath\config\install_config.txt")) -replace "(\\r)?\\n", [Environment]::NewLine))




# Get App Identifier and Config Server

        $appid = $install_config.ApplicationIdentifier
        
        if ([string]::IsNullOrEmpty($appid)) 

        {

        Write-host "Can't load Install Config Parameters. Exiting" -BackgroundColor Red

        Exit
        
        } 
        
        $statusserver = $install_config.StatusServer
        $configserver = $install_config.ConfigurationServer
		$ConfigurationServerPort = $install_config.ConfigurationServerPort

        Write-Host "Agent Identifier: $appid`n"

        if ($configserver -eq "") {
        
            Write-Host "Install Type:  Stand-Alone`n" 
            
            $installtype = "Stand-Alone"
            
            }

            else { 
                       $installtype = "Managed"

                        Write-Host "Install Type:  $installtype" 
                        Write-Host "QRadar Configuration Server:  $configserver"
                        Write-Host "QRadar Configuration Port:  $ConfigurationServerPort`n"
                        
                        #Check to make sure the token has been updated

                        if ($Authtoken -eq "") 

                            {

                            Write-Host 'Please run the script using the Authtoken parameter (i.e. .\ReInstallWinCollect.ps1 -Authtoken 9e32bca0-97f1-47c7-84da-4567605c814b, we need the authorization token created in QRadar.'

                            Exit

                            }

                        if ($Authtoken.Length -ne 36){
                        
                            Write-Host 'The Authtoken provied is not 36 characters long, please re-check the auth token and try again'

                            Exit

                            }
            
                    }


# Stop WinCollect Service

       Stop-WinCollect        


# Make a backup of the Agent-Config.xml and Install_config.txt

        Copy-Item -Path $InstallPath\config\AgentConfig.xml -Destination $AgentConfigBackup -Force

        Copy-Item -Path $InstallPath\config\install_config.txt -Destination $InstallConfigBackup -Force

        # Make sure the file is there, before we uninstall

        if (-Not (Test-Path -Path $AgentConfigBackup -PathType Leaf)) {Write-Host "Unable to backup AgentConfig.xml Exiting" Exit}

        if (-Not (Test-Path -Path $InstallConfigBackup -PathType Leaf)) {Write-Host "Unable to backup install_config.txt Exiting" Exit}


#Uninstall and then Install Agent

        if ($configserver -eq "" -and $statusserver -eq "") { $argument = '/s /v"/qn HOSTNAME=' + $appid + ' INSTALLDIR=\"' + $InstallPath +'""'}
        elseif ($configserver -eq "" -and $statusserver -ne "") { $argument = '/s /v"/qn HOSTNAME=' + $appid + ' INSTALLDIR=\"' + $InstallPath +'" STATUSSERVER=' + $statusserver + '"'}
        elseif ($configserver -ne "" -and $statusserver -eq "") { $argument = '/s /v"/qn HOSTNAME=' + $appid + ' FULLCONSOLEADDRESS=' + $configserver + ':' + $ConfigurationServerPort + ' AUTHTOKEN=' + $Authtoken + ' INSTALLDIR=\"' + $InstallPath +'""'}
        elseif ($configserver -ne "" -and $statusserver -ne "") { $argument = '/s /v"/qn HOSTNAME=' + $appid + ' FULLCONSOLEADDRESS=' + $configserver + ':' + $ConfigurationServerPort + ' AUTHTOKEN=' + $Authtoken + ' INSTALLDIR=\"' + $InstallPath +'" STATUSSERVER=' + $statusserver + '"'}
        else{write-host "Something is wrong trying to generate the Installation command, Exiting" Exit }

        Write-Host "Uninstalling WinCollect `n"
            
        Start-Process msiexec.exe -Wait -ArgumentList '/x {1E933549-2407-4A06-8EC5-83313513AE4B} REMOVE_ALL_FILES=True /qn'

        #Clean-up folders just in case

        if ( Test-Path -Path $InstallPath -PathType Container ) { "Remove-Item $InstallPath -Force  -Recurse -ErrorAction SilentlyContinue" }

        Write-Host "Installing WinCollect...`n"
        
        Write-Host "Installation Command: `n $env:SystemDrive\wincollect-7.3.0-24.$bit.exe $argument`n"
        
        Start-Process "$env:SystemDrive\wincollect-7.3.0-24.$bit.exe" -Wait -ArgumentList $argument
        
        
        
#If we are in stand alone copy in the new Agent-Config 

        if ($installtype -eq "Stand-Alone") {
        
                Write-Host "Waiting 30 seconds for Agent to finish installing"

                Start-Sleep -Seconds 10
                
                Write-Host "Copying back the AgentConfig and Restarting WinCollect"

                if (-Not (Test-Path -Path $AgentConfigBackup -PathType Leaf)) {Write-Host "Unable to find AgentConfig.xml something is wrong with the installation Exiting" Exit}

                Copy-Item -Path $AgentConfigBackup -Destination $InstallPath\config\AgentConfig.xml -Force

                write-host "Stopping WinCollect Service to apply backup configuration"
                        
                Stop-WinCollect
                 
                Start-Service -Name WinCollect
                
                Check-WinCollect

               
                }

        if ($installtype -eq "Managed") {
        
            Write-Host "Waiting 30 seconds for Agent to finish installing"

            Start-Sleep -Seconds 30
            
            Check-WinCollect

            Write-Host "`nNOTE: It could take 5-10 minutes, or more to get code and configuration updates from QRadar"
            
            }   

        
        


