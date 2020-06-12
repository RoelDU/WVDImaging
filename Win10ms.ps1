Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************************************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Name: Win10ms.ps1 **********************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Description: Customization to build a WVD Windows 10ms image ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Version: 0.0.1 *************************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Date: 10 June 2020 *********************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** AUthor: Roel Schellens *****************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Company: Microsoft *********************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************************************************************'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null
New-Item -Path 'C:\temp\Win20ms2004v001' -ItemType Directory -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install BGInfo to c:\temp. ***'
Invoke-WebRequest -Uri 'https://live.sysinternals.com/Bginfo.exe' -OutFile 'c:\temp\BGInfo.exe'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name BgInfo -PropertyType string -Value 'C:\Temp\Bginfo.exe /timer:0 /nolicprompt' -force
Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Visual Studio Code ver.latest***'
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile 'c:\temp\VScode.exe'
Invoke-Expression -Command 'c:\temp\VScode.exe /verysilent'
Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Notepadplusplus ver.7.7.1 ***'
Invoke-WebRequest -Uri 'https://notepad-plus-plus.org/repository/7.x/7.7.1/npp.7.7.1.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'
Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: GPOs will be used for configuring FSLogix)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Start-Sleep -Seconds 10
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'
Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install OneDrive in per-machine mode ***'
Invoke-WebRequest -Uri 'https://aka.ms/OneDriveWVD-Installer' -OutFile 'c:\temp\OneDriveSetup.exe'
New-Item -Path 'HKLM:\Software\Microsoft\OneDrive' -Force | Out-Null
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\OneDriveSetup.exe /uninstall
New-ItemProperty -Path 'HKLM:\Software\Microsoft\OneDrive' -Name 'AllUsersInstall' -Value '1' -PropertyType DWORD -Force | Out-Null
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\OneDriveSetup.exe /allusers'
Start-Sleep -Seconds 10

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
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
Start-Sleep -Seconds 30

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Set TLS1.2 enforced ***'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host '*** WVD AIB Customize phase ********************* END *************************'
