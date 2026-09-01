# Configure Windows Server Backup and File Recovery

## Objective

Configure **Windows Server Backup** on `DC01` using a dedicated backup volume, create a backup containing the server's `C:` volume and **System State**, verify the backup using `wbadmin`, and perform a file-level recovery test.

The backup protects the Windows Server configuration, Active Directory-related system state, shared folders, and redirected user data stored on `C:`.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Server | `DC01` |
| Operating System | Windows Server 2025 Standard Evaluation |
| Backup Feature | Windows Server Backup |
| Backup Source | `Local Disk (C:)` |
| System State | Included |
| Backup Destination | `ServBackup (F:)` |
| Backup Disk Size | ~80 GB |
| Recovery Test File | `TESTING.txt` |


---

## Backup Design

The backup configuration was designed to protect both the server's data and critical Windows Server components.

```text
DC01
│
├── C:  Windows Server / AD DS / File Data
│   ├── C:\CompanyShares
│   ├── C:\UserData
│   └── Windows Server system files
│
└── F:  ServBackup
    └── Windows Server Backup data
```

The backup included:

| Item | Purpose |
|------|---------|
| `Local Disk (C:)` | Protects server files, shared folders, redirected user data, and the Windows installation |
| System State | Protects Active Directory-related system components, SYSVOL, Registry, and other critical server configuration |

---

## Design Decisions

### Dedicated Backup Volume

A separate virtual disk was added to `DC01` and formatted as:

```text
ServBackup (F:)
```

This keeps backup data separate from the operating system volume.

The backup disk was configured as a dynamically expanding virtual disk to reduce unnecessary storage usage in the homelab.

<img width="1013" height="738" alt="02-BackupVolume" src="https://github.com/user-attachments/assets/46a03af7-b8b7-40e5-8272-69db34ecc4cb" />


### System State Backup

Because `DC01` is a Domain Controller, **System State** was included in the backup.

System State allows recovery of important Windows Server components such as:

- Active Directory Domain Services
- SYSVOL
- Registry
- Boot and system configuration
- Other system components required for server recovery

### Manual Backup Before Scheduling

The first backup was created using **Backup Once** rather than immediately configuring a recurring schedule.

This allowed the backup configuration to be tested and validated before automating future backup jobs.

### Recovery Validation

A backup is only useful if data can be recovered from it.

A disposable text file was deleted after the backup and restored using the Windows Server Backup Recovery Wizard to validate that file-level recovery was working.

---

## Install Windows Server Backup

Windows Server Backup was installed on `DC01`.

<img width="975" height="695" alt="06-windowsservebackup" src="https://github.com/user-attachments/assets/db0c2945-e623-4501-a767-f69ceefbb39a" />


---

## Configure the Backup

Opened:

```text
Server Manager
→ Tools
→ Windows Server Backup
→ Local Backup
→ Backup Once
```

Selected:

```text
Different options
```

and choose a **Custom** backup configuration.

The following items were added:

```text
Local Disk (C:)
System State
```

The backup destination was configured as:

```text
ServBackup (F:)
```

The final confirmation screen showed:

```text
Backup destination:
ServBackup (F:)

Backup items:
Local disk (C:)
System state
```

<img width="835" height="699" alt="03-BackupConfirmation" src="https://github.com/user-attachments/assets/e2c22a53-328c-4d86-b327-59f42b440508" />



---

## Run the Backup

The backup was started from the Windows Server Backup wizard.

The job completed successfully and transferred approximately:

```text
27.64 GB
```

The backup results showed:

| Item | Status |
|------|--------|
| Local disk `(C:)` | Completed |
| System State | Completed |

<img width="842" height="697" alt="01-BackupProgress" src="https://github.com/user-attachments/assets/f66db09c-a0da-4249-b24a-5f958f8b4666" />

This confirmed that the backup job completed and was written to the dedicated `F:` volume.

---

## Verify the Backup with wbadmin

The backup was verified using the Windows Server Backup command-line utility.

