# Postman - FCG Fase 4

Importe estes arquivos no Postman:

- `FCG-Fase-4.postman_collection.json`;
- `FCG-Fase-4.postman_environment.json`.

Selecione **FCG - Fase 4** e preencha localmente `adminPassword` e
`testUserPassword`. Preencha `newUserPassword` somente se for demonstrar a troca
de senha. Os valores são secretos e ficam vazios no Git. Os scripts de login
salvam os JWTs no Environment e nas variáveis da Collection.

Todos os requests externos usam `kongBaseUrl`. Para acessar o cluster por
port-forward, mantenha `http://localhost:8000` e execute:

```powershell
kubectl port-forward service/kong-proxy 8000:80 -n fcg
```

Para demonstrar o Load Balancer, substitua `kongBaseUrl` por
`http://<EXTERNAL-IP>` obtido com:

```powershell
kubectl get service kong-proxy -n fcg
```

## Roteiro obrigatório da Fase 4

Execute as pastas e requests na ordem apresentada:

1. Faça login como administrador.
2. Registre um usuário e faça login com ele.
3. Execute `Consultar versão implantada` para identificar o SHA da imagem do
   Catalog em execução. Esse valor pode ser comparado com a tag do ACR antes e
   depois de um live deploy.
4. Crie um jogo. A criação invalida a lista em cache e indexa o documento no
   Elastic Cloud.
5. Execute `Listar catálogo - 1ª consulta (cache miss)`. O script salva o tempo
   em `cacheMissResponseTime`.
6. Execute `Listar catálogo - 2ª consulta (cache hit)`. O script exibe no console
   os dois tempos. Confirme nos logs do Catalog a mensagem `CacheStatus: HIT`.
7. Execute `Busca fuzzy - erro de digitação`. O termo `Presentaton` contém um
   erro proposital e deve localizar o jogo `Presentation` por relevância.
8. Atualize o jogo e repita a busca para demonstrar a sincronização do índice.
9. Crie e liste uma avaliação para demonstrar a persistência no MongoDB.

Para acompanhar o cache durante os passos 5 e 6:

```powershell
kubectl logs -n fcg deployment/fcg-catalog-api --tail=100 -f
```

O tempo da segunda chamada é uma evidência auxiliar. A confirmação determinística
do cache hit é a mensagem do Catalog nos logs.

## Fluxo adicional de compra

Depois do roteiro obrigatório, execute:

1. `Criar compra` com o usuário normal;
2. aguarde o processamento assíncrono;
3. `Consultar pagamento por Order ID` com o administrador;
4. `Listar jogos adquiridos - Somente aprovados` com o usuário normal.

Esse fluxo demonstra Catalog, RabbitMQ, Payments e Notifications, mas não é
necessário para provar MongoDB, Redis e Elasticsearch.

## Tokens e variáveis

- `adminJwtToken`: manutenção de usuários e jogos e consulta de pagamentos;
- `userJwtToken`: catálogo, avaliações, compras e biblioteca;
- `gameId`, `userId` e `orderId`: preenchidos automaticamente pelos testes;
- `cacheMissResponseTime`: tempo em milissegundos da primeira consulta;
- `fuzzySearchTerm`: termo propositalmente digitado com erro.

Os HTTP Triggers de Notifications são internos. Todas as chamadas do cliente
entram pelo Kong; a Azure Function não deve ser exposta na Collection.
