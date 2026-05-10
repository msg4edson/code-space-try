variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project tag used for AppFlow and S3 resources."
  type        = string
  default     = "servicenow-ingestion"
}

variable "environment" {
  description = "Deployment environment tag (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "servicenow_connector_profile_name" {
  description = "Existing Amazon AppFlow ServiceNow connector profile name in AWS account."
  type        = string
}

variable "servicenow_table_name" {
  description = "ServiceNow table to ingest. Default performs the initial full load of knowledge base rows."
  type        = string
  default     = "kb_knowledge"
}

variable "appflow_name" {
  description = "Name of the AppFlow flow."
  type        = string
  default     = "ServiceNow_to_S3_Daily_Sync"
}

variable "s3_bucket_name" {
  description = "Destination S3 bucket for ServiceNow ingestion output."
  type        = string
}

variable "s3_bucket_prefix" {
  description = "S3 prefix path inside the destination bucket."
  type        = string
  default     = "servicenow/kb_knowledge"
}

variable "appflow_trigger_type" {
  description = "AppFlow trigger type. Use OnDemand for first full load, Scheduled for recurring syncs."
  type        = string
  default     = "OnDemand"

  validation {
    condition     = contains(["OnDemand", "Scheduled"], var.appflow_trigger_type)
    error_message = "appflow_trigger_type must be either OnDemand or Scheduled."
  }
}

variable "schedule_expression" {
  description = "Schedule expression used only when appflow_trigger_type is Scheduled."
  type        = string
  default     = "rate(1 day)"
}
