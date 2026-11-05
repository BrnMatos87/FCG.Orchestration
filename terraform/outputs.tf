output "resource_group_name" {
  description = "Resource Group criado para a FCG."
  value       = azurerm_resource_group.fcg.name
}

output "aks_name" {
  description = "Nome do cluster AKS."
  value       = azurerm_kubernetes_cluster.fcg.name
}

output "acr_name" {
  description = "Nome globalmente único do Azure Container Registry."
  value       = azurerm_container_registry.fcg.name
}

output "acr_login_server" {
  description = "Servidor utilizado nas tags das imagens Docker."
  value       = azurerm_container_registry.fcg.login_server
}

output "get_credentials_command" {
  description = "Comando para configurar o kubectl local."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.fcg.name} --name ${azurerm_kubernetes_cluster.fcg.name} --overwrite-existing"
}

output "github_actions_client_id" {
  description = "Client ID que deve ser cadastrado como AZURE_CLIENT_ID nos repositórios GitHub."
  value       = azuread_application_registration.github_actions.client_id
}

output "github_actions_tenant_id" {
  description = "Tenant ID que deve ser cadastrado como AZURE_TENANT_ID nos repositórios GitHub."
  value       = var.tenant_id
}

output "github_actions_subscription_id" {
  description = "Subscription ID que deve ser cadastrado como AZURE_SUBSCRIPTION_ID nos repositórios GitHub."
  value       = var.subscription_id
  sensitive   = true
}
