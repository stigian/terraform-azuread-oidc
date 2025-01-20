output "provider_attributes" {
  description = "Attributes of the Entra ID OpenID Connect Provider."
  value       = azuread_application.this[0]
}

output "client_id" {
  description = "Client ID of the OpenID Connect Provider."
  value       = azuread_application.this[0].client_id
}

output "client_secret" {
  description = "Client secret of the OpenID Connect Provider."
  value       = azuread_application_password.this[0].value
  sensitive   = true
}

output "entra_auth_endpoint" {
  description = "The authentication endpoint for Entra ID."
  value       = local.entra_auth_endpoint
}

output "graph_endpoint" {
  description = "The Microsoft Graph endpoint."
  value       = local.graph_endpoint
}

output "oauth2_issuer_endpoint" {
  description = "The OAuth2 issuer endpoint."
  value       = local.oauth2_issuer_endpoint
}

output "oauth2_auth_endpoint" {
  description = "The OAuth2 authorization endpoint."
  value       = local.oauth2_auth_endpoint
}

output "oauth2_token_endpoint" {
  description = "The OAuth2 token endpoint."
  value       = local.oauth2_token_endpoint
}

output "oauth2_user_info_endpoint" {
  description = "The OAuth2 user info endpoint."
  value       = local.oauth2_user_info_endpoint
}
