# Configure File Shares & Permissions

## Objective

Configure centralized network file shares on `DC01` and secure them using Share Permissions and NTFS Permissions. Validate role-based access from the domain-joined Windows client.

---

## Environment

| Setting | Value |
|---------|-------|
| Server | `DC01` |
| Operating System | Windows Server 2025 Standard Evaluation |
| Domain | `ad.nlaur.com` |
| Client | `CLIENT01` |
| Shared Folder Root | `C:\CompanyShares` |

> **Note:** This homelab intentionally hosts shared resources on `DC01` to reduce virtual machine resource usage and keep the environment manageable. In a production environment, file services would typically be hosted on a dedicated member server rather than on a domain controller.

---

## Shared Resources

The following folders were created under `C:\CompanyShares` and published as individual SMB shares.

| Share | Network Path | Purpose |
|--------|--------------|---------|
| Public | `\\DC01\Public` | Shared resources available to standard domain users |
| Software | `\\DC01\Software` | Central location for software installers and utilities |
| IT | `\\DC01\IT` | Restricted departmental share for IT staff |
| HR | `\\DC01\HR` | Restricted share for sensitive HR-related data |

### SMB Share Verification

The configured SMB shares were verified through:

```text
Computer Management
└── System Tools
    └── Shared Folders
        └── Shares
```

<img width="1226" height="465" alt="01-configuresmbshares" src="https://github.com/user-attachments/assets/a6eb4dc6-86f6-43cc-89c0-d7a3df1fb98e" />


The Shares console confirmed that the `Public`, `Software`, `IT`, and `HR` folders were successfully published from `DC01`.

---

## Folder Structure

```text
C:\CompanyShares
│
├── Public
├── Software
├── IT
└── HR
```

Each folder was shared individually rather than exposing the entire `CompanyShares` directory as a single share.

---

## Permission Design

### Share Permissions

The SMB shares were configured with:

| Principal | Permission |
|-----------|------------|
| Everyone | Full Control |

Share Permissions were intentionally kept permissive while NTFS Permissions were used as the primary access-control mechanism.

This keeps the share configuration simple while allowing more granular security to be managed through the file system.

### NTFS Permissions

| Folder | Authorized Access |
|--------|-------------------|
| Public | Domain users — Read & Execute |
| Software | Domain users — Read & Execute |
| IT | `IT_Admins` and `IT_Technicians` — Modify |
| HR | Administrators — Full Control |

---

## Design Decisions

### NTFS Permissions as the Primary Access Control

NTFS Permissions were used as the primary mechanism for controlling access to shared files and folders.

Although users may be allowed to connect to the SMB share itself, NTFS Permissions determine whether they can actually access the contents of the folder.

### Principle of Least Privilege

Users were granted only the access required for their role.

Standard users can access general-purpose resources such as `Public` and `Software`, while restricted departmental resources remain inaccessible unless the user belongs to an authorized security group.

### Group-Based Access

Permissions for restricted resources were assigned through Active Directory security groups rather than directly to individual user accounts.

For example:

```text
IT_Admins
└── Modify

IT_Technicians
└── Modify
```

This provides a more scalable permission model because users can be granted or removed from access by modifying group membership rather than changing the folder ACL.

---

## Permission Inheritance

The `Public` and `Software` folders use standard inherited permissions.

The `IT` and `HR` folders required more restrictive access, so NTFS inheritance was disabled.

When inheritance was disabled, existing inherited permissions were first converted into explicit permissions.

<img width="956" height="650" alt="02-disableinheritence" src="https://github.com/user-attachments/assets/1e25e160-d8d5-419e-aac3-d89ffd28df06" />


This allowed unnecessary permission entries to be removed without affecting permissions on the parent directory.

---

## Configure IT Share

The `IT` share was restricted to authorized IT personnel.

The final NTFS permissions include:

```text
IT_Admins
└── Modify

IT_Technicians
└── Modify

Administrators
└── Full Control

SYSTEM
└── Full Control
```

General domain-user access was removed.

<img width="955" height="650" alt="03-ITNTFSPermissions" src="https://github.com/user-attachments/assets/129f81eb-2247-4043-a4b1-5ddfcab940a8" />


This ensures that users who are not members of an authorized IT security group cannot access the departmental share.

---

## Configure HR Share

The `HR` share was configured as the most restrictive resource in this exercise.

The final permissions were limited to administrative and system-level principals.

```text
Administrators
└── Full Control

SYSTEM
└── Full Control
```

General user access was removed after disabling inheritance.

<img width="954" height="646" alt="04-HRNFTSPermissions" src="https://github.com/user-attachments/assets/c27542c7-819c-478b-a70b-6f56ad419a80" />


This demonstrates how sensitive departmental resources can be isolated from standard domain users.

---

## Lab Design Considerations

### Shared Resources Hosted on DC01

In a production environment, domain controllers are normally dedicated to identity and authentication services such as Active Directory and DNS.

File services would typically be hosted on a separate member server to improve:

- Security
- Performance
- Scalability
- Role separation
- Maintenance flexibility

For this homelab, the shared resources were intentionally hosted on `DC01` because the Hyper-V host has limited hardware resources and the primary goal of this phase is to practice Windows file-sharing and permission-management concepts.

This implementation provides hands-on experience with:

- SMB file sharing
- Share Permissions
- NTFS Permissions
- Permission inheritance
- Active Directory security groups
- Role-based access control
- Client-side permission validation

As the lab grows, these resources can later be migrated to a dedicated member server such as `FS01` to more closely reflect a production architecture.

---

## Validation

Access was tested from `CLIENT01` while logged in as user_njl, the following commands were used:


<img width="1264" height="664" alt="05-usrnjlvalid" src="https://github.com/user-attachments/assets/5a3c2bed-f26e-4153-aa67-2efee6f43a49" />



The test confirmed that general resources remained available to standard domain users while departmental shares were protected by NTFS permissions.

---

## Validation Checklist

- [x] Created centralized shared-folder structure
- [x] Configured individual SMB shares
- [x] Verified shares through Computer Management
- [x] Configured Share Permissions
- [x] Configured NTFS Permissions
- [x] Used Active Directory security groups for restricted resources
- [x] Disabled inheritance where unique permissions were required
- [x] Verified Public access from `CLIENT01`
- [x] Verified Software access from `CLIENT01`
- [x] Verified IT access was denied for `user_njl`
- [x] Verified HR access was denied for `user_njl`

---

## Lessons Learned

This lab demonstrated the difference between Share Permissions and NTFS Permissions and how both contribute to effective network access.

Using Active Directory security groups instead of assigning permissions directly to individual user accounts provides a more scalable and manageable access-control model.

Permission inheritance can simplify administration for resources that use common permissions, while disabling inheritance allows sensitive folders to maintain independent access-control lists.

The exercise also reinforced the importance of validating permissions from the client perspective. Testing with a standard domain account confirmed that the configured access rules were actually being enforced rather than relying only on the server-side configuration.
