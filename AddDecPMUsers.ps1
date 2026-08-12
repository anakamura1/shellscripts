

Import-Module MicrosoftTeams
Connect-MicrosoftTeams

#Get GroupId
$teamID = (Get-Team -DisplayName "Global Team").GroupId

#Import CSV of PM guests
#CSV should have "Email" and "Role" columns

$users = Import-Csv -Path "C:\Users\akira.nakamura\Downloads\DecPM.csv"

foreach ($user in $users) {
    Add-TeamUser -GroupId $teamID -User $user.Email -Role $user.Role
}

#Alternatively

$teamID = (Get-Team -DisplayName "Global Team").GroupId
$users = @("russell.smith@decisions.com", "jacob.andrews@decisions.com") 

foreach ($user in $users) {
    Add-TeamUser -GroupId $teamID -User $user -Role Member
    Write-Host "Added User: $user as Member" -ForegroundColor Green
}