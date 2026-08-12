# List of private channels
$PrivateChannels = @(
    "Health in Designers",
    "hirepm",
    "Mumbai",
    "FIS-5th Sept 2024",
    "HR Dynamic Questionnaire Project",
    "Mumbai IT-OPS",
    "qa_automation_hiring",
    "PS and Solutions Team",
    "Mumbai IT-OPs-QA",
    "Resume Review - Senior DD Oct 2024",
    "manual-qa-interview",
    "Junior Technical Trainer Freshers Hiring Updates",
    "Axos Renewal",
    "DocBot Training",
    "CNU-Football Alum",
    "Decisions_Taylors_Version",
    "Decisions Prays",
    "fire-recovery-escalation",
    "July19EmergencyResponseTeam",
    "goc_leads",
    "Tirade A Production System",
    "Process Mining Dev",
    "Chay",
    "Case Study Prospects",
    "Cloud Ops_hiring",
    "Gartner Sync",
    "forWelmerink",
    "Log-Matcher-Regex-Project",
    "PS and Product Management",
    "POC Developer-PreSales Engineer-Hiring Team"
)

# Define multiple 90-day windows to go further back
$StartDates = @(
    (Get-Date).AddDays(-90),
    (Get-Date).AddDays(-180),
    (Get-Date).AddDays(-270)
)
$EndDates = @(
    (Get-Date),
    (Get-Date).AddDays(-90),
    (Get-Date).AddDays(-180)
)

# Operations to check
$Ops = @(
    "MessagePostedToChannel",
    "MessageDeletedFromChannel",
    "MessageEdited",
    "ReactedToMessage",
    "ChannelCreated",
    "ChannelDeleted"
)

$AllLogs = @()

for ($i = 0; $i -lt $StartDates.Count; $i++) {
    Write-Host "Querying audit logs from $($StartDates[$i]) to $($EndDates[$i])..."
    $Logs = Search-UnifiedAuditLog -StartDate $StartDates[$i] -EndDate $EndDates[$i] -Operations $Ops -ResultSize 5000
    $AllLogs += $Logs
}

# Filter logs for the listed private channels
$PrivateChannelLogs = $AllLogs | Where-Object {
    $data = $_.AuditData | ConvertFrom-Json
    $PrivateChannels -contains $data.ChannelName
}

# Get last activity per channel
$LastActivity = $PrivateChannelLogs |
    Group-Object { ($_.AuditData | ConvertFrom-Json).ChannelName } |
    ForEach-Object {
        $_.Group | Sort-Object CreationDate -Descending | Select-Object -First 1
    }
###############################################################################################################


#Connect to teams
Import-Module MicrosoftTeams -RequiredVersion 7.3.1
Get-Command -Module MicrosoftTeams
Connect-MicrosoftTeams

#Put in the team ID, and CHANNEL NAME, you can see the users of private channels you are apart of
Get-Team | Select-Object DisplayName, GroupId
# A private channel that I am in
Get-TeamChannelUser -GroupId 1c9aafae-49a2-4004-a237-5d5cf8af6916 -DisplayName "Internal IT"

Get-TeanChannelUser -GroupId bb8d627f-c498-426f-a9b6-30e9036d1c37 -DisplayName "Mumbai"
#Test script with Technology team and public channels
$Channels = @(
"Alerts",
"General",
"Provisioning",
"Error Planet"

)
foreach ($channel in $Channels) {
    try {
        Get-TeamChannelUser -GroupId bb8d627f-c498-426f-a9b6-30e9036d1c37 -DisplayName $channel
    }
    catch {
        Write-Host "Could not find users in $channel; $_"
    }
}






# FOR GLOBAL ADMIN. Add yourself to all these channels. 
# Add yourself to the channels that the owners are cool with you deleting, if they can't delete for some reason

$PrivateChannels = @(
    "Health in Designers",
    "hirepm",
    "Mumbai",
    "FIS-5th Sept 2024",
    "HR Dynamic Questionnaire Project",
    "Mumbai IT-OPS",
    "qa_automation_hiring",
    "PS and Solutions Team",
    "Mumbai IT-OPs-QA",
    "Resume Review - Senior DD Oct 2024",
    "manual-qa-interview",
    "Junior Technical Trainer Freshers Hiring Updates",
    "Axos Renewal",
    "DocBot Training",
    "CNU-Football Alum",
    "Decisions_Taylors_Version",
    "Decisions Prays",
    "fire-recovery-escalation",
    "July19EmergencyResponseTeam",
    "goc_leads",
    "Tirade A Production System",
    "Process Mining Dev",
    "Chay",
    "Case Study Prospects",
    "Cloud Ops_hiring",
    "Gartner Sync",
    "forWelmerink",
    "Log-Matcher-Regex-Project",
    "PS and Product Management",
    "POC Developer-PreSales Engineer-Hiring Team"
)

