# Group Policy Management

## Objective

Implement centralized management using Active Directory Group Policy by deploying a desktop configuration to all domain users and validating policy application on a domain-joined workstation.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | ad.nlaur.com |
| Domain Controller | DC01 |
| Client | CLIENT01 |
| Group Policy Object | Desktop Configuration |
| Shared Folder | `\\DC01\DomainResources` |
| Wallpaper Location | `\\DC01\DomainResources\Wallpaper` |

---

## Design Decisions

### Centralized Management

Rather than configuring each workstation individually, Group Policy allows administrators to deploy standardized settings from Active Directory. This approach provides consistency across domain-joined computers while reducing administrative overhead.

### Shared Resources

A shared folder (`DomainResources`) was created on the domain controller to centrally host files deployed through Group Policy. Storing resources in a shared location allows clients to retrieve updated files without requiring local copies.

---

## Configuration

### Domain Resource Share

Created the following directory on **DC01**:

```text
C:\DomainResources
```

Shared as:

```text
\\DC01\DomainResources
```

#### Share Permissions

| Principal | Permission |
|-----------|------------|
| Authenticated Users | Read |
| Administrators | Full Control |

---

### Wallpaper Repository

Created the following directory:

```text
C:\DomainResources\Wallpaper
```

Copied the corporate wallpaper image into the folder for deployment through Group Policy.

---

### Create Group Policy Object

Created a new Group Policy Object:

```text
Desktop Configuration
```

Linked the policy to:

```text
ad.nlaur.com
```

---

### Configure Desktop Wallpaper Policy

Configured the following policy:

```text
User Configuration
└── Policies
    └── Administrative Templates
        └── Desktop
            └── Desktop
                └── Desktop Wallpaper
```

| Setting | Value |
|---------|-------|
| Policy | Enabled |
| Wallpaper | `\\DC01\DomainResources\Wallpaper\Corporate-Wallpaper.jpg` |
| Wallpaper Style | Fit |

---

## Validation

The following tasks were successfully completed:

- [x] Created the `DomainResources` network share.


<img width="1283" height="900" alt="4mto0t0h" src="https://github.com/user-attachments/assets/d53f4162-2e33-4dff-ba03-e74b0f9eeda1" />





- [x] Verified CLIENT01 could access the shared folder.


<img width="1279" height="840" alt="02-client01sharedfolder" src="https://github.com/user-attachments/assets/379a9c1e-b719-4990-b066-9222f8f31c1a" />



- [x] Created and linked the **Desktop Configuration** Group Policy Object.


<img width="1281" height="896" alt="03-DESKTOPCONFIGURATIONGPO" src="https://github.com/user-attachments/assets/44eb79c7-88c5-499d-8cc8-955f57d83054" />





- [x] Forced a Group Policy update using `gpupdate /force`.
- [x] Verified policy application using `gpresult /r`.


<img width="1276" height="903" alt="04-gpresult" src="https://github.com/user-attachments/assets/8a5b62de-0c8b-414a-81cd-cd40de5ba27a" />
<img width="1256" height="49" alt="05-gpforce" src="https://github.com/user-attachments/assets/b27115c1-001d-4af0-8377-664a8ab061ba" />



- [x] Confirmed the desktop wallpaper policy was applied successfully.


<img width="1279" height="960" alt="06-VAILDDESKTOP" src="https://github.com/user-attachments/assets/a714be0e-7c43-4f9f-892f-432668de2150" />




### Validation Commands

```powershell
gpupdate /force
```

```powershell
gpresult /r
```

Expected output:

```text
Applied Group Policy Objects

Desktop Configuration
```

---

## Lessons Learned

- Group Policy provides centralized configuration management for domain users and computers.
- Centralizing shared resources simplifies policy deployment and reduces administrative overhead.
- Both share permissions and NTFS permissions must allow clients to access resources referenced by Group Policy.
- `gpupdate /force` is useful during testing to immediately refresh policies.
- `gpresult /r` is an effective method for verifying that a Group Policy Object has been successfully applied to a client.
