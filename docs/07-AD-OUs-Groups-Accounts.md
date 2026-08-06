# Design Active Directory Organizational Structure

## Objective

Design the Active Directory organizational structure by creating Organizational Units (OUs), security groups, and user accounts that establish a scalable and manageable administration model for the `ad.nlaur.com` domain.

---

## Environment

| Component | Value |
|-----------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| Forest | `ad.nlaur.com` |

---

## Organizational Unit Structure

The following Organizational Units (OUs) were created to logically separate administrative accounts, standard users, servers, workstations, and security groups.


<img width="706" height="362" alt="01-OUs" src="https://github.com/user-attachments/assets/556bbafc-ece0-45c5-9127-2254cff51c1b" />



| Organizational Unit | Purpose |
|---------------------|---------|
| Admin | Administrative user accounts |
| Groups | Security groups |
| Servers | Server objects |
| ├── Domain Controllers | Default location for domain controllers |
| └── Member Servers | Future application and infrastructure servers |
| Service Accounts | Service identities |
| Users List | Standard user accounts |
| Workstations | Domain-joined client computers |

### Active Directory Layout

```text
ad.nlaur.com
│
├── Admin
│   └── admin_njl
│
├── Groups
│   ├── IT_Admins
│   ├── IT_Technicians
│   └── Server_Admins
│
├── Servers
│   ├── Domain Controllers
│   └── Member Servers
│
├── Service Accounts
│
├── Users List
│   └── user_njl
│
└── Workstations
```

---

## Design Decisions

### Organizational Units

Custom Organizational Units were created to organize objects based on administrative function rather than relying on the default Active Directory containers.

This structure simplifies administration and prepares the environment for future Group Policy deployment.

### Administrative Accounts

A dedicated administrative account (`admin_njl`) was created separately from the standard user account (`user_njl`).

Using separate accounts reduces the use of elevated privileges during normal daily activities and follows the principle of least privilege.

### Security Groups

Administrative permissions are assigned through security groups instead of directly to user accounts.

This approach simplifies permission management and allows additional administrators to be added by modifying group membership rather than individual permissions.

### Domain Controllers

`DC01` remains in the default **Domain Controllers** Organizational Unit.

This OU contains Microsoft's default domain controller policies and should remain the location for all domain controllers in the forest.

---

## Security Groups

<img width="813" height="411" alt="02-SecurityGroups" src="https://github.com/user-attachments/assets/d970224f-1206-4da5-9efb-880ae9e31c33" />


| Group | Purpose |
|--------|---------|
| IT_Admins | Domain administration |
| IT_Technicians | Help desk administration |
| Server_Admins | Windows Server administration |

---

## User Accounts

<img width="955" height="561" alt="03-adminaccountcreation" src="https://github.com/user-attachments/assets/a014bc11-1e46-4fd3-82e5-7119fb5ac6da" />
<img width="939" height="587" alt="standardaccountcreation" src="https://github.com/user-attachments/assets/d4f3092b-5616-4c10-abd0-678b00cc9b25" />



| Account | Purpose |
|----------|---------|
| admin_njl | Administrative account |
| user_njl | Standard user account |

---

## Validation

The following tasks were completed successfully:

- [x] Created Organizational Units
- [x] Created security groups
- [x] Created administrative account
- [x] Created standard user account
- [x] Added `admin_njl` to `IT_Admins`


<img width="1363" height="650" alt="04-nestedITadmins" src="https://github.com/user-attachments/assets/d85c467f-0a48-47b5-9423-f0cab40e8e94" />



- [x] Added `IT_Admins` to `Domain Admins`


<img width="1368" height="722" alt="05-nestedadmingroup" src="https://github.com/user-attachments/assets/72dae855-2357-4d36-b711-73fe62c42c15" />



- [x] Verified inherited administrative permissions


---

## Lessons Learned

A well-designed Organizational Unit structure provides the foundation for scalable Active Directory administration.

Separating administrative accounts from standard user accounts reduces unnecessary exposure to elevated privileges and aligns with enterprise security practices.

Managing permissions through security groups instead of assigning them directly to user accounts simplifies administration and improves long-term maintainability.

---

## Next Step

Deploy a Windows 11 client (`CLIENT01`) and join it to the `ad.nlaur.com` domain to validate authentication, DNS, and Group Policy functionality.
