locals {
  legacy_table_catalog = {
    default = {
      enabled              = true
      table_name           = var.servicenow_table_name
      flow_name            = var.appflow_name
      s3_bucket_prefix     = var.s3_bucket_prefix
      appflow_trigger_type = var.appflow_trigger_type
      schedule_expression  = var.schedule_expression
      avg_rows_per_day     = null
      backfill_start_date  = null
      priority             = null
    }
  }

  raw_table_catalog = length(var.appflow_tables) > 0 ? var.appflow_tables : local.legacy_table_catalog

  effective_tables = {
    for key, cfg in local.raw_table_catalog : key => {
      table_name           = cfg.table_name
      flow_name            = try(cfg.flow_name, length(var.appflow_tables) > 0 ? format("%s-%s", var.appflow_name, key) : var.appflow_name)
      s3_bucket_prefix     = try(cfg.s3_bucket_prefix, length(var.appflow_tables) > 0 ? format("servicenow/tables/%s", cfg.table_name) : var.s3_bucket_prefix)
      appflow_trigger_type = try(cfg.appflow_trigger_type, var.appflow_trigger_type)
      schedule_expression  = try(cfg.schedule_expression, var.schedule_expression)
      avg_rows_per_day     = try(cfg.avg_rows_per_day, null)
      backfill_start_date  = try(cfg.backfill_start_date, null)
      priority             = try(cfg.priority, null)
    } if try(cfg.enabled, true)
  }
}