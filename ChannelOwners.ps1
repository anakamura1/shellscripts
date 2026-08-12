Import-Module MicrosoftTeams
Disconnect-MicrosoftTeams
Connect-MicrosoftTeams
Get-Team -DisplayName "Decisions Org"

# Replace with the user’s email or UPN
$user = "aaron@decisions.com"
$teamID = (Get-Team -DisplayName "Decisions Org").GroupID
$results = @()

    # Get channel-level owners (only works for standard/public channels)
    $channels = Get-TeamChannel -GroupId $teamID
    foreach ($channel in $channels) {
        try {
            $chanUsers = Get-TeamChannelUser -GroupId $teamID -ErrorAction Stop -DisplayName $channel.DisplayName
            $chanOwners = $chanUsers | Where-Object { $_.Role -eq "Owner" } | Select-Object -ExpandProperty User
            if ($chanOwners -contains $user) {
                $results += [PSCustomObject]@{
                    Scope  = "Channel"
                    Channel = $channel.DisplayName
                }
            }
        } catch {
        
        }
    }


# Display results
$results | Format-Table -AutoSize

Update-Module MicrosoftTeams -Force



Import-Module MicrosoftTeams
Connect-MicrosoftTeams

$user = "heath@decisions.com"
$TeamId = "bb8d627f-c498-426f-a9b6-30e9036d1c37"
$results = @()

try {
    $channels = Get-TeamChannel -GroupId $TeamId -ErrorAction Stop
} catch {
    Write-Host "Error retrieving channels. Reconnecting and retrying..."
    Disconnect-MicrosoftTeams
    Connect-MicrosoftTeams
    $channels = Get-TeamChannel -GroupId $TeamId -ErrorAction Stop
}

foreach ($channel in $channels) {
    try {
        $chanUsers = Get-TeamChannelUser -GroupId $TeamId -DisplayName $channel.DisplayName -ErrorAction Stop
        $chanOwners = $chanUsers | Where-Object { $_.Role -eq "Owner" } | Select-Object -ExpandProperty User
        if ($chanOwners -contains $user) {
            $results += [PSCustomObject]@{
                Channel = $channel.DisplayName
                Owner   = $user
            }
        }
    } catch {
        Write-Host "Could not access channel '$($channel.DisplayName)' — likely private or restricted." -ForegroundColor Yellow
    }
}

$results | Format-Table -AutoSize


######################################################################## Channels in array 

# Replace with your Team name
# Read channel names from CSV (column "Name")
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

# Replace with your Team name
$teamName = "Decisions Org"
$teamID = "bb8d627f-c498-426f-a9b6-30e9036d1c37"

$channelList = Import-Csv "C:\Users\akira.nakamura\Downloads\ChannelsList_2025-10-17_18-38-59-UTC.csv"

$results = @()

foreach ($row in $channelList) {
    $channelName = $row.Name
    try {
        $users = Get-TeamChannelUser -GroupId $teamID -DisplayName $channelName -ErrorAction Stop
        $owners = $users | Where-Object { $_.Role -eq "Owner" } | Select-Object -ExpandProperty User
        $results += [PSCustomObject]@{
            Channel = $channelName
            Owners  = ($owners -join ", ")
        }
    } catch {
        Write-Host "Could not retrieve channel: $channelName" -ForegroundColor Yellow
    }
}

# Export results to CSV
$results | Export-Csv "C:\Users\akira.nakamura\Documents\ChannelOwners.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Done! Results saved to ChannelOwners.csv"

################################################################# Small Batch test

$PublicChannels = @(
    "Nomura Support"
)

# Replace with the correct Team ID for the team these channels belong to
$TeamId = "bb8d627f-c498-426f-a9b6-30e9036d1c37"

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


#### Parallel 

Import-Module MicrosoftTeams
Connect-MicrosoftTeams

$teamName = "Decisions Org"
$teamID = (Get-Team -DisplayName $teamName).GroupId

# Read CSV
$channelList = Import-Csv "C:\Users\akira.nakamura\Downloads\ChannelsList_2025-10-17_18-38-59-UTC.csv"
$teamID = (Get-Team -DisplayName "Decisions Org").GroupId

