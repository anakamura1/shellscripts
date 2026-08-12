Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes User.Read.All

$csvfile = Import-Csv -Path "/Users/akira.nakamura/Downloads/SignInStatus_Report(SignInStatus_Report).csv"

$results = foreach ($user in $csvfile) {

    $email = $user.Email.Trim()

    $userinfo = Get-MgUser -UserId $email -Property UserPrincipalName, AccountEnabled -ErrorAction SilentlyContinue


    if ($userinfo) {
    [PSCustomObject]@{
    User = $userinfo.UserPrincipalName
    Enabled = $userinfo.AccountEnabled
    Blocked = ( -not $userinfo.AccountEnabled)
    }
} else {
    [PSCustomObject]@{
        User = $userinfo.UserPrincipalName
        Enabled = "User Not Found"
        Blocked = "User Not Found"
    }
}
}

$results | Format-Table -AutoSize
$results | Export-Csv -Path "/Users/akira.nakamura/Documents/GlobalTeamUserStatus.csv" 