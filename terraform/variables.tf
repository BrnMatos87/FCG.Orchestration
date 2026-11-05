variable "subscription_id" {
  description = "ID da assinatura Azure onde a infraestrutura será criada."
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "ID do tenant Microsoft Entra usado pela identidade do GitHub Actions."
  type        = string
}

variable "github_owner" {
  description = "Organização ou usuário proprietário dos repositórios GitHub."
  type        = string
}

variable "github_repositories" {
  description = "Repositórios autorizados a solicitar tokens OIDC para a Azure."
  type        = set(string)
  default = [
    "FCG.Users",
    "FCG.Catalog",
    "FCG.Orchestration"
  ]
}

variable "github_deploy_branch" {
  description = "Branch de produção autorizada a publicar imagens e implantar no AKS."
  type        = string
  default     = "main"
}

variable "location" {
  description = "Região Azure dos recursos da FCG."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource Group da plataforma FCG."
  type        = string
  default     = "rg-fcg-fase4"
}

variable "aks_name" {
  description = "Nome do cluster AKS."
  type        = string
  default     = "aks-fcg-fase4"
}

variable "acr_name_prefix" {
  description = "Prefixo do ACR. Um sufixo aleatório garante unicidade global."
  type        = string
  default     = "acrfcgfase4"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,40}$", var.acr_name_prefix))
    error_message = "acr_name_prefix deve conter apenas letras e números, entre 5 e 40 caracteres."
  }
}

variable "node_vm_size" {
  description = "SKU da VM do node pool do AKS."
  type        = string
  default     = "Standard_D2s_v4"
}

variable "node_count" {
  description = "Quantidade inicial de nós no AKS."
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 3
    error_message = "node_count deve estar entre 1 e 3 para este ambiente."
  }
}

variable "tags" {
  description = "Tags comuns dos recursos Azure."
  type        = map(string)
  default = {
    project     = "fiap-cloud-games"
    environment = "phase4"
    managed-by  = "terraform"
  }
}
