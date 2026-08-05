# Hyper-V Host Setup

## Objective

Prepare the Windows host machine as the foundation for a Windows Server 2025 homelab by enabling Hyper-V and configuring the virtual networking required to support future virtual machines. 

## Environment


**|Host|** Dell Latitude 5450

**|Name|** LABHOST

**|OS|** Windows 11 Pro

**|CPU|** Intel(R) Core(TM) Ultra 5 125U

**|RAM|** 16GB

**|Storage|** 477GB SSD

**|Hypervisor|** Hyper-V

<img width="362" height="360" alt="04-LABHOST-Specs" src="https://github.com/user-attachments/assets/dc8cfbbe-09e6-41ed-8b54-942a82b3f579" />

## Configuration

### Hyper-V

- [x] Installed Hyper-V Platform
- [x] Installed Hyper-V Management Tools
- [x] Restarted Windows


<img width="715" height="64" alt="07-Install-Hyper-V" src="https://github.com/user-attachments/assets/48cadc90-5ee1-44a3-9a60-bf0252296c45" />


### Virtual Switch
**|Name|** LabSwitch

**|Type|** Internal

**|Purpose|** Created to provide an isolated network for communication between the Windows host machine and lab server. Wanted to do it this way because typically enterprise enivroments use dedicated virtual networks with controlled routing rather than automatically managed networks. Building the lab this way provides some more experience with network design concepts that translate directly to Hyper-V, VMWare, and Azure Virtual networking. 


<img width="707" height="498" alt="02-labswitch-configuration" src="https://github.com/user-attachments/assets/295b2f25-1545-44b7-ac95-6323fb59da0d" />


## Validation

- [x] Verified LabSwitch in Hyper-V Virtual Switch Manager.

- [x] Verified vEthernet (LabSwitch) adapter.

<img width="959" height="215" alt="03-get-netadapter" src="https://github.com/user-attachments/assets/a63227f9-1c73-49e9-8fe7-9f36556405fc" />
<img width="676" height="477" alt="08-Host-LabSwitch-IP" src="https://github.com/user-attachments/assets/5ada6961-3667-4542-a0d7-f2f047e83b92" />

