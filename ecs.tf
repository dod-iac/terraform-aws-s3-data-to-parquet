
#
# ECS
#

resource "aws_ecs_cluster" "ecs_cluster" {
  name               = format("app-%s", var.name)
  capacity_providers = ["FARGATE"]

  tags = var.tags
}

resource "aws_ecs_task_definition" "task_def" {
  count = length(var.target_prefix_list)

  family        = var.name
  network_mode  = "awsvpc"
  task_role_arn = aws_iam_role.task_role.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_mem
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${var.name}",
    "image": "${module.ecr_repo.repository_url}@${var.image_sha}",
    "cpu": ${var.ecs_task_cpu},
    "memory": ${var.ecs_task_mem},
    "essential": true,
    "portMappings": [],
    "environment": [
      {"name": "SRC", "value": "s3://${var.target_bucket}/${var.target_prefix_list[count.index]}"},
      {"name": "DST", "value": "s3://${module.parquet_logs.id}/${var.dst_prefix}"},
      {"name": "TRACKING_DST", "value": "s3://${module.parquet_logs.id}/${var.tracking_dst_prefix}"},
      {"name": "AWS_REGION", "value": "${data.aws_region.current.name}"},
      {"name": "TIMEOUT", "value": "${var.task_timeout}"}
    ],
    "mountPoints": [],
    "volumesFrom": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.main.name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION

  tags = var.tags
}
