
#
# ECR
#

module "ecr_kms_key" {
  source = "dod-iac/ecr-kms-key/aws"

  name = format("alias/app-%s", var.name)

  tags = var.tags
}

module "ecr_repo" {
  source  = "dod-iac/ecr-repo/aws"
  version = "1.0.0"

  encryption_type = "KMS"

  kms_key_arn = module.ecr_kms_key.aws_kms_key_arn

  name = format("app-%s", var.name)

  tags = var.tags
}

module "ecr_push" {
  source  = "dod-iac/ecr-iam-policy/aws"
  version = "1.0.0"

  allow_write = true
  name        = format("app-%s-ecr-push", var.name)
  repos       = [module.ecr_repo.arn]
}
