<!-- BEGIN_TF_DOCS -->
# Setup

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.7.5 |
| google | ~> 5.21.0 |
| random | ~> 3.6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| environment\_project | github.com/RaphaeldeGail/environment-project | main |
| workspace\_data | github.com/RaphaeldeGail/workspace-data | main |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| billing\_account | The ID of the billing account used for the workspace. "Billing account User" permissions are required to execute module. | `string` | n/a |
| bucket | The name of the administrator bucket. | `string` | n/a |
| exec\_group | The email address of the Google group with usage permissions for the workstation. | `string` | n/a |
| folder | The ID of the Workspace Folder. | `number` | n/a |
| project | The ID of the admin project. | `string` | n/a |
| region | Geographical *region* for Google Cloud Platform. | `string` | n/a |
| user | An object declaring a user with access authorization to the workstation. | ```object({ ip = string name = string key = string })``` | n/a |
| workspace | The name of the workspace. | `string` | n/a |

## Outputs

No outputs.
<!-- END_TF_DOCS -->