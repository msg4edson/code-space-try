TERRAFORM_DIR := terraform

.PHONY: help init validate plan apply destroy deploy appflow-run appflow-run-all appflow-status appflow-status-all s3-list s3-list-all

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
	if [ -z "$$FLOW" ]; then \
		echo "appflow_name is empty (multi-table mode detected). Use 'make appflow-run-all' or run 'aws appflow start-flow --flow-name <name>'."; \
		exit 1; \
	fi; \
	aws appflow start-flow --flow-name $$FLOW

appflow-run-all: ## Start runs for every managed AppFlow flow
	@cd $(TERRAFORM_DIR) && terraform output -json appflow_flow_names | \
		python -c "import json,sys,subprocess; data=json.load(sys.stdin); names=list(data.values()); \
print('No flows found' if not names else '\\n'.join(['Starting '+n if subprocess.call(['aws','appflow','start-flow','--flow-name',n])==0 else 'Failed '+n for n in names]))"

appflow-status: ## Show AppFlow flow details and latest execution metadata
	@FLOW=$$(cd $(TERRAFORM_DIR) && terraform output -raw appflow_name 2>/dev/null); \
	if [ -z "$$FLOW" ]; then \
		echo "appflow_name is empty (multi-table mode detected). Use 'make appflow-status-all' or run 'aws appflow describe-flow --flow-name <name>'."; \
		exit 1; \
	fi; \
	aws appflow describe-flow --flow-name $$FLOW

appflow-status-all: ## Describe every managed AppFlow flow
	@cd $(TERRAFORM_DIR) && terraform output -json appflow_flow_names | \
		python -c "import json,sys,subprocess; data=json.load(sys.stdin); names=list(data.values()); \
print('No flows found' if not names else '\\n'.join(['=== '+n+' ===' if subprocess.call(['aws','appflow','describe-flow','--flow-name',n])==0 else 'Failed '+n for n in names]))"

s3-list: ## List ingested ServiceNow objects in S3
	@BUCKET=$$(cd $(TERRAFORM_DIR) && terraform output -raw ingestion_bucket_name 2>/dev/null); \
	PREFIX=$$(cd $(TERRAFORM_DIR) && terraform output -raw ingestion_bucket_prefix 2>/dev/null); \
	if [ -z "$$PREFIX" ]; then \
		echo "ingestion_bucket_prefix is empty (multi-table mode detected). Use 'make s3-list-all'."; \
		exit 1; \
	fi; \
	aws s3 ls s3://$$BUCKET/$$PREFIX/ --recursive

s3-list-all: ## List ingested objects for every managed prefix
	@cd $(TERRAFORM_DIR) && \
	BUCKET=$$(terraform output -raw ingestion_bucket_name 2>/dev/null) && \
	terraform output -json ingestion_bucket_prefixes | \
		python -c "import json,sys,subprocess,os; data=json.load(sys.stdin); bucket=os.environ.get('BUCKET'); \
prefixes=list(data.values()); \
print('No prefixes found' if not prefixes else '\\n'.join(['=== '+p+' ===' if subprocess.call(['aws','s3','ls',f's3://{bucket}/{p}/','--recursive'])==0 else 'Failed '+p for p in prefixes]))" \
	BUCKET=$$BUCKET
