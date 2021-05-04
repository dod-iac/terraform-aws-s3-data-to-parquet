variable "name" {
  type        = string
  default     = "s3-data-to-parquet"
  description = "The namespace for the module"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the AWS resources"
  default     = {}
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  default     = 731
  description = "Specifies the number of days you want to retain log events in the specified log group."
}

# CPU/MEM values are here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html

variable "ecs_task_cpu" {
  type    = number
  default = 1024
}

variable "ecs_task_mem" {
  type    = number
  default = 2048
}

variable "image_sha" {
  type        = string
  description = "The SHA256 of the image to use in the task. Not an image tag."
}

variable "logging_bucket" {
  type        = string
  description = "The AWS S3 logging bucket"
}

variable "schedule_expression" {
  type        = string
  default     = "cron(30 * * * ? *)" # every half hour
  description = "The schedule to run the task on in AWS cron format."
}

variable "target_bucket" {
  type        = string
  description = "The S3 bucket to target for data."
}

variable "target_prefix_list" {
  type        = list(string)
  default     = ["s3"]
  description = "The list of S3 prefixes to target for data."
}

variable "vpc_id" {
  type        = string
  description = "The vpc ID related to the subnets."
}

variable "ecs_subnets" {
  type        = list(string)
  description = "The list of subnets to use for the ECS tasks."
}

variable "task_timeout" {
  type        = number
  description = "The timeout before the task ends."
  default     = 300
}

variable "dst_prefix" {
  type        = string
  description = "The prefix used for all ECS task output"
  default     = "s3"
}

variable "tracking_dst_prefix" {
  type        = string
  description = "The prefix used for all ECS task tracking"
  default     = "s3-tracking"
}

variable "glue_crawler_exclusions" {
  type        = list(string)
  description = "Glue crawler exclusions. Check rules here: <https://docs.aws.amazon.com/glue/latest/dg/define-crawler.html#crawler-source-type>"
  default     = []
}

variable "keys" {
  type        = list(string)
  description = "The ARNs of the AWS KMS keys the policy is allowed to use.  Use [\"*\"] to allow all keys."
  default     = []
}
