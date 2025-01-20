terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azuread = {
      source  = "azuread"
      version = "~> 3.0.0"
    }
  }
}
