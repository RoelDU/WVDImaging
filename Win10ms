############################################################
#  Script to setup golden image with Azure Image Builder
#
#  Name: Roel Schellens
#  Version: 0.0.4
#  Date: 4 June 2020
#############################################################

#Create temp folder
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null
New-Item -Path 'C:\temp\Win20ms2004v004' -ItemType Directory -Force | Out-Null

#Copy BGInfo to VM
Invoke-WebRequest -Uri 'https://live.sysinternals.com/Bginfo.exe' -OutFile 'c:\temp\BGInfo.exe'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name BgInfo -PropertyType string -Value 'C:\Temp\Bginfo.exe /timer:0 /nolicprompt' -force

#Start sleep
Start-Sleep -Seconds 10

#Install VSCode
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile 'c:\temp\VScode.exe'
Invoke-Expression -Command 'c:\temp\VScode.exe /verysilent'

#Start sleep
Start-Sleep -Seconds 10

#InstallNotepadplusplus
Invoke-WebRequest -Uri 'https://notepad-plus-plus.org/repository/7.x/7.7.1/npp.7.7.1.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'

#Start sleep
Start-Sleep -Seconds 10

#InstallFSLogix (Note: Not setting Registry Keys as GPO's will be used)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Start-Sleep -Seconds 10
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'

#Start sleep
Start-Sleep -Seconds 10

#Install C++ Redist for RTCSvc (Teams Optimized)
Invoke-WebRequest -Uri 'https://aka.ms/vs/16/release/vc_redist.x64.exe' -OutFile 'c:\temp\vc_redist.x64.exe'
Invoke-Expression -Command 'C:\temp\vc_redist.x64.exe /install /quiet /norestart'

#Start sleep
Start-Sleep -Seconds 15

#Set Regkey and Install RTCWebsocket to optimize Teams for WVD
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Name 'IsWVDEnvironment' -Value '1' -PropertyType DWORD -Force | Out-Null
Invoke-WebRequest -Uri 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4vkL6' -OutFile 'c:\temp\MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi /quiet /l*v C:\temp\MsRdcWebRTCSvc_HostSetup.log ALLUSER=1'

#Start sleep
Start-Sleep -Seconds 15

#InstallTeamsMachinemode 
Invoke-WebRequest -Uri 'https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.4461/Teams_windows_x64.msi' -OutFile 'c:\temp\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\temp\Teams.msi /quiet /l*v C:\temp\teamsinstall.log ALLUSER=1 ALLUSERS=1'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force

#Start sleep
Start-Sleep -Seconds 30

#Start sleep
Start-Sleep -Seconds 10

#Set TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Temp Fix for Win10 ms 20H1
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs' -Name 'fReverseConnectMode' -Value '1' -PropertyType DWORD -Force | Out-Null
