# Automate Active Directory User Offboarding with PowerShell

## Objective

Create a PowerShell-based Active Directory offboarding process that disables user accounts, removes additional security group memberships, moves accounts to a dedicated `Disabled Users` Organizational Unit, and records completed actions in an offboarding log.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| Active User OU | `OU=Users List,DC=ad,DC=nlaur,DC=com` |
| Disabled User OU | `OU=Disabled Users,DC=ad,DC=nlaur,DC=com` |
| Script | `C:\Scripts\Disable-LabUser.ps1` |
| Offboarding Log | `C:\Scripts\Reports\Offboarding-Log.csv` |

---

## Offboarding Design

The workflow was designed to disable access without deleting the Active Directory user object.

```text
Active User
    |
    v
Disable-LabUser.ps1
    |
    +-- Record group memberships
    +-- Remove additional security groups
    +-- Disable account
    +-- Move to Disabled Users OU
    +-- Record action in CSV log
```

This preserves the account while removing access and separating disabled users from active users.

---

## Design Decisions

### Dedicated Disabled Users OU

A new Organizational Unit named `Disabled Users` was created at the domain level:

```text
OU=Disabled Users,DC=ad,DC=nlaur,DC=com
```

This provides a clear location for accounts that have completed the offboarding process.

### Disable Instead of Delete

Accounts are disabled rather than deleted. This preserves the Active Directory object and its information while preventing the account from authenticating.

### Security Group Cleanup

The script records existing group memberships and removes additional security groups. `Domain Users` is excluded from removal.

### Offboarding Logging

Each operation is recorded in:

```text
C:\Scripts\Reports\Offboarding-Log.csv
```

The log contains the date, name, username, department, previous groups, and completed action.

---

## Create Disabled Users Organizational Unit

The existing OU structure was reviewed and a dedicated `Disabled Users` OU was created for offboarded accounts.

The OU was configured with protection from accidental deletion.

<img width="1003" height="271" alt="01-DisabledUsersOU" src="https://github.com/user-attachments/assets/85f231a6-a60c-4883-85c3-a4f3f1b61354" />


---

## Pre-Offboarding Account State

`dwilson` was initially used to test the basic workflow.

Before offboarding:

```text
Name              : David Wilson
SamAccountName    : dwilson
Department        : General
Enabled           : True
DistinguishedName : CN=David Wilson,OU=Users List,DC=ad,DC=nlaur,DC=com
Groups            :
```

This confirmed that the account was enabled and located in the active `Users List` OU.

<!-- Add screenshot: 02-PreOffboardingState -->

---

## PowerShell Offboarding Script

A reusable script named `Disable-LabUser.ps1` was created in `C:\Scripts`.

```powershell
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

$Groups = Get-ADPrincipalGroupMembership $User |
    Where-Object {$_.Name -ne "Domain Users"}

foreach ($Group in $Groups) {
    Remove-ADGroupMember -Identity $Group -Members $User -Confirm:$false
    Write-Host "Removed from group: $($Group.Name)"
}

Disable-ADAccount -Identity $User
Write-Host "Account disabled."

Move-ADObject -Identity $User.DistinguishedName -TargetPath $DisabledUsersOU
Write-Host "Moved account to Disabled Users OU."

[PSCustomObject]@{
    Date           = Get-Date
    Name           = $User.Name
    Username       = $User.SamAccountName
    Department     = $User.Department
    PreviousGroups = ($Groups.Name -join "; ")
    Action         = "Account disabled and moved to Disabled Users OU"
} |
Export-Csv $LogFile -Append -NoTypeInformation

Write-Host ""
Write-Host "Offboarding completed for $Username."
Write-Host "Log saved to: $LogFile"
```

---

## Initial Offboarding Test

The first test was performed against `dwilson`.

The script successfully disabled the account, moved it from `Users List` to `Disabled Users`, and recorded the operation in the offboarding log.

Before and After execution:

<img width="1006" height="543" alt="02-beforeafteroffboaring" src="https://github.com/user-attachments/assets/d5fefcc2-035f-4131-b050-8a8ce488fff7" />


---

## Security Group Removal Test

A second test was performed against `ajohnson` to validate group cleanup.

<img width="1007" height="572" alt="03-beforeafterajohnsonoffboarding" src="https://github.com/user-attachments/assets/de299c20-b82a-41d2-9572-dcea8df63d71" />


This confirmed that the security group membership was removed in addition to disabling and relocating the account.


---

## Offboarding Log

The generated CSV audit trail was reviewed with:

```powershell
Import-Csv "C:\Scripts\Reports\Offboarding-Log.csv" |
Format-Table -AutoSize
```

<img width="941" height="117" alt="04-offboardinglog" src="https://github.com/user-attachments/assets/20f16b98-ccec-4037-b56e-b6917360c653" />


The log contained entries for both `dwilson` and `ajohnson`.

For `ajohnson`, the previous `IT_Technicians` membership remained recorded in the log even though it had been removed from Active Directory.


---

## Validation

The completed workflow was tested against two Active Directory accounts.

The `dwilson` test confirmed that the script could disable an account, move it to `Disabled Users`, and log the operation.

The `ajohnson` test validated the complete workflow. The account began enabled in `Users List` with membership in `IT_Technicians`. After the script ran:

- `IT_Technicians` membership was removed.
- The account was disabled.
- The account was moved to `Disabled Users`.
- The previous group membership was preserved in the log.
- The completed action was recorded with a timestamp.

The tests confirmed that the offboarding workflow functioned without deleting the Active Directory user object.

---

## Lessons Learned


Separating disabled accounts into a dedicated OU clearly distinguishes inactive accounts from active users.

Removing role-based security group memberships reduces retained access, while disabling the account prevents further authentication.

Recording previous group memberships before removing them creates an audit trail of the access held before offboarding.

Using a username parameter made the script reusable across different accounts.

This project completed a basic Active Directory user lifecycle workflow in the lab:

```text
User Provisioning
       |
       v
  User Auditing
       |
       v
User Offboarding
```
