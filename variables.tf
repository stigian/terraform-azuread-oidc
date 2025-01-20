variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "identifier" {
  description = "Name of the project."
  type        = string
  default     = "demo"
}

variable "azuread_environment" {
  description = "Azure AD environment, either global or usgovernment."
  type        = string
  default     = "usgovernment"
}

variable "homepage_url" {
  description = "URL of the homepage for the application."
  type        = string
  default     = "demo.example.com"
}

variable "redirect_uris" {
  description = "List of URIs where authentication responses are sent."
  type        = list(string)
  default     = []
}

variable "app_admin_upns" {
  type        = list(string)
  description = <<-EOT
    List of Entra ID UPNs for app administrators / owners.

    Example:
    [
      "user1@example.onmicrosoft.com",
      "user1@example.onmicrosoft.com"
    ]
  EOT

  validation {
    condition     = length(var.app_admin_upns) > 0 && alltrue([for upn in var.app_admin_upns : can(regex("^\\S+@\\S+\\.\\S+$", upn))])
    error_message = "The app_admin_upns variable must be a list of one or more valid UPNs."
  }
}

variable "notification_emails" {
  type        = list(string)
  description = <<-EOT
    List of email addresses to receive signing certificate expiration notifications.
    These emails will receive notifications when the SSO IdP SAML certificate
    is about to expire.

    Example:
    [
      "user1@example.com",
      "user2@example.com"
    ]
  EOT

  validation {
    condition     = length(var.notification_emails) > 0 && alltrue([for email in var.notification_emails : can(regex("^\\S+@\\S+\\.\\S+$", email))])
    error_message = "The notification_emails variable must be a list of one or more valid email addresses."
  }
}
