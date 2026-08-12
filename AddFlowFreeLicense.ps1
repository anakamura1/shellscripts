Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"
#This one for Power Autumate Free
$users = Import-Csv "C:\Users\akira.nakamura\Downloads\AddPALicenseCSV.csv"
foreach ($user in $users) {
Set-MgUserLicense -UserId $user.UPN -AddLicenses @{SkuId = "f30db892-07e9-47e9-837c-80727f46fd3d"} -removeLicenses @()
}

#This one for Power Apps Dev
$users = Import-Csv "C:\Users\akira.nakamura\Downloads\AddPALicenseCSV.csv"
foreach ($user in $users) {
Set-MgUserLicense -UserId $user.UPN -AddLicenses @{SkuId = "5b631642-bd26-49fe-bd20-1daaa972ef80"} -RemoveLicenses @()
}
