
data "aws_iam_policy_document" "glue_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "glue_role" {
  name               = format("%s-glue-role", var.name)
  description        = format("%s: Assume role policy for AWS Glue", var.name)
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy_document.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "glue_role_att" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy_document" "glue_policy_document" {

  statement {
    sid = "ReadOnlyFromBucket"
    actions = [
      "s3:GetObject",
    ]
    effect = "Allow"
    resources = compact([
      "${module.parquet_logs.arn}/*",
    ])
  }
}

resource "aws_iam_policy" "glue_policy" {
  name        = format("%s-glue-policy", var.name)
  description = format("%s: Allow AWS Glue to read resources", var.name)
  policy      = data.aws_iam_policy_document.glue_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_policy_att" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}
