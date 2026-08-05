\# Deploy Active Directory Domain Services



\## Objective



Install Active Directory Domain Services on `DC01`, create the new `ad.nlaur.com` forest, and verify that the server is functioning correctly as the first domain controller and DNS server in the lab.







\## Domain Design



| Setting | Value |

|---------|-------|

| Public Domain | `nlaur.com` |

| Active Directory Domain | `ad.nlaur.com` |

| Forest Root Domain | `ad.nlaur.com` |

| NetBIOS Name | `AD` |

| Domain Controller | `DC01` |

| Domain Controller IP | `192.168.50.10` |



\### Design Decision



A dedicated Active Directory subdomain was selected instead of using the public root domain directly.



Using `ad.nlaur.com` separates internal directory services from the public `nlaur.com` namespace while supporting future Microsoft Entra ID and Azure hybrid identity projects.







\## Pre-Deployment Configuration



Before installing Active Directory, the following requirements were confirmed:



\- \[x] Server renamed to `DC01`

\- \[x] Static IP address assigned

\- \[x] Default gateway configured

\- \[x] Preferred DNS configured for the server's future DNS role

\- \[x] Hyper-V checkpoint created before domain promotion

\- \[x] Active Directory namespace selected







\## Role Installation



The \*\*Active Directory Domain Services\*\* role and its required management features were installed through Server Manager.



\- \[x] Installed Active Directory Domain Services

\- \[x] Confirmed the AD DS role installation completed successfully



\## AD DS Role Installation







\---



\## Domain Controller Promotion



After installing the AD DS role, `DC01` was promoted using the Active Directory Domain Services Configuration Wizard.



\### Deployment Configuration



| Setting | Selection |

|---------|-----------|

| Deployment Operation | Add a new forest |

| Root Domain Name | `ad.nlaur.com` |

| DNS Server | Enabled |

| Global Catalog | Enabled |

| Read-Only Domain Controller | Disabled |

| NetBIOS Name | `AD` |

| Database Path | `C:\\Windows\\NTDS` |

| Log Path | `C:\\Windows\\NTDS` |

| SYSVOL Path | `C:\\Windows\\SYSVOL` |



A Directory Services Restore Mode password was configured and stored securely outside the repository.



> \[!IMPORTANT]

> Passwords, recovery credentials, and other secrets should never be included in screenshots, documentation, scripts, or GitHub commits.



\### Promotion Summary



!\[Domain controller promotion configuration](../screenshots/06/02-Promotion-Review.png)



\---



\## Prerequisite Check



The prerequisite validation completed successfully.



The wizard displayed a DNS delegation warning because no parent DNS delegation existed for `ad.nlaur.com`.



> \[!NOTE]

> This warning was expected because the lab uses an internal Active Directory DNS zone. A public DNS delegation was not required for this deployment.



!\[Prerequisite check passed](../screenshots/06/03-Prerequisite-Check.png)



\---



\## Installation Result



The promotion process completed successfully and automatically restarted the server.



After the restart:



\- `DC01` became the first domain controller in the new forest

\- The `ad.nlaur.com` domain was created

\- The DNS Server role was installed

\- Active Directory-integrated DNS zones were created

\- SYSVOL and NETLOGON shares were created

\- The built-in Administrator account became the domain Administrator account



\---



\## Validation



\### Server Identity



The server name and domain suffix were verified using:



```powershell

hostname

whoami

ipconfig /all

```



Expected results:



| Check | Expected Value |

|-------|----------------|

| Hostname | `DC01` |

| User Context | `AD\\Administrator` |

| Primary DNS Suffix | `ad.nlaur.com` |

| IPv4 Address | `192.168.50.10` |

| Default Gateway | `192.168.50.1` |



!\[Domain controller IP configuration](../screenshots/06/04-DC01-IPConfig-After-Promotion.png)



\---



\### Active Directory Domain



The domain configuration was verified with:



```powershell

Get-ADDomain

```



The command confirmed:



\- DNS root: `ad.nlaur.com`

\- NetBIOS name: `AD`

\- Domain controller: `DC01`



!\[Active Directory domain verification](../screenshots/06/05-Get-ADDomain.png)



\---



\### Active Directory Forest



The forest configuration was verified with:



```powershell

Get-ADForest

```



The command confirmed that `ad.nlaur.com` is the forest root domain.



!\[Active Directory forest verification](../screenshots/06/06-Get-ADForest.png)



\---



\### DNS Resolution



DNS was verified using:



```powershell

Resolve-DnsName ad.nlaur.com

Resolve-DnsName dc01.ad.nlaur.com

nltest /dsgetdc:ad.nlaur.com

```



These checks confirmed that:



\- The Active Directory domain resolves correctly

\- `DC01` has a valid DNS host record

\- Active Directory can locate the domain controller



!\[DNS resolution verification](../screenshots/06/07-DNS-Validation.png)



\---



\### DNS Client Configuration



After promotion, Windows configured the domain controller to query the local DNS service using loopback addresses:



```text

::1

127.0.0.1

```



This is expected because `DC01` now hosts the DNS service and the Active Directory-integrated DNS zones.



!\[DNS client configuration after promotion](../screenshots/06/08-DNS-Loopback.png)



\---



\### SYSVOL and NETLOGON



The required Active Directory shares were verified with:



```powershell

net share

```



The following shares were present:



\- `SYSVOL`

\- `NETLOGON`



!\[SYSVOL and NETLOGON shares](../screenshots/06/09-Net-Share.png)



\---



\### Management Tools



The following tools were confirmed in Server Manager:



\- Active Directory Users and Computers

\- Active Directory Administrative Center

\- Active Directory Domains and Trusts

\- Active Directory Sites and Services

\- DNS Manager

\- Group Policy Management



!\[Active Directory management tools](../screenshots/06/10-AD-Management-Tools.png)



\---



\## Lessons Learned



Active Directory depends heavily on DNS. Promoting `DC01` installed the DNS Server role and created the records required for domain discovery, authentication, LDAP, Kerberos, and Group Policy.



This deployment also demonstrated the importance of completing server naming and static IP configuration before domain promotion. Establishing those settings in advance avoids unnecessary changes to critical directory and DNS services later.



The DNS delegation warning was not a deployment failure. Understanding the difference between an expected warning and a blocking error is an important part of infrastructure administration.



Finally, validating the domain controller through multiple methods provided greater confidence than relying only on the Server Manager status page.



\---



\## Next Step



Design the Organizational Unit structure and create separate administrative and standard user accounts.



➡️ \[07 - Design Active Directory Organizational Units](07-design-active-directory-organizational-units.md)

