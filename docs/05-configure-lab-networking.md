\# Configure Lab Networking



\## Objective



Configure an isolated Hyper-V virtual network that allows virtual machines to communicate with one another and access the internet through the Hyper-V host while remaining separated from the physical home network. 



\## Environment



Host OS: Windows 11 Pro

Hypervisor: Hyper-V

Virtual Switch: LabSwitch(Internal)

Host Adapter: vEthernet(LabSwitch)

NAT Name: LabNAT

Lab Network: 192.168.50.0/24



\## Network Design



Instead of bridging the virtual machines directly to the home network, an Internal Hyper-V Switch was created. This allows all lab machines to communicate on a private network while the Windows host performs Network Address Translation (NAT) for internet access.



Benefits: Isolation from the physical network, safe environment for testing AD, Internet access for updates/software installs, and ability to add additional servers/clients without affecting existing network devices. 



\## Validation



The following items were verified:



\- Hyper-V Internal Virtual Switch (LabSwitch) created successfully.

\- Host virtual adapter configured with 192.168.50.1/24.

\- Windows NAT (LabNAT) configured successfully.

\- DC01 configured with a static IP address on the lab subnet.

\- ICMP connectivity to public IP addresses verified.

\- Traceroute confirmed outbound traffic was routed through the Hyper-V NAT gateway.



\### Outstanding Validation



DNS resolution and Windows Update testing will be completed from a non-corporate network to eliminate the effects of enterprise DNS and firewall policies. 



\## Learned



Hyper-V Internal Virtual Switches and Windows NAT can be combined to create an isolated lab environment with internet connectivity. Separating the virtual infrastructure from the home network provides a safer testing environment while still allowing operating system updates and software downloads.



This configuration also highlighted the value of validating each layer of network connectivity independently. Successful ICMP connectivity confirmed that routing and NAT were functioning correctly, while DNS testing revealed that application level connectivity can still be affected by environmental factors such as enterprise network policies.



\*Note\* Final DNS and Windows Update validation will be completed on a non-corporate network to avoid issues.



\## Evidence



\-screenshot/ 01-HyperV-VirtualSwitchManager.png

\-screenshot/ 02-DC01-LabSwitchConnection.png

\-screenshot/ 03-Host-LabSwitch.png

\-screenshot/ 04-LabNAT.png

\-screenshot/ 05-Traceroute-Iternet.png









&#x20;



