# ServiceNow to S3 Ingestion with Amazon AppFlow

This repository provisions an ingestion pipeline that loads data from ServiceNow into Amazon S3 using Amazon AppFlow.

The Terraform configuration supports:
- Legacy single-table mode
- Multi-table mode with one AppFlow flow per table (recommended for 2-5 tables now and scalable to larger catalogs)

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
2. AppFlow flow resources configured to read from one or more ServiceNow tables and write to S3.

## Prerequisites

- Terraform >= 1.7
- AWS CLI configured with credentials and region access
- GNU Make
- Existing Amazon AppFlow ServiceNow connector profile in the target AWS account

ServiceNow prerequisites for connector profile:
- ServiceNow can be used as an Amazon AppFlow source only.
- ServiceNow account credentials for one of these authentication modes:
  - Basic Auth: username and password
  - OAuth2: client ID and client secret
- ServiceNow instance URL (example: https://devXXXXX.service-now.com)
- ServiceNow role access with read permissions for:
  - sys_db_object
  - sys_db_object.*
  - sys_dictionary
  - sys_dictionary.*
  - sys_glide_object
  - Any table to ingest (for example: incident and incident.*)

For role guidance, see ServiceNow documentation:
- https://docs.servicenow.com/bundle/sandiego-platform-administration/page/administer/roles/reference/r_SecurityJumpStartACLRules.html
- https://docs.servicenow.com/bundle/paris-platform-administration/page/administer/roles/concept/c_Roles.html

## Quick Start

1. Create terraform variables file:

```hcl
aws_region                        = "us-east-1"
project_name                      = "servicenow-ingestion"
environment                       = "dev"

servicenow_connector_profile_name = "your-existing-servicenow-connector-profile"
servicenow_table_name             = "kb_knowledge" # legacy single-table mode

appflow_name                      = "ServiceNow_to_S3_Daily_Sync"
appflow_trigger_type              = "OnDemand"

# Optional: customer-managed key for AppFlow encryption
appflow_kms_arn                   = null

s3_bucket_name                    = "my-project-servicenow-ingestion"
s3_bucket_prefix                  = "servicenow/kb_knowledge"

# Only used when appflow_trigger_type = "Scheduled"
schedule_expression               = "rate(1 day)"

# Recommended multi-table mode:
# appflow_tables = {
#   kb = {
#     table_name           = "kb_knowledge"
#     appflow_trigger_type = "Scheduled"
#     schedule_expression  = "rate(1 day)"
#     s3_bucket_prefix     = "servicenow/tables/kb_knowledge"
#     avg_rows_per_day     = 800
#     backfill_start_date  = "2018-01-01"
#     priority             = 1
#   }
#   incident = {
#     table_name           = "incident"
#     appflow_trigger_type = "Scheduled"
#     schedule_expression  = "rate(1 day)"
#     s3_bucket_prefix     = "servicenow/tables/incident"
#     avg_rows_per_day     = 1000
#     backfill_start_date  = "2018-01-01"
#     priority             = 2
#   }
# }
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

For multi-table mode, start all managed flows:

```bash
make appflow-run-all
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
- make appflow-run-all: start on-demand execution for all managed flows
- make appflow-status: describe flow and execution metadata
- make appflow-status-all: describe every managed flow
- make s3-list: list ingested objects in S3 prefix
- make s3-list-all: list ingested objects for all managed table prefixes
- make destroy: destroy managed infrastructure

## Configuration Defaults

- Data format: AppFlow default S3 output format
- S3 prefix: servicenow/kb_knowledge
- Trigger: OnDemand
- Error handling: managed by AppFlow flow execution behavior

## Multi-Table Scaling and Backfill Windows

AppFlow applies the 100,000 record limit per flow run. In multi-table mode, each table has its own flow/run budget.

Recommended planning cap per run: 80,000 records (20% headroom).

Use these formulas per table:

- window_days = floor(80000 / avg_rows_per_day)
- runs_per_table = ceil(backfill_days / window_days)

For an 8-year backfill (2,920 days):

- 1,000 rows/day => window_days=80, runs_per_table=37
- 500 rows/day => window_days=160, runs_per_table=19
- 200 rows/day => window_days=365 (capped), runs_per_table=8

Suggested S3 prefix convention for many tables:

- servicenow/tables/<table_name>/

The `appflow_tables` metadata fields `avg_rows_per_day`, `backfill_start_date`, and `priority` are for planning/orchestration and are not directly consumed by AppFlow.

## ServiceNow Connection Instructions (Console)

1. Open Amazon AppFlow: https://console.aws.amazon.com/appflow/
2. Choose Create flow.
3. Enter flow name and description.
4. Optional: customize encryption with a customer-managed KMS key.
5. Optional: add tags.
6. Choose ServiceNow for Source name.
7. Choose Connect, then enter:
   - Connection name
   - Authentication mode (Basic Auth or OAuth2)
   - Basic Auth credentials (username/password) or OAuth2 credentials (client ID/client secret)
   - ServiceNow instance URL
8. Choose Connect and then choose the ServiceNow object.

## ServiceNow Considerations and Limits

- ServiceNow object dropdown population may take time because AppFlow lists all available tables, including custom tables.
- Flows can run on-demand or on schedule.
- Maximum schedule frequency when ServiceNow is source: one run per minute.
- Incremental scheduled flows use the sys_updated_on field.
- ServiceNow supports up to 100,000 records per single flow run.
- Truncate and Mask transformations are not supported for ServiceNow reference type fields:
  - Truncate sets reference fields to an empty string.
  - Mask sets reference fields to null.

## Supported Destinations for ServiceNow Source

- Amazon Connect Customer
- Amazon Honeycode
- Lookout for Metrics
- Amazon Redshift
- Amazon S3
- Marketo
- Salesforce
- Snowflake
- Upsolver
- Zendesk
- Custom connectors built with AppFlow Custom Connector SDKs:
  - Python SDK: https://github.com/awslabs/aws-appflow-custom-connector-python
  - Java SDK: https://github.com/awslabs/aws-appflow-custom-connector-java

## Verification Command

```bash
aws s3 ls s3://your-bucket-name/ --recursive
```

## Notes

- This project assumes connector profile creation is done outside Terraform.
- If you want scheduled incremental syncs, set appflow_trigger_type to Scheduled and adjust schedule_expression.