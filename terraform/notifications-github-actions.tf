data "azurerm_resource_group" "notifications" {
  name = var.notifications_resource_group_name
}

data "azurerm_storage_account" "terraform_state" {
  name                = var.terraform_state_storage_account_name
  resource_group_name = var.terraform_state_resource_group_name
}

resource "azuread_application_registration" "notifications_github_actions" {
  display_name = "fcg-notifications-github-actions"
  description  = "Identidade OIDC exclusiva do pipeline da FCG.Notifications."
}

resource "azuread_service_principal" "notifications_github_actions" {
  client_id = azuread_application_registration.notifications_github_actions.client_id
}

resource "azuread_application_federated_identity_credential" "notifications_github_actions" {
  application_id = azuread_application_registration.notifications_github_actions.id
  display_name   = "github-fcg-notifications-${var.notifications_github_environment}"
  description    = "Autoriza ${var.github_owner}/${var.notifications_github_repository} no Environment ${var.notifications_github_environment}."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${var.notifications_github_repository}:environment:${var.notifications_github_environment}"
}

resource "azurerm_role_assignment" "notifications_github_actions_contributor" {
  scope                            = data.azurerm_resource_group.notifications.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.notifications_github_actions.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "notifications_github_actions_state_reader" {
  scope                            = data.azurerm_storage_account.terraform_state.id
  role_definition_name             = "Reader"
  principal_id                     = azuread_service_principal.notifications_github_actions.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "notifications_github_actions_state_data" {
  scope                            = data.azurerm_storage_account.terraform_state.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azuread_service_principal.notifications_github_actions.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
