TERRAFORM_DIR := terraform
LAMBDA_SRC    := lambda/src
LAMBDA_ZIP    := lambda/lambda.zip

.PHONY: help zip deps init validate plan apply destroy deploy logs invoke

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Lambda packaging
# ---------------------------------------------------------------------------

deps: ## Install Python dependencies into lambda/src/
	pip install -r lambda/requirements.txt -t $(LAMBDA_SRC) --upgrade --quiet

zip: ## Build the Lambda deployment zip (delegates to Terraform archive_file)
	@echo "Zip is managed by Terraform's archive_file data source."
	@echo "Run 'make plan' or 'make apply' to trigger a rebuild when sources change."

# ---------------------------------------------------------------------------
# Terraform lifecycle
# ---------------------------------------------------------------------------

init: ## Initialise Terraform (download providers)
	cd $(TERRAFORM_DIR) && terraform init

validate: ## Validate Terraform configuration
	cd $(TERRAFORM_DIR) && terraform validate

plan: ## Preview infrastructure changes
	cd $(TERRAFORM_DIR) && terraform plan

apply: ## Apply infrastructure changes
	cd $(TERRAFORM_DIR) && terraform apply

destroy: ## Destroy all managed infrastructure
	cd $(TERRAFORM_DIR) && terraform destroy

deploy: deps apply ## Install deps + apply (full deploy)

# ---------------------------------------------------------------------------
# Operational helpers (require AWS CLI + correct AWS credentials)
# ---------------------------------------------------------------------------

logs: ## Tail the last 50 CloudWatch log events
	@FUNCTION=$$(cd $(TERRAFORM_DIR) && terraform output -raw function_name 2>/dev/null); \
	aws logs tail /aws/lambda/$$FUNCTION --follow

invoke: ## Manually invoke the Lambda function and print the response
	@FUNCTION=$$(cd $(TERRAFORM_DIR) && terraform output -raw function_name 2>/dev/null); \
	aws lambda invoke \
		--function-name $$FUNCTION \
		--payload '{}' \
		--cli-binary-format raw-in-base64-out \
		/tmp/lambda-response.json && cat /tmp/lambda-response.json