The available backup versions were displayed with:

```powershell
wbadmin get versions
```

The backup returned:

```text
Backup target: Fixed Disk labeled F:
Version identifier: 09/01/2026-17:35
Can recover: Volume(s), File(s), Application(s), System State
```

The contents of the backup were inspected using:

```powershell
wbadmin get items -version:09/01/2026-17:35
```

The output confirmed that the backup contained recoverable server components including:

```text
Application = FRS
Component = SYSVOL

Application = AD
Component = ntds

Application = Registry
Component = Registry
```

<img width="1257" height="700" alt="04-wbadminconfirmation" src="https://github.com/user-attachments/assets/089816c8-8a9c-4cdf-9a99-8126be77a68e" />


This confirmed that Windows Server Backup recognized the backup as containing recoverable files, volumes, applications, and System State.

---

## File Recovery Test

A file-level recovery test was performed using:

```text
C:\UserData\user_njl\Documents\TESTING.txt
```

<img width="811" height="99" alt="05-RecoveryTest" src="https://github.com/user-attachments/assets/14e2cadf-6277-4463-ba04-f3d48a021883" />


The file existed before the backup and was intentionally deleted after the backup completed.

This simulated a basic accidental file deletion scenario.

### Recovery Procedure

Opened:

```text
Windows Server Backup
→ Recover
```

Selected:

```text
Backup location:
This server

Recovery Type:
Files and folders
```

Browse the backup and selected:

```text
C:\UserData\user_njl\Documents\TESTING.txt
```


The recovery was configured with:

```text
Recovery destination:
Original location

Existing file behavior:
Create copies so that you have both versions

Security:
Restore access control list (ACL) permissions
```

<img width="928" height="722" alt="07-RecoveryOptions" src="https://github.com/user-attachments/assets/b641bcd0-3a5f-475f-8683-99605c48e643" />


Restoring ACL permissions ensures the recovered file retains the NTFS security information stored in the backup.

---

## Validation

The backup and recovery process was validated using both the Windows Server Backup interface and `wbadmin`.

### Backup Validation

The Windows Server Backup wizard reported:

```text
Status: Completed
```

for both:

```text
Local disk (C:)
System state
```

The backup was also listed by:

```powershell
wbadmin get versions
```

and the recoverable components were confirmed with:

```powershell
wbadmin get items -version:09/01/2026-17:35
```

### Recovery Validation

`TESTING.txt` was restored from the backup to its original location:

```text
C:\UserData\user_njl\Documents\TESTING.txt
```

This confirmed that the backup was not only created successfully but could also be used for file-level recovery.

---


## Validation Checklist

- [x] Added a dedicated backup virtual disk
- [x] Formatted the backup volume as `ServBackup (F:)`
- [x] Installed Windows Server Backup
- [x] Created a custom backup
- [x] Included `Local Disk (C:)`
- [x] Included System State
- [x] Stored the backup on `ServBackup (F:)`
- [x] Completed the initial backup successfully
- [x] Verified the backup using `wbadmin get versions`
- [x] Inspected recoverable items using `wbadmin get items`
- [x] Confirmed Active Directory-related backup components
- [x] Deleted a disposable test file
- [x] Performed a file-level recovery
- [x] Restored the file to its original location
- [x] Restored the file's ACL permissions

---

## Lessons Learned

Windows Server Backup provides built-in protection for server volumes, files, and System State without requiring third-party backup software.

Including System State is especially important for a Domain Controller because it protects critical Active Directory-related components required for recovery.

Using a separate backup volume provides better separation than storing the backup on the same operating system volume, although production backups should normally be stored on infrastructure that is independent from the server being protected.

The lab also demonstrated that successful backup status alone is not enough to validate a backup strategy. Using `wbadmin` confirmed that Windows recognized the backup and its recoverable components, while performing an actual file recovery confirmed that data could be restored when needed.

Testing both backup and recovery provided a more complete validation of the Windows Server backup process.
