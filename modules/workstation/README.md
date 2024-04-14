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
| [google_compute_instance.workstation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_dns_record_set.frontend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| disk | The disk attached to the workstation. | ```object({ name = string id = string zone = string })``` | n/a |
| dns\_zone | The DNS zone for the workspace. | ```object({ name = string dns = string })``` | n/a |
| environment | The name of the environment. | `string` | n/a |
| name | The name of the workstation. | `string` | n/a |
| nat\_ip | The IP address for the front NAT of the workstation. | `string` | n/a |
| policy | The ID of the resource policy for the workstation. | `string` | n/a |
| service\_account | The email for the service account attached to the workstation. | `string` | n/a |
| subnetwork | The ID of the subnetwork hosting the workstation. | `string` | n/a |
| user | An object declaring a user with access authorization to the workstation. | ```object({ ip = string name = string key = string })``` | n/a |

## Outputs

No outputs.
<!-- END_TF_DOCS -->