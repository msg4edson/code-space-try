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

variable "create_connector_profile" {
  description = "Set to true to let Terraform create the AppFlow connector profile. Set to false to reference an existing profile by name (required when IAM/SCP restricts appflow:CreateConnectorProfile)."
  type        = bool
  default     = false
}

variable "enable_appflow" {
  description = "Set to true to manage AppFlow resources. Set to false in restricted accounts where SCP blocks appflow:* actions."
  type        = bool
  default     = false
}

variable "servicenow_connector_profile_name" {
  description = "Name for the Amazon AppFlow ServiceNow connector profile. Created by Terraform when create_connector_profile=true, otherwise must already exist."
  type        = string
  default     = "ServiceNow-Dev"
}

variable "servicenow_instance_url" {
  description = "ServiceNow instance URL (e.g. https://devXXXXX.service-now.com)."
  type        = string
}

variable "servicenow_username" {
  description = "ServiceNow Basic Auth username for AppFlow connector profile."
  type        = string
  sensitive   = true
}

variable "servicenow_password" {
  description = "ServiceNow Basic Auth password for AppFlow connector profile."
  type        = string
  sensitive   = true
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

variable "appflow_kms_arn" {
  description = "Optional customer-managed KMS key ARN used by AppFlow for data encryption. Set null to use AWS managed encryption."
  type        = string
  default     = null
}

variable "s3_bucket_name" {
  description = "Destination S3 bucket for ServiceNow ingestion output. Must be globally unique across AWS."
  type        = string

  validation {
    condition = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.s3_bucket_name)) && !contains(["yes", "no"], lower(var.s3_bucket_name))
    error_message = "s3_bucket_name must be a valid, globally unique bucket name and cannot be a confirmation word like 'yes' or 'no'."
  }
}

variable "s3_bucket_prefix" {
  description = "S3 prefix path inside the destination bucket."
  type        = string
  default     = "servicenow/kb_knowledge"
}

variable "manage_s3_bucket_security_resources" {
  description = "Set to true to manage S3 versioning, encryption, and public access block resources. Set to false when IAM/SCP blocks read APIs like GetBucketVersioning/GetBucketEncryption/GetPublicAccessBlock."
  type        = bool
  default     = false
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
  description = "Schedule expression used only when appflow_trigger_type is Scheduled. ServiceNow source supports at most one run per minute."
  type        = string
  default     = "rate(1 day)"
}

variable "appflow_tables" {
  description = "Optional table catalog for multi-table ingestion. When empty, legacy single-table variables are used."
  type = map(object({
    enabled             = optional(bool, true)
    table_name          = string
    flow_name           = optional(string)
    s3_bucket_prefix    = optional(string)
    appflow_trigger_type = optional(string)
    schedule_expression = optional(string)
    avg_rows_per_day    = optional(number)
    backfill_start_date = optional(string)
    priority            = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for cfg in values(var.appflow_tables) : (
        !can(cfg.appflow_trigger_type) || contains(["OnDemand", "Scheduled"], cfg.appflow_trigger_type)
      )
    ])
    error_message = "Each appflow_tables entry must set appflow_trigger_type to OnDemand or Scheduled when provided."
  }
}
