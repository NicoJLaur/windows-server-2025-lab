# Initial Server Configuration



## Objective



Prepare Windows Server 2025 for its future role as the first Active Directory Domain Controller by configuring the server identity and assigning a static network configuration. 



## Server Configuration



| Setting | Value |
|---------|-------|
| Computer Name | DC01 |
| Operating System | Windows Server 2025 Standard Evaluation |
| Role | Future Domain Controller |

## Network Configuration

| Setting | Value |
|---------|-------|
| IPv4 Address | 192.168.50.10 |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 192.168.50.1 *(or None if that's what you actually configured at this stage)* |
| Preferred DNS | 192.168.50.10 |

## Design Decisions
### Static IP Address
A domain controller should always use a static IP address to ensure clients can consistently locate Active Directory and Domain services.

### Preferred DNS
This will be a temporary decision to prepare the server into becoming the domain controller. The preferred DNS server was configured as the server's own IP address because the server will host Active Directory integrated DNS service after promotion.


## Validation

The following initial configuration task were completed:


- [x] Renamed the server to 'DC01'


<img width="959" height="504" alt="02-RenameServer" src="https://github.com/user-attachments/assets/a598a177-7058-45f9-95a5-4e7d1c7303d4" />



- [x] Configured a static IPv4 address
- [x] Configured DNS server


<img width="959" height="500" alt="03-StaticIP-Config" src="https://github.com/user-attachments/assets/312bc9fb-a2af-4af8-a18f-8120361c7971" />



- [x] Confirmed the new hostname and network configuration


<img width="957" height="502" alt="04-LocalServer-After" src="https://github.com/user-attachments/assets/b391f7b8-12d0-4b24-a1b3-5da97baa3b93" />



## Learned


Configuring a static IP address before installing Active Directory helps ensure consistent network communication.