$results = $channelList | ForEach-Object -Parallel {
    param($teamID, $channelName)

    try {
        $users = Get-TeamChannelUser -GroupId $teamID -DisplayName $channelName -ErrorAction Stop
        $owners = $users | Where-Object { $_.Role -eq "Owner" } | Select-Object -Property User, Role
        foreach ($owner in $owners) {
            [PSCustomObject]@{
                Channel = $channelName
                User    = $owner.User
                Role    = $owner.Role
            }
        }
    } catch {
        # skip inaccessible channels
    }
} -ArgumentList $teamID, $_.Name -ThrottleLimit 10

$results | Export-Csv "C:\Users\akira.nakamura\Documents\ChannelOwners.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Done! Channel owners saved to CSV."



# Import module and connect
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

# Your team
$teamName = "Decisions Org"
$teamID = (Get-Team -DisplayName $teamName).GroupId

# Path to the CSV containing channel names (column "Name")
$csvPath = "C:\Users\akira.nakamura\Downloads\ChannelsList_2025-10-17_18-38-59-UTC.csv"
$channelList = Import-Csv -Path $csvPath | Select-Object -ExpandProperty Name

# Prepare results array
$results = @()

foreach ($channelName in $channelList) {
    try {
        $users = Get-TeamChannelUser -GroupId $teamID -DisplayName $channelName -ErrorAction Stop
        $owners = $users | Where-Object { $_.Role -eq "Owner" } | Select-Object User, Role

        if ($owners) {
            foreach ($owner in $owners) {
                $results += [PSCustomObject]@{
                    ChannelName = $channelName
                    User        = $owner.User
                    Role        = $owner.Role
                }
            }
        } else {
            # No owners found (rare)
            $results += [PSCustomObject]@{
                ChannelName = $channelName
                User        = "No owners found"
                Role        = ""
            }
        }

    } catch {
        # Error retrieving this channel
        $results += [PSCustomObject]@{
            ChannelName = $channelName
            User        = "Could not retrieve: $($_.Exception.Message)"
            Role        = ""
        }
    }
}

# Export to CSV
$exportPath = "C:\Users\akira.nakamura\Documents\ChannelOwners.csv"
$results | Export-Csv -Path $exportPath -NoTypeInformation -Force

Write-Host "Done! Channel owners saved to $exportPath."


# With Parallel Running in Pwsh 7

# Import module and connect
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

# === Variables ===

$csvPath    = "C:\Users\akira.nakamura\Downloads\ChannelsList_2025-10-17_18-38-59-UTC.csv"
$exportPath = "C:\Users\akira.nakamura\Documents\ChannelOwners_Parallel.csv"

# Get Team ID
$teamID = (Get-Team -DisplayName "Decisions Org").GroupId

# Import channel names from CSV
$channelList = Import-Csv -Path $csvPath | Select-Object -ExpandProperty Name

# Use $using:teamID to pass into each parallel runspace
$results = $channelList | ForEach-Object -Parallel {
    param($channelName)

    try {
        $users = Get-TeamChannelUser -GroupId $using:teamID -DisplayName $channelName -ErrorAction Stop
        $owners = $users | Where-Object { $_.Role -eq "Owner" } | Select-Object User, Role

        if ($owners) {
            $owners | ForEach-Object {
                [PSCustomObject]@{
                    ChannelName = $channelName
                    User        = $_.User
                    Role        = $_.Role
                }
            }
        }
        else {
            [PSCustomObject]@{
                ChannelName = $channelName
                User        = "No owners found"
                Role        = ""
            }
        }
    }
    catch {
        [PSCustomObject]@{
            ChannelName = $channelName
            User        = "Could not retrieve: $($_.Exception.Message)"
            Role        = ""
        }
    }

} -ThrottleLimit 8

# Export to CSV
$results | Export-Csv -Path $exportPath -NoTypeInformation -Force

Write-Host "✅ Done! Channel owners saved to $exportPath."



Import-Module MicrosoftTeams
Connect-MicrosoftTeams

$csvPath = "C:\Users\akira.nakamura\Downloads\ChannelsList_2025-10-17_18-38-59-UTC.csv"
$exportPath = "C:\Users\akira.nakamura\Documents\ChannelOwners.csv"

# Get your team
$teamName = "Decisions Org"
$teamID = (Get-Team -DisplayName $teamName).GroupId

# Clean and prepare the channel list
$channelList = Import-Csv -Path $csvPath |
    Where-Object { $_.Name -and $_.Name.Trim() -ne "" } |
    ForEach-Object { $_.Name.Trim() } |
    Sort-Object -Unique

Write-Host "Processing $($channelList.Count) channels..."

