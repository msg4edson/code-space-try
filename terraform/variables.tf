variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name for the Lambda function (also used to name related resources)."
  type        = string
  default     = "my-scheduled-lambda"
}

variable "environment" {
  description = "Deployment environment tag (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "schedule_expression" {
  description = "EventBridge schedule expression. Examples: rate(1 hour), cron(0 8 * * ? *)."
  type        = string
  default     = "rate(1 hour)"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch log entries."
  type        = number
  default     = 14
}

variable "lambda_timeout" {
  description = "Maximum execution time in seconds for the Lambda function."
  type        = number
  default     = 30
}

variable "lambda_memory_mb" {
  description = "Memory allocated to the Lambda function in MB."
  type        = number
  default     = 128
}

variable "lambda_env_vars" {
  description = "Map of environment variables to pass to the Lambda function."
  type        = map(string)
  default     = {}
}
