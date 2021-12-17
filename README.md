<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# s3-data-to-parquet

Convert S3 data to parquet format. To use this module a docker image must be uploaded to ECR that implements
code similar to [deptofdefense/s3-access-logs](https://github.com/deptofdefense/s3-access-logs). This docker
image should take the following environment variables:

* SRC - The s3 bucket and key holding the code to convert to parquet.
* DST - The s3 bucket and key to place the parquet data. This bucket is created by the module.
* TRACKING\_DST - The S3 bucket and key to place tracking information. It's ok to ignore this parameter.
* AWS\_REGION - The AWS Region where this module is deployed.
* TIMEOUT - The timeout in seconds for the code.

## Usage

```hcl
module "s3-access-logs" {
  source = "dod-iac/s3-data-to-parquet/aws"

  name = format("%s-%s-s3-access-logs", var.application, var.environment)
  image_sha = "sha256:c58e5fd04e0d118899e2732093c6fc3024d537a28cfd4a2956d1163d813a4444"

  vpc_id      = module.vpc.vpc_id
  ecs_subnets = module.vpc.private_subnets

  target_bucket = module.logs.aws_logs_bucket
  target_prefix_list = [
    "s3/bucket1",
    "s3/bucket2",
  ]
  logging_bucket = module.logs.aws_logs_bucket

  tags = {
    Project     = var.project
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Querying S3 Access Logs with Athena

A common use case is to query s3 access logs with the data created by this module. You can do this
using another modules [dod-iac/terraform-aws-s3-access-logs](https://github.com/dod-iac/terraform-aws-s3-access-logs).

The usage example is:

```hcl
module "s3_access_logs_parquet" {
  source  = "dod-iac/s3-access-logs/aws"
  version = "~> 1.1.0"

  project = format("%s-%s-s3-access-logs", var.application, var.environment)

  target_bucket  = module.s3_access_logs_to_parquet.parquet_logs_bucket.id
  logging_bucket = module.logs.aws_logs_bucket

  database_name = module.s3_access_logs_to_parquet.database_name
  table_name    = "s3"

  bytes_scanned_cutoff_per_query = 4294967296 # 4GB

  tags = {
    Project     = var.project
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit terraform terraform-docs
pre-commit install --install-hooks
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_kms_key"></a> [cloudwatch\_kms\_key](#module\_cloudwatch\_kms\_key) | dod-iac/cloudwatch-kms-key/aws | ~> 1.0.0 |
| <a name="module_ecr_kms_key"></a> [ecr\_kms\_key](#module\_ecr\_kms\_key) | dod-iac/ecr-kms-key/aws | 1.0.1 |
| <a name="module_ecr_push"></a> [ecr\_push](#module\_ecr\_push) | dod-iac/ecr-iam-policy/aws | 1.0.0 |
| <a name="module_ecr_repo"></a> [ecr\_repo](#module\_ecr\_repo) | dod-iac/ecr-repo/aws | 1.1.1 |
| <a name="module_parquet_logs"></a> [parquet\_logs](#module\_parquet\_logs) | trussworks/s3-private-bucket/aws | ~> 3.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.run_command](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_task_definition.task_def](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_glue_catalog_database.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_crawler.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_glue_security_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_security_configuration) | resource |
| [aws_iam_policy.glue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudwatch_target_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.glue_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_target_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.glue_policy_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.glue_role_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch_target_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.events_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.glue_assume_role_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.glue_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_execution_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.target_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. | `number` | `731` | no |
| <a name="input_dst_prefix"></a> [dst\_prefix](#input\_dst\_prefix) | The prefix used for all ECS task output | `string` | `"s3"` | no |
| <a name="input_ecs_subnets"></a> [ecs\_subnets](#input\_ecs\_subnets) | The list of subnets to use for the ECS tasks. | `list(string)` | n/a | yes |
| <a name="input_ecs_task_cpu"></a> [ecs\_task\_cpu](#input\_ecs\_task\_cpu) | n/a | `number` | `1024` | no |
| <a name="input_ecs_task_mem"></a> [ecs\_task\_mem](#input\_ecs\_task\_mem) | n/a | `number` | `2048` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable ECS tasks to run. | `bool` | `true` | no |
| <a name="input_glue_crawler_exclusions"></a> [glue\_crawler\_exclusions](#input\_glue\_crawler\_exclusions) | Glue crawler exclusions. Check rules here: <https://docs.aws.amazon.com/glue/latest/dg/define-crawler.html#crawler-source-type> | `list(string)` | `[]` | no |
| <a name="input_image_sha"></a> [image\_sha](#input\_image\_sha) | The SHA256 of the image to use in the task. Not an image tag. | `string` | n/a | yes |
| <a name="input_keys"></a> [keys](#input\_keys) | The ARNs of the AWS KMS keys the policy is allowed to use.  Use ["*"] to allow all keys. | `list(string)` | `[]` | no |
| <a name="input_logging_bucket"></a> [logging\_bucket](#input\_logging\_bucket) | The AWS S3 logging bucket | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The namespace for the module | `string` | `"s3-data-to-parquet"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | The schedule to run the task on in AWS cron format. | `string` | `"cron(30 * * * ? *)"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the AWS resources | `map(string)` | `{}` | no |
| <a name="input_target_bucket"></a> [target\_bucket](#input\_target\_bucket) | The S3 bucket to target for data. | `string` | n/a | yes |
| <a name="input_target_prefix_list"></a> [target\_prefix\_list](#input\_target\_prefix\_list) | The list of S3 prefixes to target for data. | `list(string)` | <pre>[<br>  "s3"<br>]</pre> | no |
| <a name="input_task_timeout"></a> [task\_timeout](#input\_task\_timeout) | The timeout before the task ends. | `number` | `300` | no |
| <a name="input_tracking_dst_prefix"></a> [tracking\_dst\_prefix](#input\_tracking\_dst\_prefix) | The prefix used for all ECS task tracking | `string` | `"s3-tracking"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The vpc ID related to the subnets. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | The name of the Glue database |
| <a name="output_parquet_logs_bucket"></a> [parquet\_logs\_bucket](#output\_parquet\_logs\_bucket) | The s3 bucket used to output parquet logs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
