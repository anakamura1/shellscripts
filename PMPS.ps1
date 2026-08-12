Connect-ExchangeOnline

Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\PMPSDevs.csv" | ForEach-Object {

$original = $_.WorkEmail
$PMemail = $original.Split("@")[0]
$DecEmail = "$PMemail@decisions.com"
Add-DistributionGroupMember -Identity psdev@decisions.com -Member $DecEmail

}

$excel = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\PMPSDevs.csv"

foreach ($user in $excel) {
    $original = $user.WorkEmail
    $department = $user.Dept
    $UPN = $original.Split("@")[0]
    $newemail = "$UPN@decisions.com"

[PSCustomObject]@{
 NewEmail = $newemail
 Department = $department
}
}