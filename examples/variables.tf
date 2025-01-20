variable "create" {
  description = "Determines whether to create the OIDC objects or not; defaults to enabling the creation."
  default     = true
  type        = bool
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

variable "homepage_url" {
  description = "Application hostname without the protocol, e.g. demo.example.com"
  type        = string
}
