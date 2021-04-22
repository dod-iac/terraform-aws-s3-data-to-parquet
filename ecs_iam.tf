

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

### ECS Task Execution Role https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
# Allows ECS to Pull down the ECR Image and write Logs to CloudWatch

data "aws_iam_policy_document" "task_execution_role_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.main.arn,
      format("%s:log-stream:*", aws_cloudwatch_log_group.main.arn),
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [module.ecr_repo.arn]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = format("ecs-task-exec-role-%s", var.name)
  description        = format("Role allowing ECS tasks to execute %s task", var.name)
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  name   = format("%s-policy", aws_iam_role.task_execution_role.name)
  role   = aws_iam_role.task_execution_role.name
  policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
}

### ECS Task Role
# Allows ECS to start the task

data "aws_iam_policy_document" "task_role_policy_doc" {

  # Target bucket should be read only
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = flatten([
      [data.aws_s3_bucket.target_bucket.arn],
      [for target_prefix in var.target_prefix_list : format("%s/%s*", data.aws_s3_bucket.target_bucket.arn, target_prefix)]
    ])
  }

  # Parquet logs output, give full access
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      module.parquet_logs.arn,
      format("%s/*", module.parquet_logs.arn),
    ]
  }
}

resource "aws_iam_role" "task_role" {
  name               = format("ecs-task-role-%s", var.name)
  description        = format("Role allowing container definition to execute %s task", var.name)
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "task_role_policy" {
  name   = format("%s-policy", aws_iam_role.task_role.name)
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role_policy_doc.json
}
