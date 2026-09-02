# Automate Active Directory User Provisioning with PowerShell

## Objective

Automate the creation of Active Directory user accounts from a CSV file using PowerShell.

The provisioning script created multiple users in the `Users List` Organizational Unit, configured their account attributes, assigned department-based security groups, and prevented duplicate accounts from being created when the script was run again.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| User OU | `OU=Users List,DC=ad,DC=nlaur,DC=com` |
| Script Directory | `C:\Scripts` |
| User Data File | `C:\Scripts\new-users.csv` |
| Provisioning Script | `C:\Scripts\New-LabUsers.ps1` |
| IT Security Group | `IT_Technicians` |
| HR Security Group | `HR_Users` |

---

## Provisioning Design

The provisioning process used a CSV file as the source for new user information.

```text
new-users.csv
      │
      ▼
New-LabUsers.ps1
      │
      ├── Check for existing account
      ├── Create AD user
      ├── Set department
      ├── Place user in Users List OU
      └── Assign security group
              │
              ▼
       Active Directory
```

This allowed multiple accounts to be created from a consistent data source rather than manually creating each account in Active Directory Users and Computers.

---

## Design Decisions

### CSV-Based User Data

User information was separated from the PowerShell script and stored in:

```text
C:\Scripts\new-users.csv
```

The CSV contained:

```text
FirstName
LastName
Username
Department
Group
```

This allowed the same script to process multiple accounts without changing the script for each user.

### Users List Organizational Unit

Automatically created accounts were placed in the existing `Users List` Organizational Unit:

```text
OU=Users List,DC=ad,DC=nlaur,DC=com
```

### Department-Based Group Membership

The CSV included an optional `Group` field. Users with a group specified were automatically added to the corresponding Active Directory security group.

The deployment used:

```text
IT_Technicians
HR_Users
```

Both were confirmed as Global Security groups before provisioning.

### Duplicate Account Protection

Before creating an account, the script checked Active Directory for an existing `SamAccountName`.

Existing accounts were skipped instead of being recreated.

---

## User Provisioning Data

Three test users were defined in `new-users.csv`:

```csv
FirstName,LastName,Username,Department,Group
Alex,Johnson,ajohnson,IT,IT_Technicians
Sarah,Miller,smiller,HR,HR_Users
David,Wilson,dwilson,General,
```

| User | Username | Department | Security Group |
|------|----------|------------|----------------|
| Alex Johnson | `ajohnson` | IT | `IT_Technicians` |
| Sarah Miller | `smiller` | HR | `HR_Users` |
| David Wilson | `dwilson` | General | None |

The General user was intentionally created without a departmental security group to test an account with no optional group assignment.

---

## PowerShell Provisioning Script

A PowerShell script named:

```text
New-LabUsers.ps1
```

was created in:

```text
C:\Scripts
```

The script imported the Active Directory module, read the CSV records, checked for existing accounts, created new users, and processed optional security group assignments.

The accounts were configured with:

```powershell
Import-Module ActiveDirectory

$Users = Import-Csv "C:\Scripts\new-users.csv"
$UserOU = "OU=Users List,DC=ad,DC=nlaur,DC=com"

$DefaultPassword = Read-Host "Enter temporary password" -AsSecureString

foreach ($User in $Users) {

    $Username = $User.Username
    $FullName = "$($User.FirstName) $($User.LastName)"

    # Check whether the account already exists
    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Warning "$Username already exists. Skipping."
        continue
    }

    try {

        New-ADUser `
            -Name $FullName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@ad.nlaur.com" `
            -Department $User.Department `
            -Path $UserOU `
            -AccountPassword $DefaultPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user: $Username"

        if ($User.Group) {
            Add-ADGroupMember `
                -Identity $User.Group `
                -Members $Username

            Write-Host "Added $Username to $($User.Group)"
        }
    }
    catch {
        Write-Error "Failed to provision $Username : $($_.Exception.Message)"
    }
}
```

---

## User Creation

The provisioning script successfully created:

```text
ajohnson
smiller
dwilson
```

All three accounts were created in:

```text
OU=Users List,DC=ad,DC=nlaur,DC=com
```

PowerShell validation returned:

<img width="1505" height="231" alt="02-userscreated" src="https://github.com/user-attachments/assets/51ce4688-5e09-46fc-8581-4f4b180d3cfe" />


This confirmed that the CSV data was correctly translated into Active Directory user objects.

---

## Security Group Assignment

The provisioning process assigned departmental security groups from the CSV.

`ajohnson` was confirmed as a member of:

```text
IT_Technicians
```

`smiller` was confirmed as a member of:

```text
HR_Users
```

`dwilson` had no departmental group specified and therefore received no additional group assignment from the script.

<img width="1074" height="428" alt="01-Groupconfirmation" src="https://github.com/user-attachments/assets/692e790c-52d2-456a-a706-7f010572a8cf" />


---

## Duplicate User Protection

The provisioning script was executed a second time after the three accounts already existed.

The existing accounts were detected and skipped:

```text
WARNING: ajohnson already exists. Skipping.
WARNING: smiller already exists. Skipping.
WARNING: dwilson already exists. Skipping.
```

<img width="516" height="109" alt="03-scriptrerunresult" src="https://github.com/user-attachments/assets/24b88753-dc84-4288-8fdd-9fb8d0893c14" />


This confirmed that rerunning the provisioning process did not create duplicate Active Directory accounts.

---

## Validation

The completed provisioning process confirmed that:

- All three users existed in the `Users List` OU.
- All three accounts were enabled.
- Each account contained the correct department value.
- `ajohnson` was a member of `IT_Technicians`.
- `smiller` was a member of `HR_Users`.
- `dwilson` was created without a departmental group assignment.
- Existing accounts were detected and skipped during a second execution.

---

## Lessons Learned

PowerShell can automate repetitive Active Directory administration tasks that would otherwise require manually creating and configuring individual accounts.

Separating user information into a CSV file allows the same provisioning script to process multiple users and makes the workflow easier to maintain.

Security group membership can be incorporated into the provisioning process so account creation and role-based access assignments occur within the same workflow.

Adding an existing-user check made the script safer to rerun because previously created accounts were detected and skipped rather than generating duplicate-account errors.

This project demonstrated how PowerShell, CSV data, Active Directory Organizational Units, user attributes, and security groups can be combined into a repeatable user-provisioning workflow.
