resource "aws_appflow_flow" "servicenow_to_s3" {
  for_each = var.enable_appflow ? local.effective_tables : {}

  name    = each.value.flow_name
  kms_arn = var.appflow_kms_arn

  depends_on = [
    aws_s3_bucket_policy.servicenow_ingestion,
    aws_s3_bucket_public_access_block.servicenow_ingestion,
    aws_s3_bucket_server_side_encryption_configuration.servicenow_ingestion,
    aws_s3_bucket_versioning.servicenow_ingestion,
    aws_appflow_connector_profile.servicenow
  ]

  source_flow_config {
    connector_type         = "Servicenow"
    connector_profile_name = var.create_connector_profile ? aws_appflow_connector_profile.servicenow[0].name : var.servicenow_connector_profile_name

    source_connector_properties {
      service_now {
        object = each.value.table_name
      }
    }
  }

  destination_flow_config {
    connector_type = "S3"

    destination_connector_properties {
      s3 {
        bucket_name   = aws_s3_bucket.servicenow_ingestion.bucket
        bucket_prefix = each.value.s3_bucket_prefix
      }
    }
  }

  task {
    source_fields = []
    task_type     = "Map_all"
  }

  trigger_config {
    trigger_type = each.value.appflow_trigger_type

    dynamic "trigger_properties" {
      for_each = each.value.appflow_trigger_type == "Scheduled" ? [1] : []

      content {
        scheduled {
          schedule_expression = each.value.schedule_expression
          data_pull_mode      = "Incremental"
        }
      }
    }
  }
}
