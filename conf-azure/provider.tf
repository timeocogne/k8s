terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.25"
    }
  }
}

# --- Provider Vault ---
provider "vault" {
  address = "http://127.0.0.1:8200"
}

# --- Lecture des secrets depuis Vault ---
data "vault_generic_secret" "azure" {
  path = "terraform/azure"
}

# --- Provider Azure (utilise les secrets Vault) ---
provider "azurerm" {
  features {}

  subscription_id = data.vault_generic_secret.azure.data["subscription_id"]
  client_id       = data.vault_generic_secret.azure.data["client_id"]
  client_secret   = data.vault_generic_secret.azure.data["client_secret"]
  tenant_id       = data.vault_generic_secret.azure.data["tenant_id"]
}
