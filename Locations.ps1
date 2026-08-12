####################################WHQ 
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

Get-DistributionGroupMember "WHQ" | Select-Object DisplayName, PrimarySmtpAddress | Export-Csv "C:\Users\akira.nakamura\Documents"

$MyWHQ = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\My WHQ.csv"

$WHQPosh = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\WHQPosh.csv"

Compare-Object `
-ReferenceObject $MyWHQ.Email `
-DifferenceObject $WHQPosh.PrimarySmtpAddress

##########################################US REMOTE

Get-DistributionGroupMember "US Remote" | Select-Object DisplayName, PrimarySmtpAddress | Export-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\USRemotePosh.csv"
Get-DistributionGroupMember "Global Remote" | Select-Object DisplayName, PrimarySmtpAddress | Export-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\GlobalRemote.csv"

$USRemote = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\USRemotePosh.csv"
$MyUSRemote = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\MyUSRemote.csv"


Compare-Object `
-ReferenceObject $MyUSRemote.Email `
-DifferenceObject $USRemote.PrimarySmtpAddress


#############################################GLOBAL REMOTE

$GlobalRemote = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\GlobalRemotePosh.csv"
$MyGlobalRemote = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\MyGlobalRemote.csv"

Compare-Object `
-ReferenceObject $MyGlobalRemote.Email `
-DifferenceObject $GlobalRemote.PrimarySmtpAddress

#############################################Bolivia

Get-DistributionGroupMember "ProcessMaker Bolivia" | Select-Object DisplayName, PrimarySmtpAddress | Export-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\PMBoliviaPosh.csv"

$Bolivia = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\PMBoliviaPosh.csv"
$MyBolivia = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\MyBolivia.csv"

Compare-Object `
-ReferenceObject $MyBolivia.Email `
-DifferenceObject $Bolivia.PrimarySmtpAddress

###########################################GOC
$GOCgroups = @('GOC IT','GOC Finance','GOC Customer Support','GOC Leads', 'GOC_PS','GOC R&D','GOC RevOps','GOC Support Functions', 'GOC People Managers', 'GOC Presales', 'GOC Solutions','GOC Training','GOC Talent')

 $GOCusers= foreach( $group in $GOCgroups){
    Get-DistributionGroupMember $group | Select-Object DisplayName, PrimarySmtpAddress

}
 $GOCusers |Export-Csv C:\Users\akira.nakamura\Documents\CSV_Files\GOCoutput.csv

$MyGOC = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\MyGOC.csv"
Compare-Object `
-ReferenceObject $MyGOC.Email `
-DifferenceObject $GOCusers.PrimarySmtpAddress

###########################################MUMBAI

Get-DistributionGroupMember "Mumbai Team" | Select-Object DisplayName,PrimarySmtpAddress | Export-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\MumbaiPosh.csv"

$MyMumbai = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\MyMumbai.csv"
$Mumbai = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\MumbaiPosh.csv"

Compare-Object `
-ReferenceObject $MyMumbai.Email `
-DifferenceObject $Mumbai.PrimarySmtpAddress
Write-Host "No discrepancies"


################################# Add members to US Remote

$users = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\AddUSRemote.csv"

foreach($user in $users) {
    Add-DistributionGroupMember -Identity "US Remote" -Member $user.Email
}

##################################### Add members to Global Remote

$users = Import-Csv "C:\Users\akira.nakamura\Documents\CSV_Files\AddGlobalRemote.csv"

foreach($user in $users) {
    Add-DistributionGroupMember -Identity "Global Remote" -Member $user.Email
}