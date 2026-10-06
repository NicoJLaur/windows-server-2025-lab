# Project 22 - Azure VM Backup and Recovery

## Objective

Configure Azure Backup for `AZSRV-01`, create a recovery point, restore the server as a separate virtual machine, verify that the recovered operating system boots successfully, and remove temporary recovery resources after testing.

## Environment

| Component | Configuration |
| --- | --- |
| Subscription | Azure subscription 1 |
| Resource Group | `rg-hybrid-lab` |
| Region | West US 2 |
| Source VM | `AZSRV-01` |
| Source VM Size | `Standard_B2ls_v2` - 2 vCPU, 4 GiB RAM |
| Source VM Network | `vnet-hybrid-lab` / `snet-servers` |
| Recovery Services Vault | `rsv-hybrid-lab` |
| Backup Policy | `AZSRV01-BackupPolicy` |
| Restored VM | `AZSRV-01-Restore` |
| Temporary Staging Account | `sthybridstor` |

## Design

The recovery design used Azure Backup to protect the existing Windows Server VM and restore it as a separate VM without modifying the original server.

```text
AZSRV-01
    |
    v
Azure VM Backup
    |
    v
rsv-hybrid-lab
    |
    v
Recovery Point
    |
    v
Restore Operation
    |
    +--> Temporary Staging Storage
    |
    v
AZSRV-01-Restore
    |
    v
Boot Diagnostics
```

The restored VM remained on the existing private Azure network. Boot Diagnostics was used to verify the recovered operating system because direct connectivity to the Azure subnet was not yet available.

## Backup Configuration

A Recovery Services vault named `rsv-hybrid-lab` was created in West US 2.

<img width="835" height="571" alt="01-RSV" src="https://github.com/user-attachments/assets/b043f9db-6c1c-4489-b888-2b6cb4672e67" />

The vault used:

- Locally-redundant storage (LRS)
- Microsoft-managed encryption
- Reversible immutability
- Public network access

LRS was selected for the non-production lab rather than using geographic redundancy. Microsoft-managed encryption also avoided introducing Key Vault and customer-managed key dependencies.

An Enhanced backup policy named `AZSRV01-BackupPolicy` was configured for `AZSRV-01`.

| Setting | Value |
| --- | --- |
| Frequency | Daily |
| Backup Time | 8:00 AM |
| Time Zone | Pacific Time |
| Instant Restore Retention | 2 days |
| Daily Recovery Point Retention | 7 days |
| Disk Selection | All disks |
| Future Disks | Included |

<img width="857" height="840" alt="02-BackupPolicy-wrongname" src="https://github.com/user-attachments/assets/53c7fc97-42fb-4bad-8946-7229bd5e7aa4" />

> **Note:** The screenshot was captured while the policy was temporarily named `AZSRV02-BackupPolicy`. It was corrected to `AZSRV01-BackupPolicy` before the backup configuration was completed.

Weekly, monthly, and yearly retention were not configured because this project focused on short-term backup and recovery testing.

## Backup and Recovery Point

An on-demand backup of `AZSRV-01` was started on October 2, 2026.

The backup completed successfully in approximately 42 minutes and created a recovery point for the VM.

<img width="1663" height="883" alt="03-BackupDesign" src="https://github.com/user-attachments/assets/8b73b0ae-b48e-443d-ac7b-40e08221d27b" />

The resulting recovery point was:

- Snapshot and Vault-Standard
- Crash Consistent
- Immutable
- Backup Pre-Check: Passed
- Last Backup Status: Success

Although the Enhanced policy supported application or file-system consistent recovery points, the recovery point generated during this backup was crash-consistent.

## Restore Attempt

The recovery point was used to restore the server as a separate virtual machine.

| Setting | Value |
| --- | --- |
| Restore Type | Create new virtual machine |
| VM Name | `AZSRV-01-Restore` |
| Resource Group | `rg-hybrid-lab` |
| Virtual Network | `vnet-hybrid-lab` |
| Subnet | `snet-servers` |
| Availability Zone | NoZone |
| Restore Identity | Disabled |

Azure Backup required a staging location for the restore operation. A temporary Standard LRS storage account named `sthybridstor` was created in West US 2.

<img width="1147" height="850" alt="05-storageaccount" src="https://github.com/user-attachments/assets/a62525b7-1299-4a39-a445-8492e3b190f6" />

The storage account was used only for recovery staging and was configured with:

- Standard performance
- Locally-redundant storage (LRS)
- Hot access tier
- Microsoft-managed encryption
- Secure transfer enabled
- TLS 1.2
- Public network access

Features unnecessary for temporary recovery staging, including hierarchical namespace, SFTP, NFS, versioning, and soft delete, remained disabled.

## Restore Troubleshooting and Recovery

Azure Backup successfully transferred the recovery data, but creation of `AZSRV-01-Restore` completed with warnings.

The restore job reported:

`UserErrorCoreCountSubscriptionQuotaReached`

<img width="1883" height="569" alt="06-Restorewarnings" src="https://github.com/user-attachments/assets/3bc82462-ba95-4f80-82f6-cd62370e6b45" />

`AZSRV-01` uses the `Standard_B2ls_v2` VM size. The subscription's Standard Bsv2 Family quota in West US 2 was fully consumed at **2 of 2 vCPUs**.

Stopping and deallocating the original VM did not reduce the quota usage. Additional Bsv2 capacity was therefore required before Azure could create the restored VM.

The Bsv2 family quota was increased from 2 to 4 vCPUs.

<img width="1320" height="420" alt="04-quotaincrease" src="https://github.com/user-attachments/assets/169d4ee4-0711-4392-bb34-cab3e59e0649" />

After the increase, the subscription showed:

```text
Standard Bsv2 Family vCPUs
2 of 4 in use
```

This provided enough capacity for the existing two-vCPU `AZSRV-01` and the temporary two-vCPU restored VM.

### Completing the Restore

The failed restore had already transferred the recovery data and generated deployment artifacts in `sthybridstor`.

Instead of repeating the complete restore process, the **Deploy Create VM Template** option from the existing restore job was used.

The generated ARM template retained the recovery configuration for:

- `rg-hybrid-lab`
- West US 2
- `vnet-hybrid-lab`
- `snet-servers`
- Restored OS disk
- Restore-specific network interface

The virtual machine name was set to `AZSRV-01-Restore`.

After the quota issue was resolved, the custom ARM deployment completed successfully and created the restored virtual machine and its recovery-specific network resources.

<img width="1582" height="661" alt="04-customdeployment" src="https://github.com/user-attachments/assets/bd7fd2fc-8f58-45c5-80ae-0a90dc4aa97d" />


## Recovered Operating System

Boot Diagnostics was not automatically configured on `AZSRV-01-Restore`, so it was enabled using the Microsoft-managed storage option.

Boot Diagnostics then displayed the Windows Server lock screen.

<img width="990" height="817" alt="07-Bootdiag" src="https://github.com/user-attachments/assets/5b245edd-452d-4496-88d5-e90c482d6911" />

This confirmed that the recovered OS disk successfully booted and that `AZSRV-01-Restore` was operational.

Because the Azure subnet remained private and the separate Site-to-Site VPN project was unfinished, direct RDP connectivity was not required for this recovery test.

Boot Diagnostics provided a way to verify **guest operating system health independently of network reachability**.

## Recovery Cleanup

After the recovered VM was verified and the required screenshots were captured, the temporary recovery resources were removed to avoid unnecessary Azure costs.

The following temporary resources were deleted:

- `AZSRV-01-Restore`
- Restored OS disk
- Restore-specific network interface
- `sthybridstor`
- Remaining restore staging artifacts

The staging storage account contained an Azure Backup-created blob container used during the restore process:

`azsrv01restore-f8fb5238c092442c99ba3d60428883d6`

After the restored VM was no longer required, the staging storage account was deleted.

A restore-specific NIC remained in `rg-hybrid-lab` after the initial cleanup. It was identified during a final review of the resource group and manually deleted.

The original environment was preserved, including:

- `AZSRV-01`
- `rsv-hybrid-lab`
- Backup configuration and recovery point
- `vnet-hybrid-lab`
- `snet-servers`
- `nsg-servers`
- Azure Monitor and Log Analytics resources

## Lessons Learned

- Azure VM recovery depends on available compute quota in addition to having a valid recovery point.
- Recovery data can transfer successfully even if deployment of the replacement VM later fails.
- Azure Backup-generated ARM templates can be used to continue a recovery after the original deployment problem is resolved.
- The actual consistency type of a recovery point should be verified rather than assumed from the backup policy.
- Boot Diagnostics can confirm guest OS health when direct network access to a recovered VM is unavailable.
- Temporary restore resources should be reviewed and removed after recovery testing to prevent unnecessary Azure costs.