# Your account
$MyUser = "elliott.butler@decisions.com"

# Loop through channels
foreach ($channel in $PrivateChannels) {
    try {
        Write-Host "Adding $MyUser as owner to $channel..."
        Add-TeamChannelUser -GroupId bb8d627f-c498-426f-a9b6-30e9036d1c37 -DisplayName $channel -User $MyUser -Role Owner
        Write-Host "✅ Added $channel"
    } catch {
        Write-Warning "Could not add $channel; $_"
    }
}



####SEND THIS TO ELLIOTT SO HE CAN SEE ALL THE PRIVATE CHANNEL OWNERS 

# List of private channels
$PrivateChannels = @(
    "Health in Designers",
    "hirepm",
    "Mumbai",
    "FIS-5th Sept 2024",
    "HR Dynamic Questionnaire Project",
    "Mumbai IT-OPS",
    "qa_automation_hiring",
    "PS and Solutions Team",
    "Mumbai IT-OPs-QA",
    "Resume Review - Senior DD Oct 2024",
    "manual-qa-interview",
    "Junior Technical Trainer Freshers Hiring Updates",
    "Axos Renewal",
    "DocBot Training",
    "CNU-Football Alum",
    "Decisions_Taylors_Version",
    "Decisions Prays",
    "fire-recovery-escalation",
    "July19EmergencyResponseTeam",
    "goc_leads",
    "Tirade A Production System",
    "Process Mining Dev",
    "Chay",
    "Case Study Prospects",
    "Cloud Ops_hiring",
    "Gartner Sync",
    "forWelmerink",
    "Log-Matcher-Regex-Project",
    "PS and Product Management",
    "POC Developer-PreSales Engineer-Hiring Team"
)

# Connect to Teams
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

# Replace with the correct Team ID for the team these channels belong to
$TeamId = "bb8d627f-c498-426f-a9b6-30e9036d1c37"

# Loop through each channel and get owners
$ChannelOwners = foreach ($channel in $PrivateChannels) {
    try {
        $members = Get-TeamChannelUser -GroupId $TeamId -DisplayName $channel
        $owners = $members | Where-Object { $_.Role -eq "Owner" }
        [PSCustomObject]@{
            ChannelName = $channel
            Owners      = ($owners | Select-Object -ExpandProperty User) -join ", "
        }
    } catch {
        [PSCustomObject]@{
            ChannelName = $channel
            Owners      = "Could not retrieve: $_"
        }
    }
}


$ChannelOwners | Format-Table -AutoSize

# Optional: export to CSV
# $ChannelOwners | Export-Csv -Path "PrivateChannelOwners.csv" -NoTypeInformation

###PERSONAL TEST WITH PUBLIC CHANNELS THAT ARE IN THE TECHNOLOGY TEAM
# List of public channels
$PublicChannels = @(
    "Alerts",
"General",
"Provisioning",
"Error Planet"
)

# Replace with the correct Team ID for the team these channels belong to
$TeamId = "1c9aafae-49a2-4004-a237-5d5cf8af6916"

# Loop through each channel and get owners
$ChannelOwners = foreach ($channel in $PublicChannels) {
    try {
        $members = Get-TeamChannelUser -GroupId $TeamId -DisplayName $channel
        $owners = $members | Where-Object { $_.Role -eq "Owner" }
        [PSCustomObject]@{
            ChannelName = $channel
            Owners      = ($owners | Select-Object -ExpandProperty User) -join ", "
        }
    } catch {
        [PSCustomObject]@{
            ChannelName = $channel
            Owners      = "Could not retrieve: $_"
        }
    }
}

# Display results
$ChannelOwners | Format-Table -AutoSize

# Optional: export to CSV
$ChannelOwners | Export-Csv -Path "PrivateChannelOwners.csv" -NoTypeInformation
