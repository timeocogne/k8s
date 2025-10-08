variable "subscription_id" {
  description = "ID de ton abonnement Azure"
  type        = string
}

variable "client_id" {
  description = "App ID du service principal Azure"
  type        = string
}

variable "client_secret" {
  description = "Mot de passe du service principal Azure"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Tenant ID Azure"
  type        = string
}
