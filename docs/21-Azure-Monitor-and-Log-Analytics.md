# 21 - Configure Azure Monitor and Log Analytics

## Objective

Configure centralized monitoring for the Azure Windows Server VM `AZSRV-01` using Azure Monitor, Azure Monitor Agent (AMA), a Data Collection Rule (DCR), and a Log Analytics workspace. Validate telemetry with KQL, configure CPU alerting with email notification, review ingestion costs, and troubleshoot the outbound connectivity issue that initially prevented AMA from downloading its DCR.

## Environment

| Component | Configuration |
| --- | --- |
| Azure subscription | Azure subscription 1 |
| Resource group | `rg-hybrid-lab` |
| Region | West US 2 |
| Virtual network | `vnet-hybrid-lab` |
| Server subnet | `snet-servers` (`10.10.10.0/24`) |
| Azure VM | `AZSRV-01` |
| Operating system | Windows Server 2025 Datacenter: Azure Edition |
| VM private IP | `10.10.10.4` |
| VM public IP | None |
| Log Analytics workspace | `law-lab` |
| Data Collection Rule | `dcr-azsrv01-monitoring` |
| Azure Monitor Agent | `AzureMonitorWindowsAgent` |
| NAT Gateway | `nat-hybrid-lab` |
| NAT public IP | `pip-nat-hybrid-lab` |
| Alert rule | `AZSRV-01-High-CPU` |
| Action group | `hybrid-lab-alerts` |

## Design

```text
AZSRV-01
    |
    | Azure Monitor Agent
    v
dcr-azsrv01-monitoring
    |
    +-- Windows Event Logs
    +-- Performance Counters
    |
    v
law-lab
    |
    +-- KQL queries
    +-- Monitoring validation
```

`AZSRV-01` remained private with no directly assigned public IP. Because `snet-servers` was configured as a private subnet, explicit outbound connectivity was added through Azure NAT Gateway.

```text
AZSRV-01 (10.10.10.4)
        |
        v
snet-servers
        |
        v
nat-hybrid-lab
        |
        v
pip-nat-hybrid-lab
        |
        v
Azure Monitor services
```

Alerting used the VM's platform CPU metric:

```text
AZSRV-01 Percentage CPU
        |
        v
AZSRV-01-High-CPU
        |
        v
hybrid-lab-alerts
        |
        v
Email notification
```

## Design Decisions

### Private Azure VM

`AZSRV-01` continued to operate without a directly assigned public IP. Required outbound connectivity was provided at the subnet level rather than exposing the VM directly to the Internet.

### Selective Telemetry Collection

The DCR collected selected event severity levels instead of every Windows event:

- Application: Critical, Error, Warning
- System: Critical, Error, Warning
- Security: Audit Failure

Informational, verbose, and successful security audit events were excluded. Performance counters were sampled every 60 seconds. This kept ingestion focused on useful lab telemetry.

### Explicit Outbound Connectivity

`snet-servers` had **Private subnet** enabled. This initially prevented `AZSRV-01` from reaching the Azure Monitor control endpoint over TCP 443. A NAT Gateway was added to provide explicit outbound connectivity while retaining private inbound access.

### Metric-Based CPU Alert

A metric alert monitored `Percentage CPU`. Its threshold was temporarily lowered to 1% for validation and restored to the intended 80% afterward.

## Log Analytics Workspace

Created `law-lab` in `rg-hybrid-lab`, West US 2, as the central destination for telemetry from `AZSRV-01`.

<img width="1588" height="420" alt="01-Log-Analytics-workspace" src="https://github.com/user-attachments/assets/9cbbcda8-36fd-412e-8794-fc0ea6222a66" />


## Data Collection Rule

<img width="751" height="450" alt="02-DCR-Data-Sources" src="https://github.com/user-attachments/assets/05f1c885-fab8-4357-a356-aafaa4dd61f9" />
<img width="1864" height="490" alt="03-DCR-Deployment-Complete" src="https://github.com/user-attachments/assets/4d296916-fa95-405a-966a-4865cf09aaba" />
<img width="1865" height="498" alt="04-DCR-Resource-Association" src="https://github.com/user-attachments/assets/a09d0351-b798-4df1-9816-7ef352460abf" />

Created `dcr-azsrv01-monitoring` with:

- Telemetry: Agent-based - Windows
- Region: West US 2
- Data Collection Endpoint: None
- Associated resource: `AZSRV-01`
- Destination: `law-lab`

### Windows Event Logs

| Log | Levels |
| --- | --- |
| Application | Critical, Error, Warning |
| Security | Audit Failure |
| System | Critical, Error, Warning |

