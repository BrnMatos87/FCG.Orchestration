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
