\# Initial Server Configuration



\## Objective



Prepare Windows Server 2025 for deployment as the first Domain Controller by configuring its identity and network settings.



\## Configuration



Server: DC01 (Renamed)

OS: Windows Server 2025

IPv4 Address: 192.168.50.10 (Set static IP to ensure future reliable DNS and authentication services.)

Subnet Mask: 255.255.255.0

Default Gateway: None

Preferred DNS: 192.168.50.10 (Configured to use itself because it will host the DNS service after Active Directory is installed.)



\## Validation



\-Server renamed successfully

\-Static IP address applied successfully

\-Server restarted to apply IP and name

\-Network and name verified on Server Manager < Local Server



\## Learned



Configuring a static IP address before installing Active Directory helps ensure consistent network communication.



\## Evidence



\-screenshot/ 01-LocalServer-Before.png

\-screenshot/ 02-RenameServer.png

\-screenshot/ 03-StaticIP-Config.png

\-screenshot/ 04-LocalServer-After.png







