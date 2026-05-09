# Scheduled AWS Lambda Scaffold (Python + Terraform)

This repository contains a starter setup for deploying a Python AWS Lambda function using Terraform.

The scaffold includes:

- Lambda function code in Python
- EventBridge scheduled trigger
- Least-privilege IAM execution role
- CloudWatch log group with retention policy
- Makefile commands for common workflows

## Project Structure

```text
.
├── lambda/
│   ├── requirements.txt
│   └── src/
│       └── handler.py
├── terraform/
│   ├── cloudwatch.tf
│   ├── eventbridge.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── Makefile
└── README.md
```

## How It Works

1. Terraform packages `lambda/src/` into `lambda/lambda.zip` using the `archive_file` data source.
2. Terraform creates:
	 - `aws_lambda_function`
	 - `aws_iam_role` + logging policy
	 - `aws_cloudwatch_log_group`
	 - `aws_cloudwatch_event_rule` (schedule)
	 - `aws_cloudwatch_event_target`
	 - `aws_lambda_permission` for EventBridge invoke
3. EventBridge triggers the Lambda function using the configured schedule expression.

## Prerequisites

- Terraform >= 1.7
- AWS CLI configured with credentials and region access
- Python 3.x + `pip`
- GNU Make

## Quick Start

From the repository root:

```bash
make init
make plan
make deploy
```

After deploy:

```bash
make invoke
make logs
```

To destroy all resources:

```bash
make destroy
```

## Available Make Targets

- `make help`      : Show available targets
- `make deps`      : Install Python dependencies into `lambda/src/`
- `make init`      : Run `terraform init` inside `terraform/`
- `make validate`  : Validate Terraform configuration
- `make plan`      : Preview infrastructure changes
- `make apply`     : Apply infrastructure changes
- `make deploy`    : Install dependencies and apply changes
- `make invoke`    : Invoke Lambda manually via AWS CLI
- `make logs`      : Tail Lambda CloudWatch logs
- `make destroy`   : Destroy managed infrastructure

## Configuration

Main variables are defined in `terraform/variables.tf`.

Common values to customize:

- `aws_region`
- `function_name`
- `environment`
- `schedule_expression` (for example: `rate(1 hour)` or `cron(0 8 * * ? *)`)
- `log_retention_days`
- `lambda_timeout`
- `lambda_memory_mb`
- `lambda_env_vars`

### Example `terraform.tfvars`

Create `terraform/terraform.tfvars`:

```hcl
aws_region          = "us-east-1"
function_name       = "daily-report-lambda"
environment         = "dev"
schedule_expression = "cron(0 8 * * ? *)"
log_retention_days  = 14
lambda_timeout      = 30
lambda_memory_mb    = 128

lambda_env_vars = {
	STAGE = "dev"
	TEAM  = "platform"
}
```

## Lambda Code

Edit `lambda/src/handler.py` to implement your business logic.

The current handler:

- logs the incoming event
- reads `STAGE` from environment variables
- returns a simple JSON result

## Notes

- Terraform state is local in this scaffold.
- This setup is intended as a starter template for development and learning.
- For production, consider:
	- remote backend (S3 + DynamoDB lock)
	- separate workspaces/environments
	- stricter IAM policies per use-case
	- CI/CD pipeline for plan/apply controls