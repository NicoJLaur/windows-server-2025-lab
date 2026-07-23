\# Create Domain Controller Virtual Machine



\## Objective



Create the first Windows Server 2025 Virtual Machine that will later be promoted to the first domain controller for the lab.



\## Environment



\-Hypervisor: Hyper-V

\-Host: Dell Latitude 5450(LABHOST)

\-VM Name: DC01 (Follows Microsoft's common Domain Controller naming convention.)

\-Virtual Switch: LabSwitch (Connects the VM to an isolated network)

\-Processors: 2 vCPU (Hopefully enough for my small lab)

\-Memory: 4GB (Hopefully enough allocated from a 16GB host machine)

\-Disk: 80GB (Provides adequate storage)



\## Validation



\-VM (DC01) successfully created in Hyper-V Manager.

\-Configuration verified in DC01 settings menu.



\## Evidence



\-screenshot/ 04-dc01-created.png

\-screenshot/ 05-dc01-settings.png

\-screenshot/ 06-hyperv-manager-with-dc01.png



\## Learned



\-Hyper-V separates VM configuration files from virtual hard disks.

\-Choosing the correct VM generation when making a new VM is important because it cannot be changed later.

\-Generation 2 provides UEFI functionality.

