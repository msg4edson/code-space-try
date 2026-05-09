resource "aws_lambda_function" "main" {
  function_name = var.function_name
  description   = "Scheduled Lambda function — ${var.environment}"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.12"
  handler = "handler.lambda_handler"

  role    = aws_iam_role.lambda_exec.arn
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_mb

  environment {
    variables = merge(
      { STAGE = var.environment },
      var.lambda_env_vars,
    )
  }

  # Ensure the log group exists before the function is created so that the
  # first invocation does not create an unmanaged log group.
  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy.lambda_logs,
  ]
}
