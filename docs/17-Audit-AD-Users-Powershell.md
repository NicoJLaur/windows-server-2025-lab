# Audit Active Directory Users with PowerShell

## Objective

Create a PowerShell-based Active Directory user audit that collects account status, department information, logon activity, password information, and security group memberships from users in the `Users List` Organizational Unit.

The audit results were exported to a CSV file for easier review and reporting.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| User OU | `OU=Users List,DC=ad,DC=nlaur,DC=com` |
| Script Directory | `C:\Scripts` |
| Audit Script | `C:\Scripts\Get-ADUserAudit.ps1` |
| Report Directory | `C:\Scripts\Reports` |
| Audit Report | `C:\Scripts\Reports\AD-User-Audit.csv` |

---

## Audit Design

The audit collected information directly from Active Directory and exported the results to a CSV report.

```text
Active Directory
      │
      ▼
Get-ADUserAudit.ps1
      │
      ├── Collect account information
      ├── Collect department
      ├── Collect account status
      ├── Collect logon activity
      ├── Collect password information
      ├── Collect group memberships
      └── Export CSV
              │
              ▼
      AD-User-Audit.csv
```

This provided a reusable method for reviewing multiple user accounts without manually opening each account in Active Directory Users and Computers.

---

## Design Decisions

### Users List OU Scope

The audit was scoped to:

```text
OU=Users List,DC=ad,DC=nlaur,DC=com
```

This limited the report to the user accounts created and managed within the lab's primary user OU.

### Account Attributes

The audit included the following information:

```text
Name
Username
Department
Enabled
LastLogonDate
PasswordLastSet
PasswordNeverExpires
Groups
```

These fields provide a basic account review covering identity, status, activity, password configuration, and authorization.

### Security Group Reporting

Group memberships were collected with:

```powershell
Get-ADPrincipalGroupMembership
```

`Domain Users` was intentionally excluded from the `Groups` column so the report focused on additional role-based and departmental group memberships.

### CSV Export

The audit results were exported to:

```text
C:\Scripts\Reports\AD-User-Audit.csv
```

CSV output made the report easy to review, sort, and reuse outside PowerShell.

---

## Initial Active Directory Review

Before creating the audit script, Active Directory user information was reviewed with PowerShell.

The query returned attributes including:

```text
SamAccountName
Department
Enabled
LastLogonDate
PasswordLastSet
PasswordNeverExpires
```

The results showed that previously used accounts such as `user_njl` and `hruser` contained logon and password-set dates, while newly provisioned accounts such as `ajohnson`, `smiller`, and `dwilson` had not yet logged on.

<img width="1005" height="675" alt="01-initialaudit" src="https://github.com/user-attachments/assets/22eea33f-ff56-4422-84ec-78c1a9d74af1" />


---

## PowerShell Audit Script

A PowerShell script named:

```text
Get-ADUserAudit.ps1
```

was created in:

```text
C:\Scripts
```

The script queried Active Directory, collected user attributes and group memberships, and exported the completed report to CSV.

```powershell
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
```

The script created one report row for each user in the `Users List` OU.

---

## Audit Report

The completed script generated:

```text
C:\Scripts\Reports\AD-User-Audit.csv
```

The report included:

| Field | Purpose |
|-------|---------|
| Name | User display name |
| Username | Active Directory `SamAccountName` |
| Department | Department attribute |
| Enabled | Account enabled status |
| LastLogonDate | Most recent recorded logon |
| PasswordLastSet | Last password-set date |
| PasswordNeverExpires | Password expiration configuration |
| Groups | Additional security group memberships |

The generated report showed examples including:

```text
Alex Johnson  → IT → IT_Technicians
Sarah Miller  → HR → HR_Users
HR USER       → HR_Users
David Wilson  → General → No additional group
Nico Laurie   → No additional group listed
```

<img width="1535" height="342" alt="02-AuditReport" src="https://github.com/user-attachments/assets/caa8ed96-3c75-44cd-8206-642cf6e215fa" />


---

## Validation

The completed CSV report was reviewed to confirm that the exported values matched the Active Directory data.

The audit confirmed:

- `ajohnson` was enabled and assigned to the IT department.
- `ajohnson` was a member of `IT_Technicians`.
- `smiller` was enabled and assigned to the HR department.
- `smiller` was a member of `HR_Users`.
- `hruser` was also shown as a member of `HR_Users`.
- `dwilson` was enabled and assigned to the General department.
- Newly created accounts without logon activity had blank `LastLogonDate` values.
- `Domain Users` was excluded from the additional Groups field.

The CSV could also be displayed in PowerShell using:

```powershell
Import-Csv "C:\Scripts\Reports\AD-User-Audit.csv" |
Format-Table Name,Username,Department,Enabled,LastLogonDate,PasswordLastSet,PasswordNeverExpires,Groups -AutoSize
```

<img width="1501" height="275" alt="03-CSVvalidation" src="https://github.com/user-attachments/assets/8ff86b0c-28fe-44ef-8a01-e4e854528f5b" />


---

## Validation Checklist

- [x] Reviewed Active Directory user attributes
- [x] Created `C:\Scripts\Reports`
- [x] Created `Get-ADUserAudit.ps1`
- [x] Scoped the audit to the `Users List` OU
- [x] Collected department information
- [x] Collected enabled status
- [x] Collected last logon information
- [x] Collected password last-set information
- [x] Collected password expiration settings
- [x] Collected additional security group memberships
- [x] Excluded `Domain Users` from the additional groups column
- [x] Exported the results to `AD-User-Audit.csv`
- [x] Reviewed the generated CSV
- [x] Confirmed the exported values matched Active Directory

---

## Lessons Learned

PowerShell can be used not only to automate Active Directory changes but also to create repeatable auditing and reporting workflows.

Using `Get-ADUser` with additional properties makes it possible to collect account status, activity, and password information across multiple users at once.

Combining `Get-ADPrincipalGroupMembership` with the user query added authorization information to the same report, making the CSV more useful for account reviews.

Exporting the results to CSV provides a simple way to review, sort, archive, or further process Active Directory audit data.

This project demonstrated how PowerShell can turn Active Directory account information into a reusable administrative report rather than requiring manual review of individual user objects.
