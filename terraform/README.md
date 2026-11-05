# Terraform - FCG Fase 4

Esta configuração provisiona a infraestrutura Azure compartilhada da solução:

- Resource Group;
- Azure Container Registry Basic, sem usuário administrador;
- Azure Kubernetes Service Free tier;
- identidade gerenciada do AKS com permissão `AcrPull` no ACR.

As APIs e suas dependências são definidas pelos manifests Kubernetes do
repositório de orquestração. No primeiro deploy, esses manifests podem ser
aplicados manualmente para validação; no fluxo final, as pipelines executam a
implantação e atualizam as imagens no AKS.

## Pré-requisitos

- Terraform 1.10 ou superior;
- Azure CLI;
- acesso à assinatura Azure;
- `Contributor` para criar os recursos;
- permissão para criar a associação `AcrPull`, como `Role Based Access Control Administrator`, `User Access Administrator` ou `Owner`;
- `Storage Blob Data Contributor` no Storage Account do state.

Autentique e selecione a assinatura antes de executar o Terraform:

```powershell
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

## Estado remoto

O backend usa Azure Storage para que pessoas e pipelines diferentes trabalhem
com o mesmo estado. O Storage Account não armazena dados da aplicação; ele
mantém somente o vínculo entre os arquivos Terraform e os recursos reais.

A configuração inicial precisa criar uma única vez:

```text
Resource Group:  rg-fcg-tfstate
Storage Account: nome globalmente único
Container:       tfstate
Blob do state:   fcg-orchestration-phase4.tfstate
```

### Criar o backend pela primeira vez

Execute estes comandos somente uma vez. Eles criam o armazenamento privado do
state, mas ainda não criam AKS nem ACR:

```powershell
$subscriptionId = az account show --query id --output tsv
$stateSuffix = $subscriptionId.Replace("-", "").Substring(0, 8)
$stateResourceGroup = "rg-fcg-tfstate"
$stateStorageAccount = "stfcgtfstate$stateSuffix"
$stateContainer = "tfstate"

az group create `
  --name $stateResourceGroup `
  --location eastus

az storage account create `
  --name $stateStorageAccount `
  --resource-group $stateResourceGroup `
  --location eastus `
  --sku Standard_LRS `
  --kind StorageV2 `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false

$stateStorageId = az storage account show `
  --name $stateStorageAccount `
  --resource-group $stateResourceGroup `
  --query id `
  --output tsv

$currentUserId = az ad signed-in-user show --query id --output tsv

az role assignment create `
  --assignee-object-id $currentUserId `
  --assignee-principal-type User `
  --role "Storage Blob Data Contributor" `
  --scope $stateStorageId

az storage container create `
  --name $stateContainer `
  --account-name $stateStorageAccount `
  --auth-mode login
```

Se o último comando retornar erro de autorização imediatamente depois da
atribuição da função, aguarde a propagação da permissão e execute somente o
comando `az storage container create` novamente.

Confirme os valores que serão usados em `backend.hcl`:

```powershell
$stateResourceGroup
$stateStorageAccount
$stateContainer
```

Não versione `backend.hcl`, arquivos `*.tfvars` reais, planos `tfplan` ou
arquivos `*.tfstate`.

## Primeira execução

Copie os exemplos e preencha os valores da assinatura e do backend:

```powershell
Copy-Item backend.hcl.example backend.hcl
Copy-Item terraform.tfvars.example terraform.tfvars
```

Inicialize e valide:

```powershell
terraform init -backend-config=backend.hcl
terraform fmt -check
terraform validate
terraform plan -out=tfplan
```

Revise o plano antes de criar recursos. Somente depois da revisão:

```powershell
terraform apply tfplan
```

## Execução por outro colaborador

Um colaborador não recebe o arquivo `terraform.tfstate`. Depois de clonar o
repositório, ele deve:

1. obter as permissões Azure listadas nos pré-requisitos;
2. executar `az login` e selecionar a assinatura;
3. copiar `backend.hcl.example` para `backend.hcl` e informar o mesmo Storage Account;
4. copiar `terraform.tfvars.example` para `terraform.tfvars`;
5. executar `terraform init -backend-config=backend.hcl`;
6. executar `terraform plan`.

Durante o `init`, o Terraform acessa automaticamente o state armazenado no
Azure Storage. O bloqueio do blob evita que duas execuções alterem o mesmo
state simultaneamente.

## Pós-aplicação

Depois do `apply`, use os outputs para configurar o `kubectl` e as tags das
imagens no ACR:

```powershell
terraform output
terraform output -raw get_credentials_command
```
