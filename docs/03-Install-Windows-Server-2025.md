# Install Windows Server 2025



## Objective



Install Windows Server 2025 Evaluation on the 'DC01' virtual machine and verify that the OS boots successfully, allowing the server to be configured for future infrastructure plans.



## Installation Media


| Component | Value |
|-----------|-------|
| Operating System | Windows Server 2025 Standard Evaluation |
| Source | Microsoft Evaluation Center |
| Installation Type | Desktop Experience |
| Installation Method | Custom Installation |
| Target VM | DC01 |



## Installation Process

Performed using the Microsoft Evaluation ISO attached to the virtual hard disk in Hyper-V. The following steps were completed:

- [x] Booted the virtual machine from the Windows Server 2025 installation ISO
- [x] Performed Custom installation and selected Windows Server 2025 Standard Evaluation (Desktop Experience)


<img width="636" height="499" alt="08-Windows-Edition-Selection" src="https://github.com/user-attachments/assets/ee53bacd-2cb2-4294-9feb-6e5ab3878fbf" />



- [x] Installed Windows Server to the 80GB virtual hard disk


<img width="638" height="504" alt="09-disk-selection" src="https://github.com/user-attachments/assets/afd96074-0ff7-45de-8ed3-92f69d4917a9" />



- [x] Created the local admin account


<img width="639" height="502" alt="10-Admin-Account-Creation" src="https://github.com/user-attachments/assets/c9849c15-6b69-421b-8a00-c3b589b06198" />



## Issues Encountered


Generation 2 UEFI Boot Failure, when starting/connecting to DC01 the ISO consistently failed to boot.

**-Error displayed:** SCSI DVD(1,1) The boot loader failed.

<img width="959" height="503" alt="01-bootloader-fail" src="https://github.com/user-attachments/assets/1f48a53b-55dc-4e94-b226-4d93c225463f" />



When recreating DC01 with Generation 1 I failed to create the virtual hard disk because the previous virtual hard disk.

**-Error displayed:** The system failed to create 'C:\\Hyper-V\\VMs\\DC01\\Virtual Hard Disks\\DC01.vhdx': The file exist (0x80070050).


<img width="959" height="505" alt="06-VirtualHardDisk-Error" src="https://github.com/user-attachments/assets/90434611-1ab3-4052-8e57-25190a3cea6c" />



### Troubleshooting performed:

Verified the ISO integrity via PowerShell (Get-FileHash) and compared hashes.


<img width="959" height="227" alt="02-Hash-Check" src="https://github.com/user-attachments/assets/4d4e4678-c85d-4347-aea0-45968e4c88b0" />



Downloaded the ISO a second time to rule out file corruption.

Confirmed the ISO mounted successfully in Windows.

Verified the DVD drives was attached correctly and set to first in boot order in Hyper-V.


<img width="959" height="506" alt="03-bootorder-check" src="https://github.com/user-attachments/assets/095608cc-524d-485d-8511-964126265748" />




Tested with Secure Boot disabled (No Change)


<img width="959" height="503" alt="04-SecureBoot-Template-Check" src="https://github.com/user-attachments/assets/13b5543c-0609-4f1b-8659-3921f388d1d2" />



Tested both MS Windows and MS UEFI Certificate Authority Secure Boot templates (No Change)

Successfully created a test VM with same configuration with Generation 1.


<img width="959" height="503" alt="05-Test-VM-created" src="https://github.com/user-attachments/assets/9f679bee-aa25-49e3-812d-efe1488e8bd2" />



Deleted previous Virtual Hard Disk located in 'C:\\Hyper-V\\VMs\\DC01\\Virtual Hard Disks\\DC01.vhdx'.


<img width="959" height="502" alt="07-Deleted-vhdx" src="https://github.com/user-attachments/assets/6ebbf646-1fc5-4f00-bb11-a0b8dec05adb" />



In order to continue with the lab and avoid blocking the Windows 2025 setup, The VM was recreated as Generation 1 and Windows installed successfully.

## Validation


- [x] Windows Server booted successfully

- [x] Administrator account created and accessible

- [x] Server Manager launched successfully


<img width="958" height="483" alt="11-First-Boot-Server-Manager" src="https://github.com/user-attachments/assets/b54815e2-967d-4a12-b2c8-0dfdd5754391" />


- [x] No installation errors were present after the first boot
