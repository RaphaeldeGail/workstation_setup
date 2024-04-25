<!-- BEGIN_TF_DOCS -->
# Setup

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.7.5 |
| google | ~> 5.21.0 |
| random | ~> 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| google | 5.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| environment\_project | github.com/RaphaeldeGail/environment-project | main |
| workspace\_data | github.com/RaphaeldeGail/workspace-data | main |

## Resources

| Name | Type |
|------|------|
| [google_kms_crypto_key_iam_member.crypto_compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| admin\_account | n/a | `string` | n/a |
| admin\_project | The ID of the admin project. | `string` | n/a |
| billing\_account | The ID of the billing account used for the workspace. "Billing account User" permissions are required to execute module. | `string` | n/a |
| bucket | The name of the administrator bucket. | `string` | n/a |
| exec\_group | The email address of the Google group with usage permissions for the workstation. | `string` | n/a |
| name | The name of the workspace. | `string` | n/a |
| region | Geographical *region* for Google Cloud Platform. | `string` | n/a |
| workspace\_folder | The ID of the Workspace Folder. | `number` | n/a |

## Outputs

No outputs.
<!-- END_TF_DOCS -->