param (
    [Parameter(Mandatory=$true)]
    [string]$Username
)

Import-Module ActiveDirectory

$DisabledUsersOU = "OU=Disabled Users,DC=ad,DC=nlaur,DC=com"
$LogDirectory = "C:\Scripts\Reports"
$LogFile = "$LogDirectory\Offboarding-Log.csv"

$User = Get-ADUser $Username -Properties Department,MemberOf

if (-not $User) {
    Write-Host "User $Username was not found."
    exit
}

Write-Host "Offboarding user: $($User.Name)"

# Record existing group memberships
$Groups = Get-ADPrincipalGroupMembership $User |
    Where-Object {$_.Name -ne "Domain Users"}

# Remove additional group memberships
foreach ($Group in $Groups) {

    Remove-ADGroupMember `
        -Identity $Group `
        -Members $User `
        -Confirm:$false

    Write-Host "Removed from group: $($Group.Name)"
}

# Disable the account
Disable-ADAccount -Identity $User

Write-Host "Account disabled."

# Move account to Disabled Users OU
Move-ADObject `
    -Identity $User.DistinguishedName `
    -TargetPath $DisabledUsersOU

Write-Host "Moved account to Disabled Users OU."

# Record the offboarding operation
[PSCustomObject]@{
    Date          = Get-Date
    Name          = $User.Name
    Username      = $User.SamAccountName
    Department    = $User.Department
    PreviousGroups = ($Groups.Name -join "; ")
    Action        = "Account disabled and moved to Disabled Users OU"
} |
Export-Csv $LogFile -Append -NoTypeInformation

Write-Host ""
Write-Host "Offboarding completed for $Username."
Write-Host "Log saved to: $LogFile"