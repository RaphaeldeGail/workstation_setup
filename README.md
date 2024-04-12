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
| random | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_billing_project_info.billing_association](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_project_info) | resource |
| [google_compute_disk.boot_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_kms_crypto_key_iam_member.crypto_compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project.environment_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_project_iam_binding.environment_editors](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_service.service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.environment_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.workld_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_folder.workspace_folder](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder) | data source |
| [google_kms_crypto_key.symmetric_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| billing\_account | The ID of the billing account used for the workspace. "Billing account User" permissions are required to execute module. | `string` | n/a |
| exec\_group | The email address of the Google group with exectuive usage for the project. | `string` | n/a |
| folder | The ID of the Workspace Folder. | `number` | n/a |
| principal\_set | The principal set. | `string` | n/a |
| project | The ID of the admin project. | `string` | n/a |
| region | Geographical *region* for Google Cloud Platform. | `string` | n/a |

## Outputs

No outputs.
<!-- END_TF_DOCS -->