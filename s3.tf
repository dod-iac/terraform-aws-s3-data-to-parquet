
data "aws_s3_bucket" "target_bucket" {
  bucket = var.target_bucket
}

module "parquet_logs" {
  source  = "trussworks/s3-private-bucket/aws"
  version = "~> 3.5.0"

  bucket = var.name
  tags   = var.tags

  enable_analytics        = false
  enable_bucket_inventory = false

  use_account_alias_prefix = false

  logging_bucket = var.logging_bucket
}
