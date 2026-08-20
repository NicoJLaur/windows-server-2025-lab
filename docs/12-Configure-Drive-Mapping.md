# Configure Drive Mapping with Group Policy

## Objective

Use Group Policy Preferences to automatically map shared network drives for domain users based on their role and Active Directory security group membership.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| Client | `CLIENT01` |
| Group Policy Object | `Drive Mapping` |
| Public Share | `\\DC01\Public` |
| Software Share | `\\DC01\Software` |
| IT Share | `\\DC01\IT` |
| HR Share | `\\DC01\HR` |

---

## Drive Mapping Design

The following drive mappings were configured:

| Drive | Share | Assigned To |
|------|------|-------------|
| `P:` | `\\DC01\Public` | Standard domain users |
| `S:` | `\\DC01\Software` | Standard domain users |
| `I:` | `\\DC01\IT` | `IT_Admins` or `IT_Technicians` |
| `H:` | `\\DC01\HR` | `HR_Users` |

This allows general-purpose resources to be available to all applicable users while restricted departmental drives are only displayed to authorized users.

---

## Design Decisions

### Group Policy Preferences

Drive mappings were deployed using **Group Policy Preferences** rather than configuring mapped drives manually on each workstation.

This allows drive assignments to be centrally managed from Active Directory and applied automatically when users sign in.

### Item-Level Targeting

Restricted drive mappings use **Item-Level Targeting** so that users only receive drives associated with their security group membership.

For example, the IT drive uses:

```text
IT_Admins
    OR
IT_Technicians
        ↓
Map I: Drive
```

The HR drive uses:

```text
HR_Users
    ↓
Map H: Drive
```

### Separation of Deployment and Authorization

Group Policy determines whether a drive mapping is presented to a user, while NTFS permissions remain responsible for controlling access to the underlying data.

This creates two layers of control:

```text
Active Directory Group Membership
              │
              ▼
     Group Policy Targeting
              │
              ▼
        Drive Mapping
              │
              ▼
        NTFS Permissions
              │
              ▼
       Resource Access
```

This prevents unauthorized users from receiving unnecessary drive mappings while still ensuring that NTFS permissions remain the actual security boundary.

---

## Group Policy Configuration

A dedicated Group Policy Object named:

```text
Drive Mapping
```

was created and linked to the Organizational Units containing the intended users.

The mappings were configured under:

```text
User Configuration
└── Preferences
    └── Windows Settings
        └── Drive Maps
```

## Create HR Security Group and Test User

To test department-based drive mapping, an HR security group and test user were created in Active Directory.

The following objects were created:

| Object | Name | Purpose |
|--------|------|---------|
| Security Group | `HR_Users` | Controls access to HR resources |
| User Account | `hruser` | Test account representing an HR employee |

The `hruser` account was added as a member of the `HR_Users` security group.

<img width="938" height="732" alt="06-hruser" src="https://github.com/user-attachments/assets/48fc854d-b0c2-4ab9-8fac-4e18c164316d" />


## Configure Public Drive

The Public share was mapped using the following settings:

```text
Action:       Update
Location:     \\DC01\Public
Label:        Public
Drive Letter: P:
```

No Item-Level Targeting was required because the Public share is available to standard domain users.

---

## Configure Software Drive

The Software share was configured as:

```text
Action:       Update
Location:     \\DC01\Software
Label:        Software
Drive Letter: S:
```

Like the Public drive, no Item-Level Targeting was required.

---

## Configure IT Drive

The IT share was configured as:

```text
Action:       Update
Location:     \\DC01\IT
Label:        IT
Drive Letter: I:
```

Item-Level Targeting was enabled.

The targeting rule was configured as:

```text
User is a member of AD\IT_Technicians

OR

User is a member of AD\IT_Admins
```

<img width="745" height="521" alt="01-ItemTargeting" src="https://github.com/user-attachments/assets/7ed097a9-8c1c-403e-bbd0-b8c1ee9f6105" />


This ensures the `I:` drive is only mapped for authorized IT users.

---

## Configure HR Drive

The HR share was configured as:

```text
Action:       Update
Location:     \\DC01\HR
Label:        HR
Drive Letter: H:
```

Item-Level Targeting was configured using the following security group:

```text
AD\HR_Users
```

<img width="972" height="698" alt="02-HRITEMTARGETING" src="https://github.com/user-attachments/assets/36b96bae-ec68-4529-954f-6752442d7e68" />


Only members of `HR_Users` receive the `H:` drive mapping.

---

## Validation

The drive mappings were tested from `CLIENT01` using multiple domain accounts.

### Standard User

<img width="1270" height="722" alt="03-standarduservalidation" src="https://github.com/user-attachments/assets/b75f5f18-bf4d-4190-b74c-128174237e35" />


This confirmed that standard users receive only general-purpose shared resources.

---

### IT Administrative User


<img width="1267" height="784" alt="04-adminmapping" src="https://github.com/user-attachments/assets/78e221a5-aaf8-4b5a-a3d6-932d9b48fbd2" />


This confirmed that Item-Level Targeting successfully identified the account as an authorized IT user.

---

### HR User


<img width="1271" height="800" alt="05-HRmapping" src="https://github.com/user-attachments/assets/39f1afc3-e05f-420c-b8d9-602ff8c77c49" />


The IT drive was not mapped because the HR account was not a member of an authorized IT security group.


Mapped network drives were also be verified using:

```powershell
net use
```

and:

```powershell
Get-SmbMapping
```

---

## Validation Matrix

| Account | `P:` Public | `S:` Software | `I:` IT | `H:` HR |
|---------|:-----------:|:-------------:|:-------:|:-------:|
| `user_njl` | ✅ | ✅ | ❌ | ❌ |
| `admin_njl` | ✅ | ✅ | ✅ | ❌ |
| `hruser` | ✅ | ✅ | ❌ | ✅ |

The results confirmed that the drive mappings were being deployed according to Active Directory group membership.

---

## Validation Checklist

- [x] Created a dedicated Drive Mapping GPO
- [x] Mapped the Public share as `P:`
- [x] Mapped the Software share as `S:`
- [x] Mapped the IT share as `I:`
- [x] Mapped the HR share as `H:`
- [x] Configured Item-Level Targeting for IT users
- [x] Configured Item-Level Targeting for HR users
- [x] Verified standard user mappings
- [x] Verified IT user mappings
- [x] Verified HR user mappings
- [x] Confirmed restricted drives were not shown to unauthorized users
- [x] Verified mappings from `CLIENT01`

---

## Lessons Learned

Group Policy Preferences provide a centralized method for deploying mapped drives to domain users without requiring manual configuration on each workstation.

Item-Level Targeting allows administrators to customize resource deployment based on Active Directory security group membership.

Group Policy controls whether the drive mapping appears, while NTFS permissions determine whether the user is actually authorized to access the underlying files.

Testing the configuration with multiple domain accounts confirmed that role-based resource deployment was functioning as intended.
