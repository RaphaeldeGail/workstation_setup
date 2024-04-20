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
| [google_dns_managed_zone.working_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |
| [google_folder.workspace_folder](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder) | data source |
| [google_kms_crypto_key.symmetric_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| folder | The ID of the Workspace Folder. | `number` | n/a |
| region | Geographical *region* for Google Cloud Platform. | `string` | n/a |

## Outputs

| Name | Description |
|------|-------------|
| dns | The DNS zone boud to the workspace. |
| key\_id | The ID of the symmetric crypto key for the workspace. |
| workspace\_name | The name of the workspace |
<!-- END_TF_DOCS -->