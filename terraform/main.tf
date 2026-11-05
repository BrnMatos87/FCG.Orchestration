resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  acr_name = "${lower(var.acr_name_prefix)}${random_string.acr_suffix.result}"
}

resource "azurerm_resource_group" "fcg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "fcg" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.fcg.name
  location            = azurerm_resource_group.fcg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "fcg" {
  name                = var.aks_name
  location            = azurerm_resource_group.fcg.location
  resource_group_name = azurerm_resource_group.fcg.name
  dns_prefix          = "fcg-fase4"
  sku_tier            = "Free"

  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true

  default_node_pool {
    name                         = "system"
    node_count                   = var.node_count
    vm_size                      = var.node_vm_size
    type                         = "VirtualMachineScaleSets"
    os_disk_size_gb              = 64
    only_critical_addons_enabled = false

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.fcg.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.fcg.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
