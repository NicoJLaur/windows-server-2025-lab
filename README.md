# Windows Server 2025 Enterprise Homelab

> A hands-on Windows Server 2025 infrastructure lab built to develop
> practical systems administration experience with Hyper-V, Active
> Directory, DNS, Group Policy, file services, backup and recovery, and
> PowerShell automation.

![Windows
Server](https://img.shields.io/badge/Windows%20Server-2025-blue)
![Hyper-V](https://img.shields.io/badge/Hyper--V-Lab-purple) ![Active
Directory](https://img.shields.io/badge/Active%20Directory-AD%20DS-success)
![PowerShell](https://img.shields.io/badge/PowerShell-Automation-5391FE)
![Status](https://img.shields.io/badge/On--Prem%20Phase-Complete-brightgreen)

The environment was built from the ground up on Hyper-V, beginning with
isolated virtual networking and progressing through Windows Server
deployment, Active Directory administration, Group Policy, role-based
access control, backup/recovery, and automated AD user lifecycle
management.

------------------------------------------------------------------------

## Lab Architecture

``` text
                              Internet
                                 |
                         Windows 11 LABHOST
                     Hyper-V / Windows NAT
                                 |
                     LabSwitch - Internal vSwitch
                         192.168.50.0/24
                                 |
                +----------------+----------------+
                |                                 |
       DC01 - 192.168.50.10              CLIENT01 - 192.168.50.20
       Windows Server 2025                Windows 11 Pro
                |                                 |
       +--------+---------+                  Domain Joined
       |        |         |                  GPO Client
     AD DS     DNS    File Services
       |
   ad.nlaur.com
```

------------------------------------------------------------------------

## Projects

Each project links to the full implementation notes, screenshots,
validation, troubleshooting, and lessons learned.

  -----------------------------------------------------------------------------------------------------------------------------
| # | Project | Objective |
|---:|---|---|
| 01 | [Hyper-V Host Setup](docs/01-HyperV-LabHost-setup.md) | Configured the Windows 11 Hyper-V host and internal virtual switch. |
| 02 | [Create Domain Controller VM](docs/02-Create-Domain-Controller-VM.md) | Designed and created the `DC01` Windows Server virtual machine. |
| 03 | [Install Windows Server 2025](docs/03-Install-Windows-Server-2025.md) | Installed Server 2025 and troubleshot a Generation 2 UEFI boot failure. |
| 04 | [Initial Server Configuration](docs/04-Initial-Server-Configuration.md) | Configured the DC01 hostname, static IP addressing, gateway, and DNS. |
| 05 | [Configure Lab Networking](docs/05-Configure-Lab-Networking.md) | Built an isolated `192.168.50.0/24` network with Hyper-V Internal Switch and Windows NAT. |
| 06 | [Deploy Active Directory Domain Services](docs/06-Install-Active-Directory.md) | Created the `ad.nlaur.com` forest and configured AD-integrated DNS. |
| 07 | [Active Directory Organizational Structure](docs/07-Organizational-Units.md) | Designed OUs, administrative accounts, standard users, and security groups. |
| 08 | [Windows 11 Client Deployment](docs/08-Windows-Client-Deployment.md) | Deployed `CLIENT01`, joined it to the domain, and validated domain authentication. |
| 09 | [Group Policy Management](docs/09-GroupPolicy-Fundamentals.md) | Deployed centralized desktop configuration and validated GPO processing. |
| 10 | [Password & Account Policies](docs/10-Password-Account-Policy.md) | Configured domain-wide password and account lockout policies. |
| 11 | [Shared Resources & NTFS Permissions](docs/11-Configure-Shared-Resources-and-NTFS-Permissions.md) | Built SMB shares and implemented group-based NTFS access control. |
| 12 | [Drive Mapping with Group Policy](docs/12-Configure-Drive-Mapping.md) | Used Group Policy Preferences and Item-Level Targeting for role-based mapped drives. |
| 13 | [Folder Redirection](docs/13-Configure-Folder-Redirection.md) | Redirected user Documents to server storage and troubleshot NTFS ACL/ownership issues. |
| 14 | [Windows Server Backup & File Recovery](docs/14-Windows-Server-Backup-and-File-Recovery.md) | Backed up `DC01` and System State, verified with `wbadmin`, and performed a file recovery. |
| 15 | [Software Deployment with Group Policy](docs/15-Software-Deployment-GroupPolicy.md) | Automatically deployed 7-Zip to `CLIENT01` using Group Policy Software Installation. |
| 16 | [AD User Provisioning with PowerShell](docs/16-AD-User-Provisioning-with-Powershell.md) | Automated CSV-based account creation, OU placement, group assignment, and duplicate detection. |
| 17 | [AD User Auditing with PowerShell](docs/17-Audit-AD-Users-Powershell.md) | Automated account, password, logon, and security-group reporting to CSV. |
| 18 | [AD User Offboarding with PowerShell](docs/18-Offboarding-Automation-Powershell.md) | Automated group cleanup, account disablement, OU relocation, and offboarding audit logging. |

------------------------------------------------------------------------

## Environment

  -----------------------------------------------------------------------
  Component                           Configuration
  ----------------------------------- -----------------------------------
  Hyper-V Host                        `LABHOST` - Windows 11 Pro

  Host Hardware                       Dell Latitude 5450, Intel Core
                                      Ultra 5 125U, 16 GB RAM

  Hypervisor                          Microsoft Hyper-V

  Virtual Switch                      `LabSwitch` - Internal

  NAT                                 `LabNAT`

  Lab Network                         `192.168.50.0/24`

  Gateway                             `192.168.50.1`

  Domain Controller                   `DC01` - Windows Server 2025 -
                                      `192.168.50.10`

  Client                              `CLIENT01` - Windows 11 Pro -
                                      `192.168.50.20`

  Active Directory Domain             `ad.nlaur.com`
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Key Highlights

### Active Directory & DNS

Built a new `ad.nlaur.com` forest, promoted `DC01` as the first domain
controller, configured AD-integrated DNS, designed the OU structure,
separated standard and administrative accounts, and implemented
security-group-based administration.

### Role-Based Resource Access

Combined Active Directory security groups, SMB shares, NTFS permissions,
Group Policy Preferences, and Item-Level Targeting to control both
access to resources and which mapped drives users receive.

### Troubleshooting

Documented and resolved issues including Windows Server Generation 2
boot failure, Windows 11 TPM/OOBE requirements, Hyper-V Enhanced Session
authentication behavior, and Folder Redirection ACL/ownership problems.

### Backup & Recovery

Configured Windows Server Backup with a dedicated backup volume and
System State protection, verified recoverable components with `wbadmin`,
and restored an intentionally deleted file with its ACL permissions.

### PowerShell User Lifecycle Automation

``` text
CSV User Data
     |
     v
User Provisioning
     |
     v
Active Directory
     |
     v
User Auditing
     |
     v
User Offboarding
```

Created reusable PowerShell workflows for provisioning users, assigning
groups, auditing account state, exporting reports, removing access
during offboarding, disabling accounts, relocating disabled users, and
maintaining an audit log.

------------------------------------------------------------------------

## Lab Design Notes

This lab runs on a 16 GB Windows 11 Hyper-V host, so some services that
would normally be separated in a production environment are
intentionally consolidated on `DC01`.

For example, shared resources and redirected user data are hosted on the
domain controller to keep the lab practical within the available
hardware. The individual project documentation identifies these
compromises and distinguishes the homelab implementation from a
production reference architecture.

------------------------------------------------------------------------

## Next Phase: Azure & Hybrid Infrastructure

The core on-premises Windows Server phase is complete through Project
18.

The next phase will use this environment as the on-premises foundation
for a Microsoft Azure hybrid lab, with planned work around:

-   Azure resource organization and virtual networking
-   Windows Server workloads in Azure
-   Hybrid network connectivity and DNS
-   Microsoft Entra ID and hybrid identity
-   Azure RBAC
-   Azure Monitor and Log Analytics
-   Azure Backup

The goal is to extend the existing `ad.nlaur.com` environment into a
practical hybrid Microsoft infrastructure project.
