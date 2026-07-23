\# Hyper-V Host setup



\## Objective



Prepare my Windows host machine for virtualization by installing Hyper-V and creating an internal virtual switch



\## Environment/Specs



Host Computer:

\-Dell Latitude 5450

\-Windows 11 Pro

\-Intel(R) Core(TM) Ultra 5 125U

\-16GB RAM

\-500GB SSD



\## Configuration



\### Hyper-V

\-Installed Hyper-V Platform

\-Installed Hyper-V Management Tools



\### Virtual Switch

\-Name: LabSwitch

\-Type: Internal

\-Purpose: Provide a dedicated network for communication between the host machine and virtual machine.



\## Validation

\-Verified LabSwitch in Hyper-V Virtual Switch Manager.

\-Verified vEthernet (LabSwitch) adapter using Powershell command Get-NetAdapter.



\## Evidence



\-screenshot/ 01-hyperv-manager.png

\-screenshot/ 02-labswitch-configuration.png

\-screenshot/ 03-get-netadapter.png

