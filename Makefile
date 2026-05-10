TERRAFORM_DIR := terraform

.PHONY: help init validate plan apply destroy deploy appflow-run appflow-status s3-list

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

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

deploy: apply ## Apply ingestion infrastructure

# ---------------------------------------------------------------------------
# Operational helpers (require AWS CLI + correct AWS credentials)
# ---------------------------------------------------------------------------

appflow-run: ## Start an on-demand AppFlow run
	@FLOW=$$(cd $(TERRAFORM_DIR) && terraform output -raw appflow_name 2>/dev/null); \
	aws appflow start-flow --flow-name $$FLOW

appflow-status: ## Show AppFlow flow details and latest execution metadata
	@FLOW=$$(cd $(TERRAFORM_DIR) && terraform output -raw appflow_name 2>/dev/null); \
	aws appflow describe-flow --flow-name $$FLOW

s3-list: ## List ingested ServiceNow objects in S3
	@BUCKET=$$(cd $(TERRAFORM_DIR) && terraform output -raw ingestion_bucket_name 2>/dev/null); \
	PREFIX=$$(cd $(TERRAFORM_DIR) && terraform output -raw ingestion_bucket_prefix 2>/dev/null); \
	aws s3 ls s3://$$BUCKET/$$PREFIX/ --recursive
