# 🎮 FCG.Orchestration

## 📖 Sobre o projeto

O **FCG.Orchestration** é o repositório responsável por centralizar a execução da solução **FIAP Cloud Games**.

Ele não possui código-fonte de negócio, sendo responsável apenas pela infraestrutura necessária para executar todos os microsserviços da aplicação.

Neste repositório estão concentrados:

- Docker Compose da solução completa
- Manifests Kubernetes
- Configurações compartilhadas
- Documentação da arquitetura
- Orquestração dos microsserviços

---

# 🏗 Arquitetura da Solução

A solução é composta pelos seguintes microsserviços:

| Microsserviço | Responsabilidade |
|---------------|------------------|
| FCG.Users | Cadastro e autenticação de usuários |
| FCG.Catalog | Catálogo de jogos e biblioteca do usuário |
| FCG.Payments | Processamento de pagamentos |
| FCG.Notifications | Envio de notificações via eventos |

Todos os serviços se comunicam através do RabbitMQ utilizando arquitetura orientada a eventos.

---

# 📁 Estrutura do Projeto

```text
FCG.Orchestration
│
├── docker-compose.yml
│
├── README.md
│
└── k8s
    ├── namespace.yaml
    ├── rabbitmq.yaml
    │
    ├── users
    │   ├── configmap.yaml
    │   ├── secret.yaml
    │   ├── api-deployment.yaml
    │   ├── api-service.yaml
    │   └── sqlserver.yaml
    │
    ├── catalog
    │   ├── configmap.yaml
    │   ├── secret.yaml
    │   ├── api-deployment.yaml
    │   ├── api-service.yaml
    │   ├── worker-deployment.yaml
    │   └── sqlserver.yaml
    │
    ├── payments
    │   ├── configmap.yaml
    │   ├── secret.yaml
    │   ├── api-deployment.yaml
    │   ├── api-service.yaml
    │   ├── worker-deployment.yaml
    │   └── sqlserver.yaml
    │
    └── notifications
        ├── configmap.yaml
        ├── secret.yaml
        └── worker-deployment.yaml
```

---

# 🐳 Containers

Ao executar o Docker Compose serão iniciados:

| Serviço | Porta |
|----------|------|
| Users API | 5101 |
| Catalog API | 5102 |
| Payments API | 5103 |
| RabbitMQ | 5672 |
| RabbitMQ Management | 15672 |
| Users SQL Server | 1435 |
| Catalog SQL Server | 1436 |
| Payments SQL Server | 1437 |

Além dos Workers:

- Catalog Worker
- Payments Worker
- Notifications Worker

---

# 🚀 Executando com Docker

## Subir toda a solução

```bash
docker compose up -d
```

---

## Verificar containers

```bash
docker compose ps
```

---

## Visualizar logs

Todos

```bash
docker compose logs -f
```

API Users

```bash
docker compose logs -f users-api
```

Catalog API

```bash
docker compose logs -f catalog-api
```

Catalog Worker

```bash
docker compose logs -f catalog-worker
```

Payments API

```bash
docker compose logs -f payments-api
```

Payments Worker

```bash
docker compose logs -f payments-worker
```

Notifications Worker

```bash
docker compose logs -f notifications-worker
```

---

# 🌐 Endpoints

## Users

```
http://localhost:5101/swagger
```

## Catalog

```
http://localhost:5102/swagger
```

## Payments

```
http://localhost:5103/swagger
```

---

# 🐰 RabbitMQ

Management

```
http://localhost:15672
```

Usuário

```
rabbitmquser
```

Senha

```
rbmq2587!@
```

---

# 💾 Bancos de Dados

Users

```
localhost,1435
```

Catalog

```
localhost,1436
```

Payments

```
localhost,1437
```

---

# ☸ Kubernetes

## Criar namespace

```bash
kubectl apply -f k8s/namespace.yaml
```

---

## RabbitMQ

```bash
kubectl apply -f k8s/rabbitmq.yaml
```

---

## Users

```bash
kubectl apply -f k8s/users
```

---

## Catalog

```bash
kubectl apply -f k8s/catalog
```

---

## Payments

```bash
kubectl apply -f k8s/payments
```

---

## Notifications

```bash
kubectl apply -f k8s/notifications
```

---

## Verificar Pods

```bash
kubectl get pods -n fcg
```

---

## Verificar Services

```bash
kubectl get svc -n fcg
```

---

## Verificar Deployments

```bash
kubectl get deployments -n fcg
```

---

# 🔄 Fluxo da Solução

## Cadastro de Usuário

Users API

↓

UserCreatedEvent

↓

Notifications Worker

↓

Envio de e-mail de boas-vindas

---

## Compra de Jogo

Catalog API

↓

OrderPlacedEvent

↓

Payments Worker

↓

PaymentProcessedEvent

↓

Catalog Worker

↓

Atualização da Biblioteca

↓

Notifications Worker

↓

Confirmação da Compra

---

# 📦 Imagens Docker Hub

```
brnmatos/fcg-users-api

brnmatos/fcg-catalog-api

brnmatos/fcg-catalog-worker

brnmatos/fcg-payments-api

brnmatos/fcg-payments-worker

brnmatos/fcg-notifications-worker
```

---

# 📚 Repositórios

- FCG.Users
- FCG.Catalog
- FCG.Payments
- FCG.Notifications
- FCG.Orchestration

---

# 🛠 Tecnologias

- .NET 8
- ASP.NET Core
- Entity Framework Core
- SQL Server
- RabbitMQ
- MassTransit
- Docker
- Docker Compose
- Kubernetes
- Swagger
- JWT Authentication

---

# 👨‍💻 Autor

Bruno Matos

Projeto desenvolvido para a Pós-Graduação em Arquitetura de Sistemas .NET da FIAP.