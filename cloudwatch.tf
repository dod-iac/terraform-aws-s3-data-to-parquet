
#
# CloudWatch Log Group
#

module "cloudwatch_kms_key" {
  source  = "dod-iac/cloudwatch-kms-key/aws"
  version = "~> 1.0.0"

  name = format("alias/%s-cloudwatch-kms", var.name)
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "main" {
  name = var.name

  kms_key_id        = module.cloudwatch_kms_key.aws_kms_key_arn
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = var.tags
}
