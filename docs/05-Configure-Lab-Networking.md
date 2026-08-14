# Configure Lab Networking



## Objective



Configure the networking infrastructure required to support communication between the Hyper-V host and all virtual machines while providing controlled internet access through Network Address Translation (NAT).


## Environment



| Component | Configuration |
|-----------|---------------|
| Host OS | Windows 11 Pro |
| Hypervisor | Hyper-V |
| Virtual Switch | LabSwitch (Internal) |
| Host Adapter | vEthernet (LabSwitch) |
| NAT Network | LabNAT |
| Lab Network | 192.168.50.0/24 |



## Network Design


<img width="332" height="669" alt="Networkdiagramsofar" src="https://github.com/user-attachments/assets/423bf116-2b59-4608-a967-e796a3800588" />




Instead of bridging the virtual machines directly to the home network, an Internal Hyper-V Switch was created. This allows all lab machines to communicate on a private network while the Windows host performs Network Address Translation (NAT) for internet access.



Benefits: Isolation from the physical network, safe environment for testing AD, Internet access for updates/software installs, and ability to add additional servers/clients without affecting existing network devices. 



## Validation



The following items were verified:



- [x] Hyper-V Internal Virtual Switch ('LabSwitch') created successfully.



<img width="676" height="477" alt="03-Host-LabSwitch-IP" src="https://github.com/user-attachments/assets/b4cf1c16-442a-4c93-9b02-448b71bfa7bd" />

<img width="374" height="152" alt="02-DC01-LabSwitchConnection" src="https://github.com/user-attachments/assets/a04b691b-ddbf-48d4-bead-a73a96de0ef0" />

- [x] Host virtual adapter configured with 192.168.50.1/24.

- [x] Windows NAT (LabNAT) created successfully.
<img width="842" height="502" alt="04-LabNAT" src="https://github.com/user-attachments/assets/98947b50-2a35-4e32-9c55-a650bb76a50f" />



- [x] Outbound ICMP connectivity verified.

- [x] Traceroute confirmed outbound traffic was routed through the Hyper-V NAT gateway.


<img width="956" height="412" alt="05-Traceroute-Internet" src="https://github.com/user-attachments/assets/18f43dda-6726-41eb-a2fa-657da3426251" />




### Outstanding Validation



DNS resolution and Windows Update testing will be completed from a non-corporate network to eliminate the effects of enterprise DNS and firewall policies. 



## Learned



Hyper-V Internal Virtual Switches and Windows NAT can be combined to create an isolated lab environment with internet connectivity. Separating the virtual infrastructure from the home network provides a safer testing environment while still allowing operating system updates and software downloads.



This configuration also highlighted the value of validating each layer of network connectivity independently. Successful ICMP connectivity confirmed that routing and NAT were functioning correctly, while DNS testing revealed that application level connectivity can still be affected by environmental factors such as enterprise network policies.



\*Note\* Final DNS and Windows Update validation will be completed on a non-corporate network to avoid issues.




