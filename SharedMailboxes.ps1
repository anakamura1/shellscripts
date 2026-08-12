Connect-ExchangeOnline
Import-Csv "C:\Users\akira.nakamura\Downloads\PM Shared Mailboxes(Sheet1).csv" | ForEach-Object {
 $email = $_.SharedMailboxes
    $name = $_.DisplayName
    $alias = $email.Split("@")[0]

    New-Mailbox -Shared `
    -Name $name `
    -PrimarySmtpAddress $email `
    -DisplayName $name `
    -Alias $alias
    
}

New-Mailbox -Shared -Name "BuildBot" -DisplayName "BuildBot" -PrimarySmtpAddress "buildbot@processmaker.com" 