### Performance Counters

Configured a 60-second sampling interval for processor, memory, logical disk, and network activity.

## Azure Monitor Agent Deployment

The DCR was created and associated, but the Azure Monitor Agent extension was not initially visible on `AZSRV-01`. The VM was started and its system-assigned managed identity was verified as enabled.

AMA was then installed explicitly from Azure Cloud Shell:

```bash
az vm extension set \
  --name AzureMonitorWindowsAgent \
  --publisher Microsoft.Azure.Monitor \
  --resource-group rg-hybrid-lab \
  --vm-name AZSRV-01 \
  --enable-auto-upgrade true
```

The deployment returned `Succeeded`. The portal later showed `AzureMonitorWindowsAgent` version `1.45.0.0`, provisioning succeeded, with automatic upgrade enabled.

<img width="1692" height="916" alt="05-Monitor-Agent-Installed" src="https://github.com/user-attachments/assets/ad67371b-9c34-4478-83f1-5f71bf00f7d2" />


## AMA and DCR Troubleshooting

The first heartbeat query returned no records:

```kusto
Heartbeat
| where Computer =~ "AZSRV-01"
| order by TimeGenerated desc
| take 20
```

Removing the computer filter also returned no records.

### AMA Runtime Inspection

Azure VM Run Command was used to inspect AMA. An initial check for `MonAgentCore` returned no process. A broader check showed:

- `MonAgentHost`
- `MonAgentLauncher`
- `MonAgentManager`

The AMA data store existed, but this expected DCR configuration file did not:

```text
C:\WindowsAzure\Resources\AMADataStore.AZSRV-01\mcs\mcsconfig.latest.xml
```

No downloaded DCR configuration was present under `configchunks`.

### IMDS Validation

Azure Instance Metadata Service connectivity was tested:

```powershell
$headers = @{ Metadata = "true" }

Invoke-RestMethod `
  -Headers $headers `
  -Method GET `
  -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" |
  Select-Object -ExpandProperty compute |
  Select-Object name, location, resourceGroupName, subscriptionId
```

The response correctly identified `AZSRV-01`, `westus2`, and `rg-hybrid-lab`, confirming IMDS connectivity.

### Azure Monitor Control Endpoint

Outbound connectivity was tested with:

```powershell
Test-NetConnection westus2.handler.control.monitor.azure.com -Port 443
```

Initial result:

```text
TcpTestSucceeded : False
```

This isolated the missing outbound network path as the reason AMA could not retrieve its DCR.

## NAT Gateway Implementation

A NAT Gateway was created and associated with the private server subnet.

| Setting | Value |
| --- | --- |
| NAT Gateway | `nat-hybrid-lab` |
| Resource group | `rg-hybrid-lab` |
| Region | West US 2 |
| SKU | Standard V2 |
| TCP idle timeout | 4 minutes |
| Public IP | `pip-nat-hybrid-lab` |
| Virtual network | `vnet-hybrid-lab` |
| Subnet | `snet-servers` |

After association, the TCP 443 test returned:

```text
TcpTestSucceeded : True
```

The VM retained no directly assigned public IP.

### DCR Download Validation

AMA configuration was checked again:

```powershell
$root = "C:\WindowsAzure\Resources\AMADataStore.AZSRV-01"

Test-Path "$root\mcs\mcsconfig.latest.xml"

if (Test-Path "$root\mcs\configchunks") {
    Get-ChildItem "$root\mcs\configchunks" |
        Select-Object Name, LastWriteTime
}
```

`mcsconfig.latest.xml` returned `True`, and a JSON configuration file appeared under `configchunks`, confirming that AMA had downloaded its DCR.

```text
Before NAT Gateway
AMA extension installed              Yes
AMA supporting processes running     Yes
System-assigned identity enabled     Yes
DCR associated                       Yes
IMDS reachable                       Yes
Azure Monitor TCP 443                No
DCR downloaded                       No
Heartbeat                            No

After NAT Gateway
Azure Monitor TCP 443                Yes
DCR downloaded                       Yes
Heartbeat                            Yes
```

## KQL and Monitoring Validation

### Heartbeat

```kusto
Heartbeat
| where Computer =~ "AZSRV-01"
| order by TimeGenerated desc
| take 20
```

Fresh records identified `AZSRV-01`, Azure Monitor Agent, Windows, and Microsoft Windows Server 2025 Datacenter Azure Edition.

<img width="1892" height="891" alt="06-Log-Analytics-Heartbeat" src="https://github.com/user-attachments/assets/39b970f7-f0a2-4afb-893d-02618ef58bf1" />


### Windows Event Logs

The initial `Event` query returned no results because the DCR only collected selected warning/error/critical events and Security audit failures.

A controlled Application Warning was generated:

```powershell
Write-EventLog `
    -LogName Application `
    -Source "Windows Error Reporting" `
    -EntryType Warning `
    -EventId 1001 `
    -Message "Azure Monitor lab validation test event."
```

