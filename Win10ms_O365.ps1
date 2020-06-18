Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Script: Win10ms_O365_Apps.ps1                                                                ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Description: Customization to build a WVD Windows 10ms image                               ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** This script configures the Microsoft recommended configuration for a Win10ms image:        ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Article: Prepare and customize a master VHD image                                          ***' 
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image       ***' 
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Article: Install Office on a master VHD image                                              ***' 
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** https://docs.microsoft.com/en-us/azure/virtual-desktop/install-office-on-wvd-master-image  ***' 
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Note: All setting that can be configured through GPO are NOT included   !!!                ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Version: 0.0.1                                                                             ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Date: 10 June 2020                                                                         ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Name: Roel Schellens                                                                     ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Company: Microsoft                                                                         ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** Set Variables ***'
#NOTE: Make sure to update these variables for your environment!!! ***
$AADTenantID = "<your-AzureAdTenantId>"


Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: Settings for FSLogix can be configured through GPO's)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'
Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET REGKEY *** Disable Automatic Updates ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'NoAutoUpdate' -Value '1' -PropertyType DWORD -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET REGKEY *** Specify Start layout for Windows 10 PCs (optional) ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SpecialRoamingOverrideAllowed' -Value '1' -PropertyType DWORD -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET REGKEY *** Set up time zone redirection ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fEnableTimeZoneRedirection' -Value '1' -PropertyType DWORD -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET REGKEY *** Disable Storage Sense ***'
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense' -Name 'AllowStorageSenseGlobal' -Value '0' -PropertyType DWORD -Force | Out-Null

# Note: Remove if not required!
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET REGKEY *** For feedback hub collection of telemetry data on Windows 10 Enterprise multi-session ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value '3' -PropertyType DWORD -Force | Out-Null

# Note: Remove if not required!
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET REGKEYS *** Fix 5k resolution support ***'
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'MaxMonitors' -Value '4' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'MaxXResolution' -Value '5120' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'MaxYResolution' -Value '2880' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs' -Name 'MaxMonitors' -Value '4' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs' -Name 'MaxXResolution' -Value '5120' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs' -Name 'MaxYResolution' -Value '2880' -PropertyType DWORD -Force | Out-Null


Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE *** Update the default Office behavior ***'
Write-Host "Mount default registry hive"
& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT
Push-Location 'TempDefault\SOFTWARE\Policies\Microsoft\office\16.0\common'
if (!(Test-Path Main)) {
  Write-Warning "Adding missing default keys for IE"
  New-Item Main
}
#STILL WORKING ON THIS !!!! https://gist.github.com/goyuix/fd68db59a4f6355ee0f6
reg add HKU\TempDefault\SOFTWARE\Policies\Microsoft\office\16.0\common /v TempDefault\SOFTWARE\Policies\Microsoft\office\16.0\common /t REG_DWORD /d 2 /f
rem Set Outlook's Cached Exchange Mode behavior
rem Must be executed with default registry hive mounted.
reg add "HKU\TempDefault\software\policies\microsoft\office\16.0\outlook\cached mode" /v enable /t REG_DWORD /d 1 /f
reg add "HKU\TempDefault\software\policies\microsoft\office\16.0\outlook\cached mode" /v syncwindowsetting /t REG_DWORD /d 1 /f
reg add "HKU\TempDefault\software\policies\microsoft\office\16.0\outlook\cached mode" /v CalendarSyncWindowSetting /t REG_DWORD /d 1 /f
reg add "HKU\TempDefault\software\policies\microsoft\office\16.0\outlook\cached mode" /v CalendarSyncWindowSettingMonths  /t REG_DWORD /d 1 /f
rem Unmount the default user registry hive
reg unload HKU\TempDefault

rem Set the Office Update UI behavior.
reg add HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate /v hideupdatenotifications /t REG_DWORD /d 1 /f
reg add HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate /v hideenabledisableupdates /t REG_DWORD /d 1 /f


Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL ONEDRIVE *** Uninstall Ondrive per-user mode and Install OneDrive in per-machine mode ***'
Invoke-WebRequest -Uri 'https://aka.ms/OneDriveWVD-Installer' -OutFile 'c:\temp\OneDriveSetup.exe'
New-Item -Path 'HKLM:\Software\Microsoft\OneDrive' -Force | Out-Null
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\OneDriveSetup.exe /uninstall'
New-ItemProperty -Path 'HKLM:\Software\Microsoft\OneDrive' -Name 'AllUsersInstall' -Value '1' -PropertyType DWORD -Force | Out-Null
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\OneDriveSetup.exe /allusers'
Start-Sleep -Seconds 10
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Configure OneDrive to start at sign in for all users. ***'
New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OneDrive' -Value 'C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe /background' -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Silently configure user account ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive' -Name 'SilentAccountConfig' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Redirect and move Windows known folders to OneDrive by running the following command. ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive' -Name 'KFMSilentOptIn' -Value $AADTenantID -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install C++ Redist for RTCSvc (Teams Optimized) ***'
Invoke-WebRequest -Uri 'https://aka.ms/vs/16/release/vc_redist.x64.exe' -OutFile 'c:\temp\vc_redist.x64.exe'
Invoke-Expression -Command 'C:\temp\vc_redist.x64.exe /install /quiet /norestart'
Start-Sleep -Seconds 15

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install RTCWebsocket to optimize Teams for WVD ***'
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Name 'IsWVDEnvironment' -Value '1' -PropertyType DWORD -Force | Out-Null
Invoke-WebRequest -Uri 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4vkL6' -OutFile 'c:\temp\MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi' 
Invoke-Expression -Command 'msiexec /i c:\temp\MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi /quiet /l*v C:\temp\MsRdcWebRTCSvc_HostSetup.log ALLUSER=1'
Start-Sleep -Seconds 15

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Install Teams in Machine mode ***'
Invoke-WebRequest -Uri 'https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.4461/Teams_windows_x64.msi' -OutFile 'c:\temp\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\temp\Teams.msi /quiet /l*v C:\temp\teamsinstall.log ALLUSER=1 ALLUSERS=1'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. ***'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
Start-Sleep -Seconds 30




Write-Host '*** WVD AIB Customize phase ********************* END *************************'
