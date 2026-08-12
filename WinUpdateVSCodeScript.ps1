### Installs module and dependencies. IF ERROR, run row three ### 
Install-Module PSWindowsUpdate
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
 
### Runs Windows and Microsoft Update and logs the result ###
$logFile = "C:\PSWindowsUpdate\Logs\$(Get-Date -Format 'yyyy-MM-dd_HHmmss').log"
"Script started at $(Get-Date)" | Out-File $logFile -Force
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot *>&1 | Out-File $logFile -Append
"Script finished successfully at $(Get-Date)" | Out-File $logFile -Append
 
### Creates the scheduled task ###
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\PSWindowsUpdate\Script\WindowsUpdate.ps1"'
#$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -WeeksInterval 4 -At 03:00AM
$Trigger = New-ScheduledTaskTrigger -MonthlyDOW -WeeksInterval 1 -DaysOfWeek Sunday -At 09:00AM
Register-ScheduledTask -TaskName "My_PSWindowsUpdate" -Action $Action -Trigger $Trigger -User "SYSTEM" -RunLevel Highest


#schtasks.exe /Create /TN "MonthlyFirstSundayTask" `
#/TR "powershell.exe -ExecutionPolicy Bypass -File 'C:\PSWindowsUpdate\Script\WindowsUpdate.ps1'" `
#/SC ONCE /ST 15:30 /F

schtasks /create /tn "Monthly_Windows_Update_Check" `
    /tr "powershell.exe -ExecutionPolicy Bypass -File 'C:\PSWindowsUpdate\Script\WindowsUpdate.ps1'" `
    /sc monthly /mo FIRST /d SUN /st 09:00 /rl HIGHEST /ru "NT AUTHORITY\SYSTEM"

### Creating the Logs folder in C: drive ###
$dir = "C:\PSWindowsUpdate\Logs"
if (-not (Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory -Force
    Write-Output "Created directory: $dir"
} else {
    Write-Output "Directory already exists."
}

### Put's the script into WindowsUpdate.ps1 ###
$scriptDir = "C:\PSWindowsUpdate\Script"
if (-not (Test-Path $scriptDir)) { 
    New-Item -Path $scriptDir -ItemType Directory -Force 
}

$scriptContent = @'
$logFile = "C:\PSWindowsUpdate\Logs\$(Get-Date -Format 'yyyy-MM-dd_HHmmss').log"
"Script started at $(Get-Date)" | Out-File $logFile -Force
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot *>&1 | Out-File $logFile -Append
"Script finished successfully at $(Get-Date)" | Out-File $logFile -Append
'@
# 3. Write the content to the file
$filePath = "$scriptDir\WindowsUpdate.ps1"
$scriptContent | Out-File -FilePath $filePath -Force -Encoding utf8

Write-Output "Successfully created $filePath"