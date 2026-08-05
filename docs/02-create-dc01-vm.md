# Create DC01 Virtual Machine



## Objective


Create the first virtual machine in the Windows Server 2025 lab. This virtual machine will host Windows Server 2025 and later be promoted to the first Active Directory domain controller.


## Environment


|Hypervisor| Hyper-V |

|Host| Dell Latitude 5450('LABHOST')|

|Virtual Switch| LabSwitch (Connects the VM to an isolated network)|


## Virtual Machine Design

The virtual machine was configured to provide enough resources for Windows Server and Active Directory while preserving sufficient CPU, memory, and storage for the Hyper-V host and future lab virtual machines.

| Setting | Value | Reason |
|---------|-------|--------|
| Name | DC01 | Identifies the server as the first domain controller in the lab. |
| Generation | Generation 1 | Used after the Windows Server ISO failed to boot successfully in a Generation 2 VM. |
| Startup Memory | 4096 MB | Provides sufficient memory for Windows Server and Active Directory while leaving resources available for the host. |
| Dynamic Memory | Enabled | Allows Hyper-V to adjust memory usage based on demand. |
| Virtual Processors | 2 vCPU | Provides adequate processing capacity for a small Active Directory lab. |
| Virtual Disk | 80 GB dynamically expanding VHDX | Provides room for Windows Server, updates, logs, and future server roles without immediately consuming the full disk allocation. |


## Validation


The virtual machine configuration was validated by confirming:

- [X] 'DC01' appeared successfully in Hyper-V Manager
<img width="796" height="217" alt="image" src="https://github.com/user-attachments/assets/ea9bf433-6c94-496e-959a-821ad23bcb32" />

- [x] The assigned memory, processors, storage, and network adapter matched the planned configuration
<img width="959" height="502" alt="03-VirtualMemory" src="https://github.com/user-attachments/assets/b8b090ee-3d91-41f2-bee4-ff3471c930be" />

- [x] The virtual hard disk was created successfully
<img width="959" height="505" alt="02-Create-VHDX" src="https://github.com/user-attachments/assets/22897837-295a-4bd8-a2a3-64cdc7fb6407" />

- [x] The VM was connected to 'Lab Switch'
<img width="959" height="502" alt="04-VM-LabSwitchConnection" src="https://github.com/user-attachments/assets/0ac9509b-2c2d-4f4f-97bb-48c5cb3194b6" />


## Learned


-Hyper-V separates VM configuration files from virtual hard disks.

-Choosing the correct VM generation when making a new VM is important because it cannot be changed later.

-Generation 2 provides UEFI functionality.

