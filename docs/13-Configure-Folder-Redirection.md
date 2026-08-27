# Configure Folder Redirection with Group Policy

## Objective

Use Group Policy Folder Redirection to centrally store a domain user's **Documents** folder on `DC01` instead of keeping the files only inside the local profile on `CLIENT01`.


---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| Client | `CLIENT01` |
| Group Policy Object | `Folder Redirection` |
| Redirected Folder | Documents |
| User Data Root | `C:\UserData` |
| Network Share | `\\DC01\UserData` |
| Test User | `user_njl` |


---

## Folder Redirection Design

The Documents folder is redirected from the local user profile:

```text
C:\Users\user_njl\Documents
```

to the centralized network location:

```text
\\DC01\UserData\user_njl\Documents
```

The resulting folder structure on `DC01` is:

```text
C:\UserData
└── user_njl
    └── Documents
```

This allows the user to continue opening **Documents** normally on `CLIENT01` while the actual files are stored on `DC01`.

---

## Design Decisions

### Centralized User Data

Folder Redirection was used to move the user's Documents folder from the local workstation to a network location.

This provides a centralized location for user data and demonstrates how domain administrators can manage user folders without manually configuring each workstation.

### Group Policy Deployment

Folder Redirection was configured through a dedicated Group Policy Object rather than configuring the Documents location manually on `CLIENT01`.

This allows the configuration to be centrally managed and automatically applied to domain users.

### Group-Based Administrative Access

Administrative access to redirected folders was maintained through the Windows **Administrators** group rather than granting access directly to `admin_njl`.

This keeps administrative permissions group-based and avoids assigning access individually to each administrator.

### NTFS Permissions

NTFS permissions were used to control access to the redirected folder structure.

The final permissions allow:

```text
AD\user_njl
    Full Control of the user's redirected Documents

BUILTIN\Administrators
    Administrative access to redirected Documents

SYSTEM
    Full Control
```

---

## UserData Share Configuration

A new folder was created on `DC01`:

```text
C:\UserData
```

The folder was shared as:

```text
\\DC01\UserData
```

### Share Permissions

The `UserData` share was configured with:

```text
Everyone
└── Full Control
```

NTFS permissions were then used to control access to the underlying folders.

<img width="454" height="559" alt="01-UserDataSharePermissions" src="https://github.com/user-attachments/assets/dd199372-55e0-448b-b0ac-4d9e11181273" />


---

## Configure UserData NTFS Permissions

Inheritance was disabled on the `C:\UserData` root so that the redirected folder structure could use a controlled permission model.

The root permissions were configured to retain administrative and system access while allowing domain users to create their individual redirected folders.

Important permission entries included:

| Principal | Access | Applies To |
|-----------|--------|------------|
| `SYSTEM` | Full Control | This folder, subfolders and files |
| `BUILTIN\Administrators` | Full Control | This folder, subfolders and files |
| Domain Users | Special | This folder only |
| `CREATOR OWNER` | Full Control | Subfolders and files only |

<img width="959" height="651" alt="02-UserDataNTFSPermission" src="https://github.com/user-attachments/assets/e58dd6e4-9b1b-4431-b43f-92a4c3f8cac7" />


---

## Group Policy Configuration

A dedicated Group Policy Object named:

```text
Folder Redirection
```

was created and linked to the Organizational Unit containing the intended user.

The policy was configured under:

```text
User Configuration
└── Policies
    └── Windows Settings
        └── Folder Redirection
            └── Documents
```

---

## Configure Documents Redirection

The Documents folder was configured using:

```text
Setting:
Basic - Redirect everyone's folder to the same location

Target folder location:
Create a folder for each user under the root path

Root Path:
\\DC01\UserData
```

Windows automatically creates a user-specific redirected folder based on the username.

For `user_njl`, the resulting path is:

```text
\\DC01\UserData\user_njl\Documents
```

<img width="986" height="707" alt="03-FolderRedirectionTarget" src="https://github.com/user-attachments/assets/4bfb14c2-fad6-473d-a8cb-f258c9c22ea2" />


---

## Configure Folder Redirection Settings

The Documents redirection policy was configured to move the contents of the user's Documents folder to the new redirected location.

The policy removal behavior was configured to leave the redirected folder in the network location if the policy is removed.

During testing, permissions on the redirected folder required additional adjustment so that both the user and administrators could access the redirected data.

<img width="981" height="700" alt="04-FolderRedirectionSettings" src="https://github.com/user-attachments/assets/6c8345ba-7a0c-475b-a636-d25482950a99" />


---

## Troubleshooting Redirected Folder Permissions

The Folder Redirection GPO successfully created:

```text
C:\UserData\user_njl\Documents
```

However, the initial ACL configuration caused permission problems when attempting to access and administer the redirected Documents folder.

Windows returned:

<img width="975" height="551" alt="06-AccessDeniedDocuments" src="https://github.com/user-attachments/assets/46a72ed7-e17d-44a1-809b-51e2a4e0e77a" />


Administrative ownership of the existing Documents folder was assigned to the Administrators group using:

<img width="1270" height="739" alt="05-FolderPermissionsRepair" src="https://github.com/user-attachments/assets/255a7a74-ff3f-4c89-a912-86a52e038440" />

After correcting the permissions:

- `user_njl` could access the redirected Documents folder.
- Members of the Administrators group could manage the redirected folder.
- Administrative access did not require granting `admin_njl` permission individually.

---

## Validation

Folder Redirection was validated from `CLIENT01` while logged in as:

```text
AD\user_njl
```

### Documents Location


<img width="970" height="689" alt="06-FolderRedirectionLocation" src="https://github.com/user-attachments/assets/55d4907b-2efb-4949-acf4-e681f8de0377" />


This confirmed that Windows Documents was no longer using the local profile location:

```text
C:\Users\user_njl\Documents
```

and was instead using the redirected location on `DC01`.

### File Access

Test text files created in the Documents folder were accessible through `CLIENT01` 

<img width="1027" height="389" alt="07-CLIENT01VALIDATION" src="https://github.com/user-attachments/assets/33cdf50a-9d12-4aec-89ab-74700f4c77e3" />



and were also present on `DC01`:

<img width="985" height="462" alt="08-DC01VALIDATION" src="https://github.com/user-attachments/assets/954aa206-d9d3-471e-a1e3-c553045175ea" />




This confirmed that files opened and created through the Documents folder on `CLIENT01` were being stored in the redirected server location.



---

## Lessons Learned

Folder Redirection provides a centralized method for storing user data while allowing users to continue interacting with familiar Windows folders such as Documents.

Group Policy allows the redirected location to be managed centrally instead of configuring each workstation manually.

The lab also demonstrated the importance of correctly configuring NTFS permissions for redirected user folders. A folder can be successfully created by Group Policy while still being unusable if the ACL does not grant the appropriate user access.

Using group-based administrative permissions allows administrators to manage redirected data without granting permissions directly to individual administrator accounts.

Testing the final Documents location from `CLIENT01` confirmed that the Folder Redirection policy was functioning as intended.
