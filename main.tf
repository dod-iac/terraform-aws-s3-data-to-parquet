/*
 * # s3-data-to-parquet
 *
 * Convert S3 data to parquet format. To use this module a docker image must be uploaded to ECR that implements
 * code similar to [deptofdefense/s3-access-logs](https://github.com/deptofdefense/s3-access-logs). This docker
 * image should take the following environment variables:
 *
 * * SRC - The s3 bucket and key holding the code to convert to parquet.
 * * DST - The s3 bucket and key to place the parquet data. This bucket is created by the module.
 * * TRACKING_DST - The S3 bucket and key to place tracking information. It's ok to ignore this parameter.
 * * AWS_REGION - The AWS Region where this module is deployed.
 * * TIMEOUT - The timeout in seconds for the code.
 *
 * ## Usage
 *
 * ```hcl
 * module "s3-access-logs" {
 *   source = "dod-iac/s3-data-to-parquet/aws"
 *
 *   name = format("%s-%s-s3-access-logs", var.application, var.environment)
 *   image_sha = "sha256:c58e5fd04e0d118899e2732093c6fc3024d537a28cfd4a2956d1163d813a4444"
 *
 *   vpc_id      = module.vpc.vpc_id
 *   ecs_subnets = module.vpc.private_subnets
 *
 *   target_bucket = module.logs.aws_logs_bucket
 *   target_prefix_list = [
 *     "s3/bucket1",
 *     "s3/bucket2",
 *   ]
 *   logging_bucket = module.logs.aws_logs_bucket
 *
 *   tags = {
 *     Project     = var.project
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Querying S3 Access Logs with Athena
 *
 * A common use case is to query s3 access logs with the data created by this module. You can do this
 * using another modules [dod-iac/terraform-aws-s3-access-logs](https://github.com/dod-iac/terraform-aws-s3-access-logs).
 *
 * The usage example is:
 *
 * ```hcl
 * module "s3_access_logs_parquet" {
 *   source  = "dod-iac/s3-access-logs/aws"
 *   version = "~> 1.1.0"
 *
 *   project = format("%s-%s-s3-access-logs", var.application, var.environment)
 *
 *   target_bucket  = module.s3_access_logs_to_parquet.parquet_logs_bucket.id
 *   logging_bucket = module.logs.aws_logs_bucket
 *
 *   database_name = module.s3_access_logs_to_parquet.database_name
 *   table_name    = "s3"
 *
 *   bytes_scanned_cutoff_per_query = 4294967296 # 4GB
 *
 *   tags = {
 *     Project     = var.project
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 *
 * ## Developer Setup
 *
 * Install dependencies (macOS)
 *
 * ```shell
 * brew install pre-commit terraform terraform-docs
 * pre-commit install --install-hooks
 * ```
 *
 */


data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
