# 20 - Deploy Azure Windows Server 2025 Virtual Machine

## Objective

Deploy a Windows Server 2025 virtual machine in Microsoft Azure as the
first server workload in the Azure portion of the hybrid lab.

The VM was deployed into the existing Azure network foundation created
in Project 19. The design keeps the server private by using the existing
server subnet and subnet-level Network Security Group without assigning
a public IP address.

This project also documents two deployment issues encountered during
implementation: Azure VM-family quota restrictions and regional compute
capacity limitations.

------------------------------------------------------------------------

## Environment

| Component | Configuration |
| --- | --- |
| Azure Subscription | Azure subscription 1 |
| Resource Group | `rg-hybrid-lab` |
| Region | West US 2 |
| Virtual Network | `vnet-hybrid-lab` |
| VNet Address Space | `10.10.0.0/16` |
| Server Subnet | `snet-servers` |
| Server Subnet Range | `10.10.10.0/24` |
| Subnet NSG | `nsg-servers` |
| Local Hyper-V Network | `192.168.50.0/24` |
| Local Domain Controller | `DC01` - `192.168.50.10` |
| Local AD Domain | `ad.nlaur.com` |

------------------------------------------------------------------------

## VM Design

The Azure server was designed as a small, cost-conscious lab VM that can
later participate in the hybrid Windows Server environment.

``` text
Azure
└── rg-hybrid-lab
    ├── vnet-hybrid-lab
    │   └── snet-servers
    │       └── AZSRV-01
    │           └── 10.10.10.4
    └── nsg-servers
        └── Associated with snet-servers
```

The existing on-premises Hyper-V lab remains on a separate network:

``` text
Hyper-V Lab
└── 192.168.50.0/24
    └── DC01
        ├── 192.168.50.10
        └── ad.nlaur.com
```

At this stage, the Azure and Hyper-V networks are intentionally
separate. Hybrid connectivity will be implemented in a later project.

------------------------------------------------------------------------

## Design Decisions

### Windows Server 2025 Azure Edition

`AZSRV-01` was deployed using **Windows Server 2025 Datacenter: Azure Edition**, x64 Generation 2.

Azure Edition was selected because the VM runs natively in Azure and supports Azure-specific Windows Server capabilities such as Hotpatch integration.

The local Hyper-V domain controller continues to use the standard Windows Server installation, while the Azure workload uses the Azure-optimized edition.

### Private-Only Networking

`AZSRV-01` was deployed without a public IP address and uses the existing server subnet and subnet-level `nsg-servers` Network Security Group rather than an additional NIC-level NSG.

This reduces direct Internet exposure and prepares the VM for private connectivity with the local Hyper-V environment later in the hybrid lab.

### Cost-Conscious VM Sizing

The final VM uses `Standard_B2ls_v2`, providing:

- 2 vCPUs
- 4 GiB RAM

This provides sufficient resources for the lab while keeping compute requirements low.

The original `B2als_v2` selection was changed because of regional capacity limitations. The deployment failure and size change are documented in the **Deployment Troubleshooting** section.

### Storage

A managed **Standard SSD LRS** OS disk was selected instead of Premium SSD storage because the lab does not require high-performance disk I/O.

This provides adequate storage performance while keeping the Azure deployment cost-conscious. The disk is also configured for automatic deletion with the VM to reduce the chance of leaving unused storage resources behind.

### Trusted Launch

Trusted Launch was enabled to provide a stronger security baseline for the Azure VM through **Secure Boot** and **virtual TPM (vTPM)**.

These protections were enabled without introducing additional security services or unnecessary complexity into the initial lab deployment.

### Cost Controls

Auto-shutdown was enabled to prevent the VM from running unnecessarily when the lab is not in use.

The shutdown schedule and other management settings are documented in the **Management and Monitoring Configuration** section.


------------------------------------------------------------------------

## Initial VM Configuration

The VM was created with the following primary configuration:

| Setting | Value |
| --- | --- |
| VM Name | `AZSRV-01` |
| Region | West US 2 |
| Availability | No infrastructure redundancy required |
| Security Type | Trusted Launch |
| Secure Boot | Enabled |
| vTPM | Enabled |
| Image | Windows Server 2025 Datacenter: Azure Edition |
| Architecture | x64 |
| Administrator | `azureuser` |
| Public Inbound Ports | None |
| Azure Hybrid Benefit | No |
| Azure Spot | No |

Microsoft Entra ID login and a system-assigned managed identity were left disabled for the initial deployment and can be introduced during later identity-focused projects.

------------------------------------------------------------------------

## Disk Configuration

The VM was configured with:

| Setting | Value |
| --- | --- |
| OS Disk Size | Image default |
| OS Disk Type | `StandardSSD_LRS` |
| Managed Disk | Yes |
| Delete OS Disk with VM | Yes |
| Ephemeral OS Disk | None |
| Disk Controller | SCSI |


------------------------------------------------------------------------

## Network Configuration

`AZSRV-01` was placed directly into the network foundation from Project 19.

| Setting | Value |
| --- | --- |
| Virtual Network | `vnet-hybrid-lab` |
| Subnet | `snet-servers` |
| Subnet Range | `10.10.10.0/24` |
| Public IP | None |
| NIC NSG | None |
| Subnet NSG | `nsg-servers` |
| Accelerated Networking | Off |
| Load Balancer | None |
| Delete NIC with VM | Enabled |

After deployment, Azure assigned the VM the private address: `10.10.10.4`

<img width="1467" height="445" alt="image" src="https://github.com/user-attachments/assets/aae8161e-ef06-4e2f-a608-a4bbc56cf2b9" />

