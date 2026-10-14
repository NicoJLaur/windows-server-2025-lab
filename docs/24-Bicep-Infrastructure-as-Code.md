# Infrastructure as Code with Azure Bicep

## Objective

Define Azure infrastructure using Bicep and deploy it through Azure Resource Manager (ARM). Create a separate virtual network, subnet, network security group (NSG), and storage account, then update the existing resources by changing the template and redeploying it. The project demonstrates basic Azure Infrastructure as Code authoring, ARM-based deployment, resource dependencies, parameters, and repeatable configuration changes.


## Environment

| Component | Configuration |
| --- | --- |
| Azure Subscription | Azure subscription 1 |
| Resource Group | `rg-hybrid-lab` (existing) |
| Region | West US 2 (`westus2`) |
| Authoring | Bicep source prepared in ChatGPT |
| Deployment Method | Azure portal > Deploy a custom template, using ARM JSON |
| Virtual Network | `vnet-bicep-lab` — `10.20.0.0/16` |
| Subnet | `snet-bicep` — `10.20.10.0/24` |
| Network Security Group | `nsg-bicep-lab` |
| Storage Account | `stbiceplab` plus a generated unique suffix |
| Storage Configuration | StorageV2, Standard_LRS, Hot tier |

## Design

The deployment used a separate `10.20.0.0/16` network so it would not overlap with the existing hybrid lab VNet (`10.10.0.0/16`). The subnet was associated with a newly created NSG. A general-purpose storage account was deployed in the same resource group.

```text
rg-hybrid-lab (West US 2)
|
+-- vnet-bicep-lab (10.20.0.0/16)
|   |
|   +-- snet-bicep (10.20.10.0/24)
|       |
|       +-- Associated NSG: nsg-bicep-lab
|
+-- nsg-bicep-lab
|
+-- stbiceplab<generated-suffix> (StorageV2 / Standard_LRS)
```

The subnet is a child configuration of the virtual network and therefore did not appear as a separate top-level resource on the deployment summary.

## Design Decisions

| Decision | Reason |
| --- | --- |
| Deploy to existing `rg-hybrid-lab` | Reuse the personal Azure lab without creating another resource group |
| Use a separate VNet address space | Avoid modifying or overlapping the existing lab network |
| Associate the NSG at the subnet | Apply network security controls to the entire test subnet |
| Leave `securityRules` empty | Use Azure's default NSG rules without adding unnecessary custom access |
| Use `uniqueString(resourceGroup().id)` for storage naming | Generate a stable, typically unique suffix across repeat deployments to the same resource group |
| Use Standard_LRS storage | Keep the test environment relatively low cost |
| Disable anonymous blob and Shared Key access | Favor authenticated access and avoid unnecessary exposure |
| Keep `publicNetworkAccess` enabled | Use the standard public storage endpoint; this does **not** make the endpoint private |
| Use the Azure portal for deployment | Avoid signing into a personal Azure account on a work computer or installing development tools on LABHOST |

## Template Development

Created a resource-group-scoped `main.bicep` template with parameters for location, resource names, and network address ranges. It defined the NSG, VNet/subnet association, and storage account, and exposed resource names and IDs as deployment outputs.

The subnet references `nsg.id`, allowing ARM to determine the dependency between the NSG and VNet automatically.

```bicep
networkSecurityGroup: {
  id: nsg.id
}
```

The storage account uses a deterministic name based on the resource group ID:

```bicep
var storageAccountName = 'stbiceplab${uniqueString(resourceGroup().id)}'
```

The storage template also specifies HTTPS-only traffic, minimum TLS 1.2, no anonymous blob access, and no Shared Key authorization. Public network access remains enabled; no private endpoint was deployed.

The project files are:

| File | Purpose |
| --- | --- |
| `main.bicep` | Editable Bicep infrastructure definition |
| `main.bicepparam` | Bicep deployment parameters |
| `azuredeploy.json` | ARM JSON template used by the Azure portal |
| `azuredeploy.parameters.json` | Equivalent ARM JSON parameter values |

**Deployment distinction:** The Bicep source was prepared for the project, but the actual deployments used the corresponding ARM JSON template through the Azure portal. A local Bicep CLI build or direct Bicep deployment was not performed.

## Initial Deployment

Opened **Azure portal > Deploy a custom template**, loaded `azuredeploy.json`, and selected **Azure subscription 1** and the existing **`rg-hybrid-lab`** resource group.

The deployment review showed West US 2, `vnet-bicep-lab`, `10.20.0.0/16`, `snet-bicep`, `10.20.10.0/24`, and `nsg-bicep-lab`. The **Location** parameter initially appeared as the ARM expression `[resourceGroup().location]` in the review interface, so it was explicitly set to `westus2` before deployment.

Selected **Create**. The deployment completed successfully on October 14, 2026. The deployment overview reported **OK** for the storage account, VNet, and NSG.

<img width="1594" height="543" alt="01-bicepdeploymentsuccess" src="https://github.com/user-attachments/assets/a6210c80-ce7e-47f7-aa17-413c9ea3087f" />


## Network Configuration

Opened `vnet-bicep-lab` in the Azure portal and inspected **Subnets > snet-bicep**. Confirmed that the subnet used `10.20.10.0/24` and had `nsg-bicep-lab` selected as its network security group.

The subnet settings were inspected without saving any manual changes.

<img width="1895" height="839" alt="02-bicepsubnetnsg" src="https://github.com/user-attachments/assets/292b4e88-fe96-46c3-96ce-daf6aeea8c94" />


## Updating Existing Infrastructure

Updated the Bicep template to accept a `resourceTags` object and applied that object to the VNet, NSG, and storage account definitions.

```bicep
@description('Tags applied to Project 24 resources')
param resourceTags object = {
  Environment: 'Lab'
  Project: '24-Azure-Bicep'
}
```

Each top-level resource definition received:

```bicep
tags: resourceTags
```

Prepared an updated ARM JSON template with the same resource names, address ranges, and configuration. Loaded the updated `azuredeploy.json` through **Deploy a custom template**, selected the same subscription and resource group, and confirmed that the review screen included the new `Resource Tags` parameter.

Redeployed the template to update the existing resources rather than creating another set of resources.

After deployment, opened **`vnet-bicep-lab` > Tags** and confirmed both tags were present:

| Tag | Value |
| --- | --- |
| `Environment` | `Lab` |
| `Project` | `24-Azure-Bicep` |

<img width="1906" height="468" alt="03-Bicepresourcetags" src="https://github.com/user-attachments/assets/83ee5954-4658-43b5-a1a5-0c16bf08c96d" />


Also checked `nsg-bicep-lab` and the deployed storage account; both had the same tags. This confirmed the template update applied across all three top-level resources.

## Lessons Learned

- **Bicep is declarative:** It defines the desired resource configuration instead of listing manual portal actions.
- **Parameters make templates reusable:** Names, regions, address ranges, and tags can be changed without rewriting resource definitions.
- **Resource references establish dependencies:** Referencing `nsg.id` connects the subnet to the NSG and informs deployment ordering.
- **Repeat deployments can update existing resources:** Keeping resource identities consistent allowed the template to apply tags to the existing VNet, NSG, and storage account.
- **Bicep and ARM JSON are related but distinct:** Bicep is the maintainable source format; the Azure portal deployment in this project used ARM JSON.
- **Security settings require precise interpretation:** Disabling anonymous blob access and Shared Key authorization does not disable the storage account's public network endpoint.
- **Infrastructure as Code improves reproducibility:** The files record the configuration needed to recreate the resources, reducing dependence on manual portal setup.