# Run in parallel
$results = $channelList | ForEach-Object -Parallel {
    param($teamID)

    # Capture each name in a local variable (important in parallel)
    $channelName = $_

    # Skip blank or invalid entries
    if (-not $channelName -or $channelName.Trim() -eq "") {
        return [PSCustomObject]@{
            ChannelName = "<empty>"
            User        = "Skipped: no name"
            Role        = ""
        }
    }

    try {
        $users = Get-TeamChannelUser -GroupId $teamID -DisplayName $channelName -ErrorAction Stop
        $owners = $users | Where-Object { $_.Role -eq "Owner" }

        if ($owners) {
            $owners | ForEach-Object {
                [PSCustomObject]@{
                    ChannelName = $channelName
                    User        = $_.User
                    Role        = $_.Role
                }
            }
        } else {
            [PSCustomObject]@{
                ChannelName = $channelName
                User        = "No owners found"
                Role        = ""
            }
        }

    } catch {
        [PSCustomObject]@{
            ChannelName = $channelName
            User        = "Could not retrieve: $($_.Exception.Message)"
            Role        = ""
        }
    }

} -ArgumentList $teamID -ThrottleLimit 8  # Adjust parallel threads

# Export
$results | Export-Csv -Path $exportPath -NoTypeInformation -Force

Write-Host "✅ Done! Results saved to $exportPath."


# Import module and connect
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

# Team info
$teamName = "Decisions Org"
$teamID = (Get-Team -DisplayName $teamName).GroupId

# Load channels from CSV
$channelList = Import-Csv "C:\Users\akira.nakamura\Downloads\ChannelsList_2025-10-17_18-38-59-UTC.csv"

# Prepare
$MaxConcurrentJobs = 5
$jobs = @()
$totalChannels = $channelList.Count
$processed = 0

foreach ($channel in $channelList) {
    # Wait until below max concurrent jobs
    while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $MaxConcurrentJobs) {
        Start-Sleep -Seconds 2
    }

    # Start a new job
    $jobs += Start-ThreadJob -ScriptBlock {
        param($teamID, $channelName)
        try {
            $users = Get-TeamChannelUser -GroupId $teamID -DisplayName $channelName -ErrorAction Stop
            $owners = $users | Where-Object { $_.Role -eq "Owner" } | Select-Object -ExpandProperty User

            if ($owners) {
                $owners | ForEach-Object {
                    [PSCustomObject]@{
                        ChannelName = $channelName
                        User        = $_
                        Role        = "Owner"
                    }
                }
            } else {
                [PSCustomObject]@{
                    ChannelName = $channelName
                    User        = "No owners found"
                    Role        = ""
                }
            }
        } catch {
            [PSCustomObject]@{
                ChannelName = $channelName
                User        = "Could not retrieve: $($_.Exception.Message)"
                Role        = ""
            }
        }
    } -ArgumentList $teamID, $channel.Name

    $processed++
    Write-Host "Queued $processed of $totalChannels channels..."
}

# Wait for all jobs to finish and collect results
$results = Receive-Job -Job (Get-Job) -Wait -AutoRemoveJob

# Export CSV
$exportPath = "C:\Users\akira.nakamura\Documents\ChannelOwners_Parallel.csv"
$results | Export-Csv -Path $exportPath -NoTypeInformation -Force

Write-Host "Done! Channel owners saved to $exportPath."




# Import module and connect
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

# Team info
$teamName = "Decisions Org"
$teamID = (Get-Team -DisplayName $teamName).GroupId

# Create a private channel
$channelName = "Town Hall"
$channelDescription = "Town Hall Links and Information"


New-TeamChannel -GroupId $teamID `
                -DisplayName $channelName `
                -Description $channelDescription `
                -MembershipType Private `
          

# Hard DELETE PRIVATE CHANNELS

# Import the Teams module and connect if not already connected
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

# Define the Team and the deleted channel to hard delete
$TeamID = "bb8d627f-c498-426f-a9b6-30e9036d1c37"
$DeletedChannelName = "Axos Renewal"

# Permanently remove the deleted private channel
Remove-TeamChannel -GroupId $TeamID -DisplayName $DeletedChannelName 


Connect-ExchangeOnline
$user = "erik.samuelson@decisions.com"
Get-MailboxFolderStatistics -Identity $user | Select-Object Name, FolderPath, ItemsinFolder, ItemsInFolderAndSubfolders, FolderSize | Where-Object {$_.Name -like "*Decisions*"}