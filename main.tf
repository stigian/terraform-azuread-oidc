data "azuread_client_config" "current" {}
data "azuread_application_published_app_ids" "well_known" {}
data "azuread_user" "app_admins" {
  for_each            = toset(var.app_admin_upns)
  user_principal_name = each.key
}

locals {
  create                    = var.create
  entra_auth_endpoint       = var.azuread_environment == "usgovernment" ? "https://login.microsoftonline.us" : "https://login.microsoftonline.com"
  graph_endpoint            = var.azuread_environment == "usgovernment" ? "https://graph.microsoft.us" : "https://graph.microsoft.com"
  oauth2_issuer_endpoint    = "${local.entra_auth_endpoint}/${data.azuread_client_config.current.tenant_id}/v2.0"
  oauth2_auth_endpoint      = "${local.entra_auth_endpoint}/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/authorize"
  oauth2_token_endpoint     = "${local.entra_auth_endpoint}/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/token"
  oauth2_user_info_endpoint = "${local.graph_endpoint}/oidc/userinfo"
  app_admin_object_ids      = [for upn in var.app_admin_upns : data.azuread_user.app_admins[upn].object_id]
  redirect_uris             = ["${var.homepage_url}/oauth2/idpresponse"]
}

###############################################################################
# Entra ID
# https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/add-application-portal-setup-oidc-sso
###############################################################################

resource "azuread_service_principal" "msgraph" {
  count = local.create ? 1 : 0

  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "this" {
  count = local.create ? 1 : 0

  display_name            = "${var.identifier}-alb-oidc"
  group_membership_claims = ["SecurityGroup"]
  sign_in_audience        = "AzureADMyOrg"
  description             = "Application OIDC IdP for ${var.identifier} ALB."
  owners = concat(
    [data.azuread_client_config.current.object_id],
    local.app_admin_object_ids
  )

  web {
    homepage_url  = var.homepage_url # url user would use to access the app
    redirect_uris = local.redirect_uris
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

    resource_access {
      id   = azuread_service_principal.msgraph[0].oauth2_permission_scope_ids["openid"]
      type = "Scope"
    }
  }
}

# Assigning a Service Principal turns the application into an Enterprise Application
resource "azuread_service_principal" "this" {
  count = local.create ? 1 : 0

  client_id                     = azuread_application.this[0].client_id
  use_existing                  = true
  preferred_single_sign_on_mode = "oidc"
  notification_email_addresses  = var.notification_emails
  app_role_assignment_required  = true
  feature_tags {
    enterprise = true
    gallery    = false
    hide       = var.hide_app
  }
}

resource "azuread_application_password" "this" {
  count = local.create ? 1 : 0

  application_id = azuread_application.this[0].id
  display_name   = "${var.identifier}-alb-oidc"
}

# https://learn.microsoft.com/en-us/graph/permissions-reference#openid
resource "azuread_service_principal_delegated_permission_grant" "this" {
  count = local.create ? 1 : 0

  service_principal_object_id          = azuread_service_principal.this[0].object_id
  resource_service_principal_object_id = azuread_service_principal.msgraph[0].object_id
  claim_values                         = ["openid"]
}

# In cases where additional user attributes are required by the workload
# application, more permissions can be granted to the azuread_application.
# This is done by assigning the API permissions to the associated Service
# Principal. The following example demonstrates how to grant the application
# the ability to read all users and group members.

# https://learn.microsoft.com/en-us/graph/permissions-reference#userreadall
# Note: automatically grants admin consent for the permissions
# resource "azuread_app_role_assignment" "user_read_all" {
#   app_role_id         = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
#   principal_object_id = azuread_service_principal.this.object_id
#   resource_object_id  = azuread_service_principal.msgraph.object_id
# }

# https://learn.microsoft.com/en-us/graph/permissions-reference#groupmemberreadall
# Note: automatically grants admin consent for the permissions
# resource "azuread_app_role_assignment" "groupmember_read_all" {
#   app_role_id         = azuread_service_principal.msgraph.app_role_ids["GroupMember.Read.All"]
#   principal_object_id = azuread_service_principal.this.object_id
#   resource_object_id  = azuread_service_principal.msgraph.object_id
# }
