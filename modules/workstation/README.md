<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| google | ~> 5.21.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 5.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.front_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.boot_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk_resource_policy_attachment.backup_policy_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk_resource_policy_attachment) | resource |
| [google_compute_instance.workstation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_resource_policy.backup_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy) | resource |
| [google_dns_record_set.frontend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| dns\_zone | The DNS zone for the workspace. | ```object({ name = string dns = string })``` | n/a |
| environment | The name of the environment. | `string` | n/a |
| kms\_key | The ID for the KMS key to encrypt disk data. | `string` | n/a |
| name | The name of the workstation. | `string` | n/a |
| policy | The ID of the resource policy for the workstation. | `string` | n/a |
| service\_account | The email for the service account attached to the workstation. | `string` | n/a |
| subnetwork | The ID of the subnetwork hosting the workstation. | `string` | n/a |
| user | An object declaring a user with access authorization to the workstation. | ```object({ ip = string name = string key = string })``` | n/a |

## Outputs

No outputs.
<!-- END_TF_DOCS -->