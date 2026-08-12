# Windows Server 2025 Enterprise Homelab

> A documentation-driven Windows Server 2025 homelab built to develop enterprise systems administration skills using Hyper-V, Active Directory, DNS, Group Policy, PowerShell, and Windows networking.

![Windows Server](https://img.shields.io/badge/Windows%20Server-2025-blue)
![Hyper-V](https://img.shields.io/badge/Hyper--V-Lab-purple)
![Active%20Directory](https://img.shields.io/badge/Active%20Directory-AD%20DS-success)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE)
![Documentation](https://img.shields.io/badge/Documentation-In%20Progress-brightgreen)

---

# Project Overview

This project documents the complete deployment of a small enterprise Windows Server environment from the ground up using Microsoft best practices.

Rather than simply following installation guides, every stage of the lab is documented with implementation details, validation procedures, troubleshooting, design decisions, and lessons learned to simulate real-world systems administration documentation.

The environment is built entirely in **Hyper-V** using an isolated virtual network with **Windows NAT**, allowing realistic Active Directory administration without affecting the physical home network.

---

# Project Goals

- Deploy Windows Server 2025 in Hyper-V
- Build an Active Directory Domain Services environment
- Configure enterprise-style networking
- Implement DNS infrastructure
- Join Windows clients to the domain
- Deploy Group Policy Objects
- Configure password and account policies
- Document every deployment step and troubleshooting process

---

# Lab Architecture

```text
                           Internet
                               │
                     Windows 11 Host (LABHOST)
                               │
                    Hyper-V Internal Switch
                        192.168.50.0/24
                               │
               ┌───────────────┴───────────────┐
               │                               │
      DC01 (192.168.50.10)          CLIENT01 (192.168.50.20)
      Windows Server 2025             Windows 11 Pro
      Active Directory                Domain Joined
      DNS                             Standard User
      Group Policy
```

---

# Technologies Used

| Infrastructure | Microsoft Technologies |
|---------------|------------------------|
| Hyper-V | Windows Server 2025 |
| Windows NAT | Active Directory Domain Services |
| Internal Virtual Networking | DNS |
| PowerShell | Group Policy |
| Git | Windows 11 |
| GitHub | Hyper-V Manager |

---

# Skills Demonstrated

- Active Directory Administration
- Windows Server Deployment
- Hyper-V Virtualization
- DNS Configuration
- Group Policy Management
- Organizational Unit Design
- User and Group Administration
- Windows Networking
- NAT Configuration
- PowerShell
- Enterprise Troubleshooting
- Technical Documentation

---

# Project Progress

| Status | Lab |
|:---:|------|
| ✅ | 01 - Hyper-V Host Setup |
| ✅ | 02 - Create Domain Controller VM |
| ✅ | 03 - Install Windows Server 2025 |
| ✅ | 04 - Initial Server Configuration |
| ✅ | 05 - Configure Lab Networking |
| ✅ | 06 - Install Active Directory Domain Services |
| ✅ | 07 - Organizational Units, Users & Security Groups |
| ✅ | 08 - Deploy Windows Client & Join Domain |
| ✅ | 09 - Group Policy Management |
| ✅ | 10 - Password & Account Policies |
| ⏳ | Drive Mapping |
| ⏳ | Folder Redirection |
| ⏳ | Desktop Restrictions |
| ⏳ | File Server |
| ⏳ | DHCP |
| ⏳ | Windows Server Backup |
| ⏳ | PowerShell Automation |

---

# Documentation

| Document | Description |
|----------|-------------|
| [01 - Hyper-V Host Setup](docs/01-HyperV-LabHost-setup.md) | Configure the Windows host and Hyper-V environment |
| [02 - Create Domain Controller VM](docs/02-Create-Domain-Controller-VM.md) | Deploy the Windows Server virtual machine |
| [03 - Install Windows Server 2025](docs/03-Install-Windows-Server-2025.md) | Install Windows Server and document troubleshooting |
| [04 - Initial Server Configuration](docs/04-Initial-Server-Configuration.md) | Configure hostname, networking, and DNS |
| [05 - Configure Lab Networking](docs/05-Configure-Lab-Networking.md) | Configure Hyper-V networking and NAT |
| [06 - Install Active Directory](docs/06-Install-Active-Directory.md) | Deploy AD DS and DNS |
| [07 - Organizational Units, Users & Groups](docs/07-Organizational-Units.md) | Create enterprise OU structure and security groups |
| [08 - Windows Client Deployment](docs/08-Windows-Client-Deployment.md) | Deploy Windows 11 and join it to the domain |
| [09 - Group Policy Management](docs/09-Group-Policy.md) | Deploy and validate Group Policy Objects |
| [10 - Password & Account Policies](docs/10-Password-Account-Policy.md) | Configure centralized password and lockout policies |

---

# Current Environment

## Domain

```text
ad.nlaur.com
```

## Domain Controller

```text
DC01
```

## Client

```text
CLIENT01
```

## Network

```text
Subnet:          192.168.50.0/24

Gateway:         192.168.50.1

Domain Controller:
192.168.50.10

Client:
192.168.50.20
```

---

# Highlights

- Built a fully isolated Active Directory environment
- Configured internal DNS infrastructure
- Implemented Windows NAT networking
- Created Organizational Units following enterprise practices
- Created users and security groups
- Joined Windows clients to the Active Directory domain
- Deployed centralized Group Policy Objects
- Configured password and account lockout policies
- Validated every deployment using PowerShell
- Documented troubleshooting throughout the project

---

# Future Improvements

Planned additions include:

- File Server
- Drive Mapping
- Folder Redirection
- DHCP
- Desktop Restrictions
- Windows Server Backup
- PowerShell Automation
- WSUS
- Active Directory Certificate Services (AD CS)
- Multi-Client Environment
- Additional Domain Controllers

The project is continuously expanded as new Windows Server technologies and administrative scenarios are implemented.
