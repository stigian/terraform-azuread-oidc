module "oidc" {
  source              = "git::https://github.com/stigian/terraform-azuread-oidc.git?ref=main"
  identifier          = "demo"
  environment         = "usgovernment"
  homepage_url        = "https://demo.example.com"
  notification_emails = ["user1@example.com", "user2@example.com"]
  app_admin_upns      = ["user1@example.onmicrosoft.com", "user2@example.onmicrosoft.com"]
}
