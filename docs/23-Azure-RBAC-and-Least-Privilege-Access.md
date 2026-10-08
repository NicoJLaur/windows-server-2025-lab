# Project 23 - Azure RBAC and Least-Privilege Access Control

## Objective

Implement role-based access control (RBAC) for the existing Azure hybrid lab using Microsoft Entra security groups, built-in Azure roles, and a custom role limited to virtual machine operations. Test access with separate user accounts to confirm that permissions matched each account's intended responsibilities.

## Environment

| Component | Configuration |
| --- | --- |
| Subscription | Azure subscription 1 |
| Resource Group | `rg-hybrid-lab` |
| Test Virtual Machine | `AZSRV-01` |
| Identity Directory | Microsoft Entra ID (Default Directory) |
| Administrator Group | `AZ-Lab-Admins` |
| Reader Group | `AZ-Lab-Readers` |
| VM Operator Group | `Lab-VM-Operators` |
| Test Accounts | `lab-admin`, `lab-reader`, `lab-vmoperator` |
| Custom Azure Role | `Lab VM Operator` |

## Access Control Design

Access was assigned to security groups rather than directly to individual users. Each group received a role at the `rg-hybrid-lab` resource-group scope, allowing the test accounts to inherit permissions through group membership.

```text
rg-hybrid-lab
    |
    +-- AZ-Lab-Admins -------- Contributor
    |       |
    |       +-- lab-admin
    |
    +-- AZ-Lab-Readers ------- Reader
    |       |
    |       +-- lab-reader
    |
    +-- Lab-VM-Operators ----- Lab VM Operator (custom)
            |
            +-- lab-vmoperator
```

The resource-group scope was chosen to keep these lab permissions limited to the existing project resources instead of granting access across the entire subscription. The custom role further restricted the operator to a small set of VM actions rather than general resource administration.

## Security Groups and Built-In Role Assignments

Created two cloud-based Microsoft Entra security groups, `AZ-Lab-Admins` and `AZ-Lab-Readers`, using assigned membership.

<img width="1905" height="441" alt="01-entragroups" src="https://github.com/user-attachments/assets/a1a30d4b-3447-4ea6-9a43-7f5f4fc5e0e7" />


In `rg-hybrid-lab` > **Access control (IAM)**, assigned the built-in **Contributor** role to `AZ-Lab-Admins` and the built-in **Reader** role to `AZ-Lab-Readers`.

| Group | Azure Role | Scope | Intended Access |
| --- | --- | --- | --- |
| `AZ-Lab-Admins` | Contributor | `rg-hybrid-lab` | Manage resources without granting access to assign Azure RBAC roles |
| `AZ-Lab-Readers` | Reader | `rg-hybrid-lab` | View resources without changing their configuration |

The IAM role-assignment view confirmed both group assignments at the resource-group scope.

<img width="1574" height="698" alt="02-readercontributor" src="https://github.com/user-attachments/assets/404af2ff-95d7-41ad-8b84-e78f7303a9d7" />


## Test Accounts and Built-In Role Behavior

Created separate cloud-only test accounts named `lab-admin` and `lab-reader`, then placed each account in its corresponding security group. These accounts were used to test the permissions independently of the original subscription administrator.

<img width="1434" height="540" alt="03-userslist" src="https://github.com/user-attachments/assets/a101aeb4-a3f8-4a99-9d05-c4fef402d0e4" />


While signed in as `lab-reader`, attempted to assign a resource tag. Azure returned **Failed to assign tags**, consistent with the Reader role's inability to modify resources.

<img width="402" height="171" alt="04-labreaderdenied" src="https://github.com/user-attachments/assets/080b0607-4c20-4284-97d1-1aade2d6c7a6" />


Signed in as `lab-admin` and performed the same type of tag change successfully. Azure displayed a **Successfully assigned the tag** notification, demonstrating the difference between Reader and Contributor access.

<img width="442" height="141" alt="05-labadminsuccess" src="https://github.com/user-attachments/assets/0f85cf4c-9e1d-49da-90ff-1cfb16deb58b" />


The administrator account's effective access was also checked in IAM. It inherited **Contributor** through the `AZ-Lab-Admins` group rather than requiring a direct user-level role assignment.

## Custom Role: Lab VM Operator

Created a custom Azure RBAC role named **Lab VM Operator** to permit basic VM operations without providing general Contributor access. The role was created from scratch and made assignable at the `rg-hybrid-lab` resource-group scope.

The role definition included these eight control-plane actions:

| Permission | Purpose |
| --- | --- |
| `Microsoft.Compute/virtualMachines/read` | View VM properties |
| `Microsoft.Compute/virtualMachines/start/action` | Start a VM |
| `Microsoft.Compute/virtualMachines/restart/action` | Restart a VM |
| `Microsoft.Compute/virtualMachines/deallocate/action` | Stop and deallocate a VM |
| `Microsoft.Resources/subscriptions/read` | Read subscription information |
| `Microsoft.Resources/subscriptions/resourceGroups/read` | Read resource-group information |
| `Microsoft.Network/networkInterfaces/read` | View associated NIC properties |
| `Microsoft.Compute/disks/read` | View associated disk properties |

The role did **not** include `Microsoft.Compute/virtualMachines/delete` or permissions to create or modify arbitrary Azure resources. No data-plane permissions were configured.

<img width="1036" height="590" alt="06-rolepermissions" src="https://github.com/user-attachments/assets/a3146acc-2b04-4734-ab29-c8e3a0a6eb67" />


## Custom Role Assignment and VM Operations

Created the `Lab-VM-Operators` security group and assigned the custom **Lab VM Operator** role to it at the `rg-hybrid-lab` scope. The `lab-vmoperator` test account inherited the role through group membership.

The group's **Azure role assignments** page showed `Lab VM Operator` assigned to `Lab-VM-Operators` for the resource group. An administrator-side access check also showed that `lab-vmoperator` inherited this role through the group, with no additional role assignments shown at that scope.

Signed in as `lab-vmoperator` and successfully **started** and **stopped/deallocated** `AZSRV-01`. These operations confirmed that the custom role allowed the intended VM management actions without assigning the broader Contributor role.


## Lessons Learned

- Assigning Azure RBAC roles to Entra security groups simplified access management and allowed users to inherit permissions through membership.
- Azure RBAC scope matters: assigning roles at the resource-group level limited the lab's delegated permissions to `rg-hybrid-lab`.
- Reader and Contributor produced different results when attempting the same tag modification.
- Custom roles can grant narrowly defined VM operations without granting full resource-management access.
- Portal buttons and confirmation dialogs do not necessarily prove that the signed-in identity is authorized to complete an operation.
- Verifying a role definition and successfully exercising allowed operations provided useful evidence without risking deletion of the existing VM.
- Azure RBAC roles for resource management are distinct from Microsoft Entra directory administrative roles.
