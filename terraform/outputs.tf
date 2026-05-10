output "appflow_connector_profile_name" {
  description = "Name of the AppFlow ServiceNow connector profile."
  value       = var.create_connector_profile ? aws_appflow_connector_profile.servicenow[0].name : var.servicenow_connector_profile_name
}

output "appflow_name" {
  description = "Name of the AppFlow flow."
  value       = aws_appflow_flow.servicenow_to_s3.name
}

output "appflow_arn" {
  description = "ARN of the AppFlow flow."
  value       = aws_appflow_flow.servicenow_to_s3.arn
}

output "servicenow_table_name" {
  description = "ServiceNow source table configured in the flow."
  value       = var.servicenow_table_name
}

output "ingestion_bucket_name" {
  description = "Name of the S3 bucket receiving ServiceNow data."
  value       = aws_s3_bucket.servicenow_ingestion.bucket
}

output "ingestion_bucket_prefix" {
  description = "Prefix path used for AppFlow output objects."
  value       = var.s3_bucket_prefix
}

output "appflow_trigger_type" {
  description = "Flow trigger mode currently configured."
  value       = var.appflow_trigger_type
}
