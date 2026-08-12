# Join Windows 11 Client to Active Directory

## Objective

Deploy a Windows 11 client virtual machine, configure it for the lab network, join it to the `ad.nlaur.com` Active Directory domain, and verify successful domain authentication.

---

## Environment

| Setting | Value |
|---------|-------|
| Client Name | CLIENT01 |
| Operating System | Windows 11 Pro |
| Hypervisor | Hyper-V |
| Domain | ad.nlaur.com |
| Virtual Switch | LabSwitch |


<img width="712" height="538" alt="01-client01-creation" src="https://github.com/user-attachments/assets/315a1fea-e138-4f3a-a9ba-1a8bf59493c4" />




---

## Network Configuration

| Setting | Value |
|---------|-------|
| IP Address | 192.168.50.20 |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 192.168.50.1 |
| Preferred DNS | 192.168.50.10 |

---

## Design Decisions

### Active Directory DNS


<img width="1359" height="855" alt="02-client01-adaptersettings" src="https://github.com/user-attachments/assets/893f8d81-b8d0-4e4c-8877-acbb7b1af203" />





CLIENT01 was configured to use the domain controller (`192.168.50.10`) as its preferred DNS server.

Active Directory relies on DNS to locate services such as Kerberos, LDAP, and Group Policy. Using a public DNS server would prevent the client from locating domain resources.

### Static IP

A static IP address was assigned during the initial deployment to simplify network validation and troubleshooting.

DHCP will be introduced later in the lab.

---

# Windows 11 Installation Notes

## TPM / Secure Boot Requirement


<img width="1278" height="1003" alt="04-OOBETMPISSUE" src="https://github.com/user-attachments/assets/a4e7932e-413a-4d94-a67a-d94fc4b20270" />




During Windows 11 installation, Setup reported that the virtual machine did not meet the minimum hardware requirements because TPM 2.0 and Secure Boot were unavailable.

### Resolution

The Windows Setup registry bypass was used to continue installation inside the lab virtual machine.

This workaround is acceptable because the VM exists solely for learning Active Directory administration and is not intended for production use.

> Future client deployments may use a Generation 2 virtual machine with a virtual TPM to satisfy Windows 11 hardware requirements. Although I did not want to run into the same issue I had when setting up DC01 with Windows Server 2025. 


<img width="1280" height="993" alt="05-TPMISSUERESOLVE" src="https://github.com/user-attachments/assets/b289428d-94ea-4bf7-a523-c6a1707e1038" />



---

## Network Requirement During OOBE


<img width="1279" height="987" alt="03-OOBEIssue" src="https://github.com/user-attachments/assets/edfae628-8750-4e11-accb-dfafb4592eef" />



Windows 11 required an internet connection during the Out-of-Box Experience (OOBE).

Since CLIENT01 was deployed on the isolated lab network, the setup process could not continue.

### Resolution

The following command was executed from the Windows Setup command prompt:

```cmd
OOBE\BYPASSNRO
```

After rebooting, the **I don't have Internet** option became available, allowing a local administrator account to be created.


<img width="1282" height="995" alt="06-OOBEISSUERESOLVE" src="https://github.com/user-attachments/assets/51f2caca-33a6-4fe7-aced-dfab865ce115" />



---

## Pre-Domain Join Validation

The following connectivity tests were completed before joining the domain.

- [x] CLIENT01 successfully communicated with DC01
- [x] CLIENT01 successfully communicated with the Hyper-V gateway
- [x] DNS resolution for `ad.nlaur.com`
- [x] DNS resolution for `dc01.ad.nlaur.com`
- [x] DNS service reachable on TCP port 53


<img width="1354" height="846" alt="07-PreDomainCheck" src="https://github.com/user-attachments/assets/5c1e04ae-3fc2-42c1-9ee3-87c1452a7e1c" />



---

# Domain Join

CLIENT01 was joined to:

```text
ad.nlaur.com
```

The domain administrator account (`admin_njl`) was used to authorize the join.

After the operation completed successfully, the client was restarted.


<img width="1368" height="848" alt="08-client01-domainjoin" src="https://github.com/user-attachments/assets/b81b9f9a-8854-4855-8f08-24052b5bff64" />



---

# Hyper-V Enhanced Session Issue

## Issue

After the domain join, signing in with the domain user displayed the following message:


<img width="1343" height="852" alt="09-userloginissue" src="https://github.com/user-attachments/assets/dbb597c3-7481-401a-b194-4b076718fc6c" />



The error was caused by Hyper-V attempting to use **Enhanced Session Mode**, which authenticates through Remote Desktop Services rather than the virtual machine console.

### Resolution

Enhanced Session Mode was disabled in Hyper-V Manager.

**Hyper-V Settings**

- Enhanced Session Mode Policy
  - Allow Enhanced Session Mode → Disabled

- User Settings
  - Use Enhanced Session Mode → Disabled

After reconnecting to CLIENT01 using the standard VM console, domain authentication succeeded normally.


<img width="1919" height="1037" alt="10-userloginresolve" src="https://github.com/user-attachments/assets/47d58dd0-f6c5-468b-ae6b-03d19391503d" />



---

# Domain Authentication

The following accounts successfully authenticated against Active Directory.

| Account | Purpose |
|---------|---------|
| admin_njl | Domain Administrator |
| user_njl | Standard User |

The standard user account (`user_njl`) was used for validation.

---

## Validation

### Logged-on User

```powershell
whoami
```

Result:

```text
ad\user_njl
```

---

### Distinguished Name

```powershell
whoami /fqdn
```

Confirmed the user account resides within:

```text
OU=Users List
```

inside the `ad.nlaur.com` domain.

---

### Group Policy

```powershell
gpresult /r
```

Successfully generated Resultant Set of Policy information, confirming the client received Active Directory Group Policy.


<img width="1279" height="913" alt="11-userloginvalidation" src="https://github.com/user-attachments/assets/8fe039f7-37a1-4880-8137-53359ddda991" />
<img width="1282" height="712" alt="12-gpresult" src="https://github.com/user-attachments/assets/b37e9bcf-580c-4a61-8c00-489ec5226b44" />



---

# Lessons Learned

- Active Directory clients must use an Active Directory-integrated DNS server rather than public DNS.
- DNS should always be verified before attempting to join a domain.
- Windows 11 hardware and network requirements can complicate virtual machine deployments and may require temporary workarounds in a lab environment.
- Hyper-V Enhanced Session Mode authenticates through Remote Desktop Services and can interfere with initial domain user sign-in if Remote Desktop logon rights have not been configured.
- Verifying the domain join with `whoami`, `whoami /fqdn`, and `gpresult /r` provides stronger validation than relying solely on the successful join message.
