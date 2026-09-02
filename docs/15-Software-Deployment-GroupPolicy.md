# Configure Software Deployment with Group Policy

## Objective

Use Group Policy Software Installation to automatically deploy a 64-bit MSI application to the domain-joined `CLIENT01` workstation.

The deployment used the existing software share on `DC01` and installed **7-Zip 26.02 (x64 edition)** without manually running the installer on the client.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| Client | `CLIENT01` |
| Group Policy Object | `Software Deployment` |
| Software Share | `\\DC01\Software` |
| MSI Package | `7z2602-x64.msi` |
| Application | 7-Zip 26.02 (x64 edition) |
| Deployment Method | Assigned |
| GPO Scope | Computer Configuration |

---

## Software Deployment Design

The deployment used the existing centralized software share created earlier in the lab.

```text
DC01
│
├── C:\CompanyShares\Software
│   └── 7z2602-x64.msi
│
└── \\DC01\Software
        │
        ▼
Software Deployment GPO
        │
        ▼
CLIENT01
        │
        ▼
7-Zip Installed
```

The MSI package was stored on `DC01` and referenced through its UNC path:

```text
\\DC01\Software\7z2602-x64.msi
```

Using the UNC path ensured that the package was accessible to the client during Group Policy processing.

---

## Design Decisions

### MSI-Based Deployment

The software package was deployed using an `.msi` installer because Group Policy Software Installation supports Windows Installer packages directly.

The 64-bit 7-Zip MSI used for the deployment was:

```text
7z2602-x64.msi
```

### Computer-Based Assignment

The package was assigned under **Computer Configuration** rather than User Configuration.

This caused the application to be installed on `CLIENT01` as a managed computer deployment rather than being tied to a specific user account.

### Centralized Software Source

The installer was stored in the existing software share:

```text
\\DC01\Software
```

This reused the file-server configuration from the earlier lab and provided a centralized location for software deployment packages.

---

## Software Package

The 7-Zip MSI was placed in:

```text
C:\CompanyShares\Software
```

and was accessible from `CLIENT01` through:

```text
\\DC01\Software\7z2602-x64.msi
```

Before creating the deployment policy, the MSI was verified as readable from `CLIENT01`.


---

## Group Policy Configuration

A dedicated Group Policy Object named:

```text
Software Deployment
```

was created and linked to the Organizational Unit containing the `CLIENT01` computer object.

The software package was configured under:

```text
Computer Configuration
└── Policies
    └── Software Settings
        └── Software installation
```

The 7-Zip MSI was added using the network path:

```text
\\DC01\Software\7z2602-x64.msi
```

The deployment method was configured as:

```text
Assigned
```

The resulting Group Policy configuration showed:

```text
7-Zip 26.02 (x64 edition)
Deployment state: Assigned
Source: \\DC01\Software\7z2602-x64.msi
```

<img width="984" height="704" alt="01-Software-Grouppolicy" src="https://github.com/user-attachments/assets/622b8d32-5103-4d29-9489-f50c219bc0df" />


---

## Deployment to CLIENT01

After the `Software Deployment` GPO was configured, Group Policy was refreshed on `CLIENT01`.

<img width="1240" height="686" alt="03-client01gpupdate" src="https://github.com/user-attachments/assets/91d85be1-83a3-4f29-9994-711c6ba53b03" />


The client was restarted so the computer-assigned software package could be processed during startup.

After the restart, **7-Zip was installed successfully on CLIENT01** without manually launching the MSI installer.

This confirmed that the application was deployed through Group Policy.


---

## Validation

The software deployment was validated from `CLIENT01`.

### Group Policy Application

The `Software Deployment` GPO was applied to the computer configuration on `CLIENT01`.

The applied computer policies can be verified with:

```powershell
gpresult /r /scope computer
```

<img width="1105" height="716" alt="02-softwaregpresult" src="https://github.com/user-attachments/assets/46bebf88-7a3e-4910-adf5-eb606452b3da" />


No manual installation of the MSI was performed on the client.

The deployment therefore confirmed the full process:

```text
MSI stored on DC01
        ↓
Software Deployment GPO
        ↓
CLIENT01 computer policy processing
        ↓
Automatic 7-Zip installation
```


---

## Validation Checklist

- [x] Added the 64-bit 7-Zip MSI to the Software share
- [x] Verified the MSI was accessible from `CLIENT01`
- [x] Created the `Software Deployment` GPO
- [x] Configured the deployment under Computer Configuration
- [x] Added the MSI using its UNC path
- [x] Configured the package as Assigned
- [x] Refreshed Group Policy on `CLIENT01`
- [x] Restarted `CLIENT01`
- [x] Confirmed 7-Zip installed automatically
- [x] Verified the deployment was completed without manually running the installer

---

## Lessons Learned

Group Policy Software Installation provides a centralized method for deploying MSI applications to domain-joined computers.

Using a UNC path for the deployment package is important because the client must be able to access the installer independently from the Domain Controller's local file system.

Assigning the software through Computer Configuration allows the application to be managed at the workstation level rather than being dependent on a specific user account.

This lab also demonstrated how previously configured file shares can be reused as software distribution points, allowing Active Directory, SMB file sharing, permissions, and Group Policy to work together as part of a larger Windows Server environment.
