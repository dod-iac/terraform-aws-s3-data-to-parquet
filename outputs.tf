
output "parquet_logs_bucket" {
  value       = module.parquet_logs
  description = "The s3 bucket used to output parquet logs"
}

output "database_name" {
  value       = local.glue_database_name
  description = "The name of the Glue database"
}