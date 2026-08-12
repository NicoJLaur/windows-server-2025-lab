# Deploy Active Directory Domain Services



## Objective



Install Active Directory Domain Services on `DC01`, create the new `ad.nlaur.com` forest, and verify that the server is functioning correctly as the first domain controller and DNS server in the lab.







## Domain Design



| Setting | Value |
|---------|-------|
| Public Domain | `nlaur.com` |
| Active Directory Domain | `ad.nlaur.com` |
| Forest Root Domain | `ad.nlaur.com` |
| NetBIOS Name | `AD` |
| Domain Controller | `DC01` |
| Domain Controller IP | `192.168.50.10` |



### Design Decision



A dedicated Active Directory subdomain was selected instead of using the public root domain directly.



Using `ad.nlaur.com` separates internal directory services from the public `nlaur.com` namespace while supporting future Microsoft Entra ID and Azure hybrid identity projects.



## Role Installation



The Active Directory Domain Services role and its required management features were installed through Server Manager.



- \[x] Installed Active Directory Domain Services

- \[x] Confirmed the AD DS role installation completed successfully



## AD DS Role Installation

<img width="958" height="497" alt="01-ADINSTALL" src="https://github.com/user-attachments/assets/ce99ae51-6f80-45d3-a903-837926f1630e" />






## Domain Controller Promotion



After installing the AD DS role, `DC01` was promoted using the Active Directory Domain Services Configuration Wizard.



### Deployment Configuration



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



### Promotion Summary



<img width="1368" height="858" alt="Screenshot 2026-08-05 085257" src="https://github.com/user-attachments/assets/332b7b5e-5f06-478a-910e-eec9b824e426" />







## Prerequisite Check



The prerequisite validation completed successfully.


<img width="1368" height="874" alt="07-Prerequisitecheck" src="https://github.com/user-attachments/assets/4555def2-20c5-46d0-aa5d-afc8900ba322" />


The wizard displayed a DNS delegation warning because no parent DNS delegation existed for `ad.nlaur.com`. This warning was expected because the lab uses an internal Active Directory DNS zone. A public DNS delegation was not required for this deployment.




## Installation Result



The promotion process completed successfully and automatically restarted the server.



After the restart:



- `DC01` became the first domain controller in the new forest

- The `ad.nlaur.com` domain was created

- The DNS Server role was installed

- Active Directory-integrated DNS zones were created

- SYSVOL and NETLOGON shares were created

- The built-in Administrator account became the domain Administrator account





## Validation



### Server Identity



The server name and domain suffix were verified using:



<img width="915" height="339" alt="Screenshot 2026-08-05 092649" src="https://github.com/user-attachments/assets/75a7a718-5085-4a94-ad73-921636fff0ce" />








### Active Directory Domain



The domain configuration was verified with:


<img width="1465" height="685" alt="09-GetADDomain" src="https://github.com/user-attachments/assets/fb349169-bf63-4227-b7dc-e2d004185cfd" />


The command confirmed:



\- DNS root: `ad.nlaur.com`

\- NetBIOS name: `AD`

\- Domain controller: `DC01`






### Active Directory Forest



The forest configuration was verified with:


<img width="1115" height="407" alt="08-ADForest" src="https://github.com/user-attachments/assets/7d17fae8-4f05-442c-9f4d-1bc70f77e05f" />




The command confirmed that `ad.nlaur.com` is the forest root domain.







### DNS Resolution



DNS was verified using:



<img width="1414" height="518" alt="05-DNSResolution" src="https://github.com/user-attachments/assets/c1727945-1f05-47fa-9d4b-fb94f7077532" />



These checks confirmed that:



\- The Active Directory domain resolves correctly

\- `DC01` has a valid DNS host record

\- Active Directory can locate the domain controller









### DNS Client Configuration



After promotion, Windows configured the domain controller to query the local DNS service using loopback addresses:


<img width="1089" height="304" alt="04-DNSVerified" src="https://github.com/user-attachments/assets/6ad3e461-2a3e-4bcb-9be0-314f32a84f74" />




This is expected because `DC01` now hosts the DNS service and the Active Directory-integrated DNS zones.








### SYSVOL and NETLOGON



The required Active Directory shares were verified with:


<img width="747" height="409" alt="03-Netshare" src="https://github.com/user-attachments/assets/5609060d-a45a-4120-931a-9f6afc7c1c14" />



The following shares were present:



\- `SYSVOL`

\- `NETLOGON`



<img width="791" height="295" alt="05-netshareresult" src="https://github.com/user-attachments/assets/2fb300fd-9d13-4758-8774-3d2b005b4fcf" />








### Management Tools



The following tools were confirmed in Server Manager:



\- Active Directory Users and Computers

\- Active Directory Administrative Center

\- Active Directory Domains and Trusts

\- Active Directory Sites and Services

\- DNS Manager

\- Group Policy Management



<img width="504" height="712" alt="Screenshot 2026-08-05 130600" src="https://github.com/user-attachments/assets/6ffe90f5-589e-44da-9770-91d7dd4e9a8d" />








## Lessons Learned



Active Directory depends heavily on DNS. Promoting `DC01` installed the DNS Server role and created the records required for domain discovery, authentication, LDAP, Kerberos, and Group Policy.



This deployment also demonstrated the importance of completing server naming and static IP configuration before domain promotion. Establishing those settings in advance avoids unnecessary changes to critical directory and DNS services later.



The DNS delegation warning was not a deployment failure. Understanding the difference between an expected warning and a blocking error is an important part of infrastructure administration.


