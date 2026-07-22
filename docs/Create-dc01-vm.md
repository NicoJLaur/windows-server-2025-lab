\# Create Domain Controller Virtual Machine



\## Objective



Create the first Windows Server 2025 Virtual Machine that will become the domain controller for the lab.



\## Configuration



Settings

\-Name: DC01

\-Generation 2

\-Memory: 4096MB

\-Processors: 2

\-Disk: 80GB

\-Network: LabSwitch

\-SecureBoot: Enabled



\## Environment



\-Generation 2 provides UEFI firmware and Secure Boot

\-4GB Memory should be enough

\-80GB provides sufficient storage for Windows Server and AD.

\-LabSwitch isolates the lab network while allowing communication between VMs.



\## Validation



\-VM (DC01) successfully created in Hyper-V Manager.

\-Configuration verified in DC01 settings menu.



\## Screenshots/Images



\-images/04-dc01-created.png

\-images/05-dc01-settings.png

\-images/06-hyperv-manager-with-dc01.png



\## Learned



\-Hyper-V separates VM configuration files from virtual hard disks.

\-Choosing the correct VM generation when making a new VM is important because it cannot be changed later.