Because the server does not have a public IP and hybrid routing has not yet been configured, the local Hyper-V environment does not currently have a direct route to this address.

------------------------------------------------------------------------

## Management and Monitoring Configuration

The following management settings were used:

| Setting | Configuration |
| --- | --- |
| System-Assigned Managed Identity | Off |
| Microsoft Entra ID Login | Off |
| Backup | Off |
| Site Recovery | Off |
| Periodic Assessment | On |
| Hotpatch | On |
| Patch Orchestration | Azure-orchestrated |
| Reboot Setting | Reboot if required |
| Auto-Shutdown | On |
| Shutdown Time | 19:00 |
| Time Zone | Pacific Standard Time |
| Shutdown Notification | On |
| Hibernation | Off |

Monitoring was intentionally kept lightweight:

| Setting | Configuration |
| --- | --- |
| Alerts | Off |
| Boot Diagnostics | On |
| OS Guest Diagnostics | Off |
| Application Health Monitoring | Off |


------------------------------------------------------------------------

## Resource Tags

| Tag | Value |
| --- | --- |
| Environment | `Lab` |
| Project | `Hybrid-Lab` |
| Purpose | `Windows-Server` |

Tags were used to identify the environment and purpose of the Azure resources.

------------------------------------------------------------------------

## Deployment Troubleshooting

### Basv2 VM Family Quota

The initial design used:

`Standard_B2als_v2`

The first deployment attempt failed because the subscription had a
**Basv2 family vCPU quota of 0** in West US 2.

Azure returned a quota error indicating that 2 additional vCPUs were
required.

During troubleshooting, a quota request was initially submitted for the
similarly named **Bsv2** family. This quota increase was approved, but
`B2als_v2` belongs to the **Basv2** family.

The correct Basv2 quota was then requested so that the intended VM
family could be deployed.

This demonstrated the importance of distinguishing between Azure VM
families with similar names.

### Regional Capacity Failure

After the quota issue was resolved, deployment of `Standard_B2als_v2`
was attempted again.

The VM deployment failed with:

`AllocationFailed`

<img width="1908" height="677" alt="03-FailedDeployment" src="https://github.com/user-attachments/assets/056cf2ed-1d1d-490d-b280-615cab01e1cb" />

Azure reported that there was insufficient capacity for the requested VM
size in West US 2.

The network interface was successfully created during the failed
deployment, but the virtual machine itself could not be allocated.

This failure was different from the earlier quota issue:

-   **QuotaExceeded** - the subscription was not authorized for enough
    vCPUs in the VM family.
-   **AllocationFailed** - the subscription was authorized, but Azure
    did not have sufficient regional capacity for the requested VM size.

### Selecting an Alternate VM Size

Instead of continuing to retry the capacity-constrained `B2als_v2`, `Standard_B2ls_v2` was selected as an alternative.

The previously approved Bsv2 quota allowed this VM family to be used. The existing NIC from the failed deployment was reused, and `AZSRV-01` was successfully redeployed using the new size.

------------------------------------------------------------------------

## Successful Deployment

The completed Azure deployment created or configured the following
resources:

-   `AZSRV-01` virtual machine
-   `azsrv-01217` network interface
-   `shutdown-computevm-AZSRV-01` auto-shutdown schedule

The VM reached the **Running** state and the Azure VM Agent reported
**Ready**.

<img width="1594" height="869" alt="01-AZSRV01Deployment" src="https://github.com/user-attachments/assets/7a7b422a-1d9e-4a20-9ac0-95c18b69577d" />

------------------------------------------------------------------------

## Validation

The Azure portal Overview page was used to validate the final VM deployment.

The following values were confirmed:

| Validation Item | Result |
| --- | --- |
| VM exists | `AZSRV-01` |
| VM status | Running |
| Region | West US 2 |
| Operating system | Windows Server 2025 Datacenter Azure Edition |
| Architecture | x64 |
| VM generation | V2 |
| VM size | `Standard_B2ls_v2` |
| vCPUs | 2 |
| Memory | 4 GiB |
| Azure VM Agent | Ready |
| VNet | `vnet-hybrid-lab` |
| Subnet | `snet-servers` |
| Private IPv4 | `10.10.10.4` |
| Public IPv4 | None |
| Environment tag | Lab |
| Project tag | Hybrid-Lab |
| Purpose tag | Windows-Server |

The absence of a public IP confirmed that the server remained private inside the Azure VNet.

<img width="1852" height="877" alt="04-AZSRV01Overview" src="https://github.com/user-attachments/assets/d868cb38-e93b-4370-8ff7-94c6b6d5fd4d" />

The two networks do not yet have private routing between them.
Establishing that connectivity will be handled as the next phase of the
hybrid lab.


------------------------------------------------------------------------

## Lessons Learned

- Azure subscription quota and regional compute capacity are separate deployment constraints.
- Similar VM-family names such as Bsv2 and Basv2 represent different quota categories and must be verified carefully.
- Selecting an alternate VM size can be preferable to repeatedly attempting a capacity-constrained SKU.
- Existing VNets, subnets, and subnet-level NSGs can be reused without creating unnecessary networking resources.
- Private-only Azure VMs reduce Internet exposure but require a private management path before direct connectivity is possible.
- Right-sized burstable VMs, Standard SSD storage, and auto-shutdown help control costs in a personal Azure lab.

With `AZSRV-01` successfully running on the Azure server subnet, the Azure compute foundation is ready for the next stage of the hybrid lab: establishing connectivity between the local Hyper-V network and Azure.
