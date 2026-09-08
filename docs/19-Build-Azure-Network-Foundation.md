# Build the Azure Network Foundation

## Objective

Create the initial Microsoft Azure network foundation for the hybrid lab by organizing resources in a dedicated Resource Group, creating a Virtual Network and server subnet, and applying a Network Security Group to the subnet.

This establishes the Azure-side network that will later host Windows Server workloads and connect back to the existing on-premises `ad.nlaur.com` AD lab.

---

## Environment

| Setting | Value |
|---------|-------|
| Azure Subscription | `Azure subscription 1` |
| Resource Group | `rg-hybrid-lab` |
| Region | `West US 2` |
| Virtual Network | `vnet-hybrid-lab` |
| VNet Address Space | `10.10.0.0/16` |
| Server Subnet | `snet-servers` |
| Server Subnet Range | `10.10.10.0/24` |
| Network Security Group | `nsg-servers` |
| On-Premises Network | `192.168.50.0/24` |
| On-Premises Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` - `192.168.50.10` |

---

## Azure Network Design

The Azure network was designed so that it does not overlap with the existing Hyper-V lab network.

```text
ON-PREMISES / HYPER-V
192.168.50.0/24

DC01
192.168.50.10
AD DS / DNS
ad.nlaur.com

CLIENT01
192.168.50.20

        Future Hybrid Connectivity

                 |
                 v

MICROSOFT AZURE

rg-hybrid-lab
|
+-- vnet-hybrid-lab
    10.10.0.0/16
    |
    +-- snet-servers
        10.10.10.0/24
        |
        +-- nsg-servers
```

The separate address spaces prepare the environment for future routed connectivity between Azure and the on-premises lab.

---

## Design Decisions

### Dedicated Resource Group

A Resource Group named:

```text
rg-hybrid-lab
```

was created to contain the Azure resources associated with the hybrid lab.

Keeping related resources in one Resource Group simplifies organization, deployment tracking, access control, and future cleanup.

### Non-Overlapping Address Space

The Azure Virtual Network uses:

```text
10.10.0.0/16
```

while the existing on-premises Hyper-V network uses:

```text
192.168.50.0/24
```

The networks were intentionally kept separate to support future routing and hybrid connectivity without address conflicts.

### Dedicated Server Subnet

A subnet named:

```text
snet-servers
```

was created using:

```text
10.10.10.0/24
```

This subnet is reserved for Azure server workloads such as the future `AZ-SRV01` Windows Server virtual machine.

### Separate Network Security Group

A dedicated Network Security Group named:

```text
nsg-servers
```

was created separately rather than allowing a future VM deployment wizard to create a default NSG.

This provides a cleaner network design and allows security rules to be managed independently from individual virtual machines.

### Subnet-Level NSG Association

`nsg-servers` was associated directly with `snet-servers`.

This creates a common network security boundary for workloads deployed into the subnet.

No custom inbound rules were added during this phase.

---

## Resource Group

The Azure lab resources were organized under:

```text
rg-hybrid-lab
```

in:

```text
West US 2
```

The Resource Group was created successfully in the personal Azure subscription.

<img width="1562" height="574" alt="01-resourcegroupcreation" src="https://github.com/user-attachments/assets/b1575ac2-5cdc-4be6-83a0-80dc66a2f912" />


---

## Virtual Network

A Virtual Network named:

```text
vnet-hybrid-lab
```

was created inside `rg-hybrid-lab`.

The address space was configured as:

```text
10.10.0.0/16
```

Azure Bastion, Azure Firewall, and DDoS Network Protection were left disabled during this initial network build.

The deployment completed successfully.

<img width="1562" height="585" alt="02-vnetdeployment" src="https://github.com/user-attachments/assets/89feb5c2-bde1-473c-91ef-0867f8c5e6d8" />


---

## Server Subnet

The default subnet was replaced with a dedicated server subnet:

```text
Name:           snet-servers
Address range:  10.10.10.0/24
```

The deployed subnet showed:

```text
snet-servers
10.10.10.0/24
251 available IP addresses
```

This subnet will host future Azure Windows Server workloads.

<img width="1697" height="419" alt="03-serversubnet" src="https://github.com/user-attachments/assets/8738f682-a80e-4630-bcd2-9899588feb1e" />


---

## Network Security Group

A Network Security Group named:

```text
nsg-servers
```

was created in:

```text
rg-hybrid-lab
```

The NSG deployment completed successfully.

No custom inbound or outbound rules were added during this phase.

<img width="1562" height="541" alt="04-nsgdeployment" src="https://github.com/user-attachments/assets/d7086d50-1da7-468e-80ea-a046920a1423" />


---

## NSG Association

`nsg-servers` was associated with:

```text
Virtual network:
vnet-hybrid-lab

Subnet:
snet-servers

Address range:
10.10.10.0/24
```

This confirmed that the server subnet is protected by the dedicated Network Security Group.

<img width="1632" height="452" alt="05-nsgsubnet" src="https://github.com/user-attachments/assets/a834a638-4a5f-4eb8-a376-d486f0af867e" />


---

## Validation

The deployed Azure network foundation was reviewed in the Azure portal after creation.

Validation confirmed that:

- `rg-hybrid-lab` was created successfully.
- `vnet-hybrid-lab` was deployed in `West US 2`.
- The VNet uses the intended `10.10.0.0/16` address space.
- `snet-servers` exists with the `10.10.10.0/24` address range.
- The Azure address space does not overlap with the existing `192.168.50.0/24` on-premises lab network.
- `nsg-servers` was deployed successfully.
- `nsg-servers` is associated with `snet-servers`.
- No unnecessary inbound access rules were created during the network foundation phase.

The Azure-side network is now ready for future server workloads and hybrid connectivity.

---

## Lessons Learned

Azure Resource Groups provide a logical boundary for organizing related cloud resources and make it easier to manage an environment as a single project.

Using non-overlapping address spaces prevents routing conflicts when separate networks are eventually connected.

Creating purpose-specific subnets provides a cleaner network design and makes it easier to apply different security or routing policies to different workloads.

Network Security Groups provide traffic filtering independently from the virtual machine itself. Associating the NSG with the subnet establishes a shared security boundary for future server workloads.

This project established the Azure networking foundation that will support the next phase of the lab, including Azure Windows Server deployment and eventual connectivity back to the existing `ad.nlaur.com` environment.
