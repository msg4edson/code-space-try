# ServiceNow to S3 Ingestion with Amazon AppFlow

This repository provisions an ingestion pipeline that loads data from ServiceNow into Amazon S3 using Amazon AppFlow.

Initial ingestion target:
- ServiceNow table: kb_knowledge
- Trigger mode: OnDemand (recommended for first full ingest)

Architecture:
- Source: ServiceNow Table API
- Transport: Amazon AppFlow over HTTPS/TLS
- Destination: Amazon S3 bucket

## Project Structure

```text
.
├── terraform/
│   ├── appflow.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── s3.tf
│   └── variables.tf
├── Makefile
└── README.md
```

## What Terraform Creates

1. S3 ingestion bucket with:
   - versioning enabled
   - server-side encryption (AES256)
   - public access blocked
2. AppFlow flow configured to read from ServiceNow table kb_knowledge and write to S3.

## Prerequisites

- Terraform >= 1.7
- AWS CLI configured with credentials and region access
- GNU Make
- Existing Amazon AppFlow ServiceNow connector profile in the target AWS account

ServiceNow prerequisites for connector profile:
- ServiceNow instance URL (example: https://devXXXXX.service-now.com)
- Service account with roles:
  - rest_service
  - personalize_dictionary

## Quick Start

1. Create terraform variables file:

```hcl
aws_region                        = "us-east-1"
project_name                      = "servicenow-ingestion"
environment                       = "dev"

servicenow_connector_profile_name = "your-existing-servicenow-connector-profile"
servicenow_table_name             = "kb_knowledge"

appflow_name                      = "ServiceNow_to_S3_Daily_Sync"
appflow_trigger_type              = "OnDemand"

s3_bucket_name                    = "my-project-servicenow-ingestion"
s3_bucket_prefix                  = "servicenow/kb_knowledge"

# Only used when appflow_trigger_type = "Scheduled"
schedule_expression               = "rate(1 day)"
```

2. Provision infrastructure:

```bash
make init
make validate
make plan
make deploy
```

3. Run first ingestion (full load):

```bash
make appflow-run
```

4. Verify ingestion in S3:

```bash
make s3-list
```

## Available Make Targets

- make help: show available targets
- make init: run terraform init
- make validate: validate terraform configuration
- make plan: preview infrastructure changes
- make apply: apply infrastructure changes
- make deploy: apply ingestion infrastructure
- make appflow-run: start on-demand AppFlow execution
- make appflow-status: describe flow and execution metadata
- make s3-list: list ingested objects in S3 prefix
- make destroy: destroy managed infrastructure

## Configuration Defaults

- Data format: AppFlow default S3 output format
- S3 prefix: servicenow/kb_knowledge
- Trigger: OnDemand
- Error handling: managed by AppFlow flow execution behavior

## Verification Command

```bash
aws s3 ls s3://your-bucket-name/ --recursive
```

## Notes

- This project assumes connector profile creation is done outside Terraform.
- If you want scheduled incremental syncs, set appflow_trigger_type to Scheduled and adjust schedule_expression.