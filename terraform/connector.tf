resource "aws_appflow_connector_profile" "servicenow" {
  count           = var.create_connector_profile ? 1 : 0

  name            = var.servicenow_connector_profile_name
  connector_type  = "Servicenow"
  connection_mode = "Public"

  connector_profile_config {
    connector_profile_credentials {
      service_now {
        # Basic Auth only. For OAuth2, the AWS provider currently requires
        # using the console or CLI — Terraform aws_appflow_connector_profile
        # does not yet expose an oauth2 block for ServiceNow.
        username = var.servicenow_username
        password = var.servicenow_password
      }
    }

    connector_profile_properties {
      service_now {
        instance_url = var.servicenow_instance_url
      }
    }
  }
}
