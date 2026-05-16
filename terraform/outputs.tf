output "appflow_connector_profile_name" {
  description = "Name of the AppFlow ServiceNow connector profile."
  value       = var.create_connector_profile ? aws_appflow_connector_profile.servicenow[0].name : var.servicenow_connector_profile_name
}

output "appflow_name" {
  description = "Legacy single-flow output. Returns flow name only when exactly one table is enabled."
  value       = var.enable_appflow && length(aws_appflow_flow.servicenow_to_s3) == 1 ? values(aws_appflow_flow.servicenow_to_s3)[0].name : null
}

output "appflow_arn" {
  description = "Legacy single-flow output. Returns flow ARN only when exactly one table is enabled."
  value       = var.enable_appflow && length(aws_appflow_flow.servicenow_to_s3) == 1 ? values(aws_appflow_flow.servicenow_to_s3)[0].arn : null
}

output "appflow_flow_names" {
  description = "Map of table catalog key to AppFlow flow name."
  value       = var.enable_appflow ? { for key, flow in aws_appflow_flow.servicenow_to_s3 : key => flow.name } : {}
}

output "appflow_flow_arns" {
  description = "Map of table catalog key to AppFlow flow ARN."
  value       = var.enable_appflow ? { for key, flow in aws_appflow_flow.servicenow_to_s3 : key => flow.arn } : {}
}

output "servicenow_table_name" {
  description = "Legacy single-table output. Returns table name only when exactly one table is enabled."
  value       = length(local.effective_tables) == 1 ? values(local.effective_tables)[0].table_name : null
}

output "servicenow_table_names" {
  description = "Map of table catalog key to ServiceNow source table name."
  value       = { for key, cfg in local.effective_tables : key => cfg.table_name }
}

output "ingestion_bucket_name" {
  description = "Name of the S3 bucket receiving ServiceNow data."
  value       = aws_s3_bucket.servicenow_ingestion.bucket
}

output "ingestion_bucket_prefix" {
  description = "Legacy single-prefix output. Returns prefix only when exactly one table is enabled."
  value       = length(local.effective_tables) == 1 ? values(local.effective_tables)[0].s3_bucket_prefix : null
}

output "ingestion_bucket_prefixes" {
  description = "Map of table catalog key to S3 destination prefix."
  value       = { for key, cfg in local.effective_tables : key => cfg.s3_bucket_prefix }
}

output "appflow_trigger_type" {
  description = "Legacy single-trigger output. Returns trigger only when exactly one table is enabled."
  value       = var.enable_appflow && length(local.effective_tables) == 1 ? values(local.effective_tables)[0].appflow_trigger_type : null
}

output "appflow_table_catalog" {
  description = "Normalized table catalog used to create AppFlow flows."
  value       = local.effective_tables
}
