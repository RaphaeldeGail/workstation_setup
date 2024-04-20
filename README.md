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
| admin\_data | ./modules/admin_data | n/a |
| environment\_project | ./modules/environment_project | n/a |
| workstation | github.com/RaphaeldeGail/legendary-workstation | feature%2Fmanage-workstation |

## Resources

| Name | Type |
|------|------|
| [google_dns_record_set.frontend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_storage_bucket_iam_member.shared_bucket_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| billing\_account | The ID of the billing account used for the workspace. "Billing account User" permissions are required to execute module. | `string` | n/a |
| bucket | The name of the administrator bucket. | `string` | n/a |
| dns\_zone | The DNS zone for the workspace. | `string` | n/a |
| exec\_group | The email address of the Google group with usage permissions for the workstation. | `string` | n/a |
| folder | The ID of the Workspace Folder. | `number` | n/a |
| project | The ID of the admin project. | `string` | n/a |
| region | Geographical *region* for Google Cloud Platform. | `string` | n/a |
| user | An object declaring a user with access authorization to the workstation. | ```object({ ip = string name = string key = string })``` | n/a |

## Outputs

No outputs.
<!-- END_TF_DOCS -->