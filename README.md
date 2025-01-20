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
