output "function_name" {
  description = "Name of the deployed Lambda function."
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "ARN of the deployed Lambda function."
  value       = aws_lambda_function.main.arn
}

output "function_invoke_arn" {
  description = "Invocation ARN (useful for API Gateway integrations)."
  value       = aws_lambda_function.main.invoke_arn
}

output "log_group_name" {
  description = "CloudWatch log group name for the Lambda function."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "schedule_expression" {
  description = "EventBridge schedule expression in use."
  value       = aws_cloudwatch_event_rule.schedule.schedule_expression
}
