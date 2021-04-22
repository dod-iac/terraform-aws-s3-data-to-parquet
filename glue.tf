
locals {
  glue_database_name = replace(format("%s-database", var.name), "-", "_")
}

resource "aws_glue_catalog_database" "main" {
  name        = local.glue_database_name
  description = format("The %s database", var.name)
  catalog_id  = data.aws_caller_identity.current.account_id
}

resource "aws_glue_security_configuration" "main" {
  name = format("%s-security-config", var.name)

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "DISABLED"
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "DISABLED"
    }

    s3_encryption {
      s3_encryption_mode = "SSE-S3"
    }
  }
}

resource "aws_glue_crawler" "main" {
  database_name = local.glue_database_name
  name          = format("%s-crawler", var.name)
  description   = format("The %s crawler", var.name)
  role          = aws_iam_role.glue_role.arn

  schedule = "cron(1 0/1 * * ? *)"

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      CrawlerOutput = {
        Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      }
      Version = 1
    }
  )

  s3_target {
    path = format("s3://%s/%s", module.parquet_logs.id, var.dst_prefix)

    exclusions = var.glue_crawler_exclusions
  }

  schema_change_policy {
    delete_behavior = "DEPRECATE_IN_DATABASE"
    update_behavior = "LOG" // Leave this as LOG or it will change the table schema
  }

  security_configuration = aws_glue_security_configuration.main.id

  tags = var.tags
}
