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
| google.env | 5.21.0 |
| random | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| workstation | ./modules/workstation | n/a |

## Resources

| Name | Type |
|------|------|
| [google_billing_project_info.billing_association](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_project_info) | resource |
| [google_compute_address.front_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.boot_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk_resource_policy_attachment.backup_policy_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk_resource_policy_attachment) | resource |
| [google_compute_firewall.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.workstation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_resource_policy.backup_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy) | resource |
| [google_compute_resource_policy.shutdown_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy) | resource |
| [google_compute_route.default_route](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_dns_record_set.frontend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_kms_crypto_key_iam_member.crypto_compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project.environment_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_project_iam_binding.instance_admins](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_service.service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.environment_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket_iam_member.shared_bucket_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_dns_managed_zone.working_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |
| [google_folder.workspace_folder](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder) | data source |
| [google_kms_crypto_key.symmetric_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| billing\_account | The ID of the billing account used for the workspace. "Billing account User" permissions are required to execute module. | `string` | n/a |
| bucket | The name of the administrator bucket. | `string` | n/a |
| dns\_zone | The DNS zone for the workspace. | `string` | n/a |
| exec\_group | The email address of the Google group with usage permissions for the workstation. | `string` | n/a |
| folder | The ID of the Workspace Folder. | `number` | n/a |
| principal\_set | The principal set. | `string` | n/a |
| project | The ID of the admin project. | `string` | n/a |
| region | Geographical *region* for Google Cloud Platform. | `string` | n/a |
| user | An object declaring a user with access authorization to the workstation. | ```object({ ip = string name = string key = string })``` | n/a |

## Outputs

No outputs.
<!-- END_TF_DOCS -->