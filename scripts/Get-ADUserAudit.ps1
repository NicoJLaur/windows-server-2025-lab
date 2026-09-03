Import-Module ActiveDirectory

$SearchBase = "OU=Users List,DC=ad,DC=nlaur,DC=com"
$ReportPath = "C:\Scripts\Reports\AD-User-Audit.csv"

$Users = Get-ADUser `
    -Filter * `
    -SearchBase $SearchBase `
    -Properties Department, Enabled, LastLogonDate,
                PasswordLastSet, PasswordNeverExpires

$Report = foreach ($User in $Users) {

    $Groups = Get-ADPrincipalGroupMembership $User |
        Where-Object {$_.Name -ne "Domain Users"} |
        Select-Object -ExpandProperty Name

    [PSCustomObject]@{
        Name                 = $User.Name
        Username             = $User.SamAccountName
        Department           = $User.Department
        Enabled              = $User.Enabled
        LastLogonDate        = $User.LastLogonDate
        PasswordLastSet      = $User.PasswordLastSet
        PasswordNeverExpires = $User.PasswordNeverExpires
        Groups               = ($Groups -join "; ")
    }
}

$Report |
    Sort-Object Username |
    Export-Csv $ReportPath -NoTypeInformation

Write-Host "AD user audit completed."
Write-Host "Report saved to: $ReportPath"