It was queried with:

```kusto
Event
| where Computer =~ "AZSRV-01"
| where TimeGenerated > ago(30m)
| order by TimeGenerated desc
| take 50
```

The result showed the Windows Error Reporting source, Application log, `AZSRV-01`, Warning level, and the validation message.

<img width="1574" height="639" alt="07-Windows-Event-Logs-KQL" src="https://github.com/user-attachments/assets/d53fc775-1458-4b4b-9804-af55a1a1bdd4" />


### Performance Counters

```kusto
Perf
| where Computer =~ "AZSRV-01"
| order by TimeGenerated desc
| take 50
```

Fresh CPU, memory, disk, and network records were returned, including `% Processor Time`, `% Committed Bytes In Use`, available memory, `% Free Space`, and `Bytes Total/sec`.

<img width="1905" height="894" alt="08-Performance-Counters-KQL" src="https://github.com/user-attachments/assets/73974eda-0a3e-41a6-a81a-a18309d2cb4a" />


## Azure Monitor Alerting

Created the following metric alert:

| Setting | Value |
| --- | --- |
| Alert rule | `AZSRV-01-High-CPU` |
| Scope | `AZSRV-01` |
| Signal | Percentage CPU |
| Threshold type | Static |
| Aggregation | Average |
| Operator | Greater than |
| Final threshold | 80% |
| Evaluation frequency | 1 minute |
| Lookback period | 5 minutes |
| Severity | 2 - Warning |
| Action group | `hybrid-lab-alerts` |

### Action Group

Created `hybrid-lab-alerts` with one email notification. No automated remediation action, Function, Logic App, webhook, or runbook was configured.

### Alert Validation

The CPU threshold was temporarily lowered from 80% to 1%. Normal interactive activity did not reliably maintain the required average, so a sustained workload was generated on the VM.

The alert then entered **Fired**:

- Alert: `AZSRV-01-High-CPU`
- Severity: 2 - Warning
- Affected resource: `azsrv-01`
- Condition: Fired
- Fire time: September 30, 2026 at 3:44 PM

The intended 80% threshold was restored after testing.

<img width="1897" height="680" alt="09-Monitor-CPU-Alert-Fired" src="https://github.com/user-attachments/assets/3d89c0c3-9033-40e2-a36f-6a7d4c7033a4" />


## Cost Awareness

The `law-lab` workspace used the Pay-as-you-go pricing tier.

At validation time, the portal displayed:

| Item | Observed Value |
| --- | --- |
| Analytics Logs ingestion price | $2.30/GB |
| Basic Logs ingestion price | $0.50/GB |
| Monthly usage displayed | 0.00 GB |
| Estimated monthly ingestion cost | $0.00 |

The usage chart showed only tens of kilobytes of billable ingestion, primarily from `Perf` with a small amount from `Event`. The displayed `0.00 GB` reflected rounding at the very small lab volume, not inactive collection.

The CPU metric alert showed an estimated cost of approximately `$0.10 USD/month` during configuration.

The NAT Gateway introduced a separate networking cost and remains provisioned independently of whether `AZSRV-01` is running.

<img width="1880" height="652" alt="10-Log-Analytics-Cost-Example" src="https://github.com/user-attachments/assets/ab27c502-e48c-4a73-9f72-fd3a0c35fe4c" />



## Lessons Learned

- Successful VM extension provisioning does not by itself prove telemetry is reaching Log Analytics.
- AMA installation, DCR association, configuration download, network connectivity, and data ingestion are separate stages that can be validated independently.
- A private Azure subnet can require explicit outbound connectivity for workloads that need Azure service endpoints.
- NAT Gateway provided outbound connectivity while preserving the VM's private-only inbound design.
- `Test-NetConnection` isolated the TCP 443 connectivity failure.
- The AMA data store, `mcsconfig.latest.xml`, and `configchunks` helped verify whether the DCR reached the VM.
- Heartbeat validates basic AMA communication, while `Event` and `Perf` validate the configured DCR data sources.
- Selective event collection reduces unnecessary Log Analytics ingestion.
- Controlled test events and temporary alert thresholds provide repeatable monitoring validation.
- Azure platform metrics and guest operating-system telemetry are different monitoring layers.
- Monitoring design should include cost visibility, particularly when adding continuously provisioned networking resources such as NAT Gateway.
