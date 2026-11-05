resource "azuread_application_registration" "github_actions" {
  display_name = "fcg-fase4-github-actions"
  description  = "Identidade OIDC usada pelas pipelines da FCG Fase 4."
}

resource "azuread_service_principal" "github_actions" {
  client_id = azuread_application_registration.github_actions.client_id
}

resource "azuread_application_federated_identity_credential" "github_actions" {
  for_each = var.github_repositories

  application_id = azuread_application_registration.github_actions.id
  display_name   = "github-${lower(replace(each.value, ".", "-"))}-${var.github_deploy_branch}"
  description    = "Autoriza ${var.github_owner}/${each.value} na branch ${var.github_deploy_branch}."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${each.value}:ref:refs/heads/${var.github_deploy_branch}"
}

resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                            = azurerm_container_registry.fcg.id
  role_definition_name             = "AcrPush"
  principal_id                     = azuread_service_principal.github_actions.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "github_actions_aks_admin" {
  scope                            = azurerm_kubernetes_cluster.fcg.id
  role_definition_name             = "Azure Kubernetes Service Cluster Admin Role"
  principal_id                     = azuread_service_principal.github_actions.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
