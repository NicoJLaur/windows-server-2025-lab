\# Install Windows Server 2025



\## Objective



Install Windows Server 2025 Evaluation within Hyper-V



\## Installation Media



OS: Windows Server 2025 Evaluation

Source: Microsoft Evaluation Center

Installation Method: Custom Installation

Installation Type: Desktop Experience



\## Installation Process



\-Started the VM from the attached ISO

\-Selected Windows Server 2025 Standard Evaluation (Desktop Experience)

\-Installed Windows onto the 80GB virtual hard disk.



\## Validation

Server booted successfully

Administrator account created

Server Manager launched successfully



\##Issues Encountered



\-Generation 2 UEFI Boot Failure, when starting/connecting to DC01 the ISO consistently failed to boot.

\-Error displayed: SCSI DVD(1,1) The boot loader failed.

\-When recreating DC01 with Generation 1 I failed to create the virtual hard disk because the previous virtual hard disk.

\-Error displayed: The system failed to create 'C:\\Hyper-V\\VMs\\DC01\\Virtual Hard Disks\\DC01.vhdx': The file exist (0x80070050).



\### Troubleshooting performed:

Verified the ISO integrity via PowerShell (Get-FileHash) and compared hashes.

Downloaded the ISO a second time to rule out file corruption.

Confirmed the ISO mounted successfully in Windows.

Verified the DVD drives was attached correctly and set to first in boot order in Hyper-V.

Tested with Secure Boot disabled (No Change)

Tested both MS Windows and MS UEFI Certificate Authority Secure Boot templates (No Change)

Successfully created a test VM with same configuration with Generation 1.

Deleted previous Virtual Hard Disk located in 'C:\\Hyper-V\\VMs\\DC01\\Virtual Hard Disks\\DC01.vhdx'.



\## Resolution



\-To continue with the lab and avoid blocking the Windows 2025 setup, The VM was recreated as Generation 1 and Windows installed successfully.



\## Evidence



\-screenshot/ 01-bootloader-fail.png

\-screenshot/ 02-Hash-Check.png

\-screenshot/ 03-bootorder-check.png

\-screenshot/ 04-SecureBoot-Template-Check.png

\-screenshot/ 05-Test-VM-created.png

\-screenshot/ 06-VirtualHardDisk-Error.png

\-screenshot/ 07-Deleted-vhdx.png

\-screenshot/ 08-Windows-Edition-Selection.png

\-screenshot/ 09-disk-selection.png

\-screenshot/ 10-Admin-Account-Creation.png

\-screenshot/ 11-First-Boot-Server-Manager.png











