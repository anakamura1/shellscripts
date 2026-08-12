# 1. Path to your input and output files
# Install module (if not already installed)
Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

$csvPath = "C:\Users\akira.nakamura\Desktop\GlobalTeam_Members.csv"
$outputPath = "C:\Users\akira.nakamura\Desktop\SignInStatus_Report.csv"

# 2. Read users from CSV and check status
$results = Import-Csv -Path $csvPath | ForEach-Object {
    $email = $_.Email.Trim()
    
    # Query Microsoft Graph for the user
    $user = Get-MgUser -UserId $email -Property DisplayName, UserPrincipalName, AccountEnabled -ErrorAction SilentlyContinue

    if ($user) {
        [PSCustomObject]@{
            Email          = $email
            DisplayName    = $user.DisplayName
            UserExists     = $true
            # If AccountEnabled is $false, Sign-In is Blocked
            IsSignInBlocked = (-not $user.AccountEnabled)
            AccountEnabled = $user.AccountEnabled
        }
    } else {
        # Account was not found in Entra ID
        [PSCustomObject]@{
            Email          = $email
            DisplayName    = "N/A"
            UserExists     = $false
            IsSignInBlocked = "Unknown (User Not Found)"
            AccountEnabled = $false
        }
    }
}

# 3. Output to screen
$results | Format-Table -AutoSize

# 4. Export results to CSV
$results | Export-Csv -Path $outputPath -NoTypeInformation
Write-Host "Report saved to $outputPath" -ForegroundColor Green