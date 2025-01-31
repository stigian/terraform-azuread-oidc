# terraform-azuread-oidc

This Terraform module creates Entra ID (formerly Azure AD) resources for implementing OIDC SSO via AWS ALB.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "oidc" {
  source               = "git::https://github.com/stigian/terraform-azuread-oidc.git?ref=main"
  identifier           = "demo"
  environment          = "usgovernment"
  homepage_url         = "https://demo.example.com"
  notification_emails  = ["user1@example.com", "user2@example.com"]
  app_admin_upns       = ["user1@example.onmicrosoft.com", "user2@example.onmicrosoft.com"]
}
```

Then, in your ALB configuration you can reference the outputs of this module:

```hcl
listeners = {
  oidc = {
    port            = 443
    protocol        = "HTTPS"
    ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-FIPS-2023-04"
    certificate_arn = local.public_wildcard_cert_arn
    action_type     = "authenticate-oidc"
    authenticate_oidc = {
      authentication_request_extra_params = {
        scope  = "openid"
        prompt = "none"
      }
      client_id              = module.oidc.client_id
      client_secret          = module.oidc.client_secret
      authorization_endpoint = module.oidc.oauth2_auth_endpoint
      issuer                 = module.oidc.oauth2_issuer_endpoint
      token_endpoint         = module.oidc.oauth2_token_endpoint
      user_info_endpoint     = module.oidc.oauth2_user_info_endpoint
    }

    forward = {
      target_group_key = "nlb_https"
    }
  }
```

## References

- [Authenticate users using an Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.this](https://registry.terraform.io/providers/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.this](https://registry.terraform.io/providers/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_delegated_permission_grant.this](https://registry.terraform.io/providers/azuread/latest/docs/resources/service_principal_delegated_permission_grant) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azuread_client_config.current](https://registry.terraform.io/providers/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_user.app_admins](https://registry.terraform.io/providers/azuread/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_upns"></a> [app\_admin\_upns](#input\_app\_admin\_upns) | List of Entra ID UPNs for app administrators / owners.<br/><br/>Example:<br/>[<br/>  "user1@example.onmicrosoft.com",<br/>  "user1@example.onmicrosoft.com"<br/>] | `list(string)` | n/a | yes |
| <a name="input_azuread_environment"></a> [azuread\_environment](#input\_azuread\_environment) | Azure AD environment, either global or usgovernment. | `string` | `"usgovernment"` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_hide_app"></a> [hide\_app](#input\_hide\_app) | Hides the Application from user's My Apps portal. Set to `true` if you want to hide the app. | `bool` | `false` | no |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | URL of the homepage for the application. | `string` | `"demo.example.com"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Name of the project. | `string` | `"demo"` | no |
| <a name="input_notification_emails"></a> [notification\_emails](#input\_notification\_emails) | List of email addresses to receive signing certificate expiration notifications.<br/>These emails will receive notifications when the SSO IdP SAML certificate<br/>is about to expire.<br/><br/>Example:<br/>[<br/>  "user1@example.com",<br/>  "user2@example.com"<br/>] | `list(string)` | n/a | yes |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | List of URIs where authentication responses are sent. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Client ID of the OpenID Connect Provider. |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | Client secret of the OpenID Connect Provider. |
| <a name="output_entra_auth_endpoint"></a> [entra\_auth\_endpoint](#output\_entra\_auth\_endpoint) | The authentication endpoint for Entra ID. |
| <a name="output_graph_endpoint"></a> [graph\_endpoint](#output\_graph\_endpoint) | The Microsoft Graph endpoint. |
| <a name="output_oauth2_auth_endpoint"></a> [oauth2\_auth\_endpoint](#output\_oauth2\_auth\_endpoint) | The OAuth2 authorization endpoint. |
| <a name="output_oauth2_issuer_endpoint"></a> [oauth2\_issuer\_endpoint](#output\_oauth2\_issuer\_endpoint) | The OAuth2 issuer endpoint. |
| <a name="output_oauth2_token_endpoint"></a> [oauth2\_token\_endpoint](#output\_oauth2\_token\_endpoint) | The OAuth2 token endpoint. |
| <a name="output_oauth2_user_info_endpoint"></a> [oauth2\_user\_info\_endpoint](#output\_oauth2\_user\_info\_endpoint) | The OAuth2 user info endpoint. |
| <a name="output_provider_attributes"></a> [provider\_attributes](#output\_provider\_attributes) | Attributes of the Entra ID OpenID Connect Provider. |
<!-- END_TF_DOCS -->