# Postman — FCG Fase 3

Importe os dois arquivos no Postman:

- `FCG-Fase-3.postman_collection.json`;
- `FCG-Fase-3-Local.postman_environment.json`.

Selecione **FCG - Fase 3 Local** no canto superior direito antes de executar os
requests. Os scripts de login salvam os JWTs nesse Environment e também nas
variáveis da Collection.

Todos os requests externos usam `kongBaseUrl`. O padrão é `http://localhost:8000`. Para usá-lo com Kubernetes:

```bash
kubectl port-forward service/kong-proxy 8000:80 -n fcg
```

Se `kong-proxy` tiver IP externo, altere `kongBaseUrl` nas variáveis da Collection para `http://<EXTERNAL-IP>`.

## Ordem sugerida para a apresentação

1. `Login - Administrador` salva `adminJwtToken`.
2. `Registrar usuário - Público` cria um usuário comum, salva `userId` e aciona Notifications por HTTP.
3. `Login - Usuário normal` salva `userJwtToken`.
4. `Criar usuário - Administrador` demonstra uma operação administrativa e salva `managedUserId`.
5. `Criar jogo` salva `gameId` usando o token administrativo.
6. Liste o catálogo disponível, crie uma avaliação e crie uma compra usando o token do usuário normal.
7. Aguarde o processamento assíncrono e consulte o pagamento com o token administrativo e a biblioteca com o token normal.

Cada request protegido está associado ao JWT apropriado:

- `adminJwtToken`: criação e manutenção de usuários/jogos e consulta de pagamentos;
- `userJwtToken`: consultas permitidas a usuários, avaliações, compras e biblioteca;
- sem token: login e registro público.

`Listar catálogo disponível - User` mostra os jogos disponíveis na loja; “User”
indica apenas o JWT usado. `Listar jogos adquiridos - Somente aprovados` consulta
a biblioteca e retorna apenas compras aprovadas.

A Collection monta explicitamente o header `Authorization` no formato
`Bearer {{adminJwtToken}}` ou `Bearer {{userJwtToken}}`, conforme a role exigida.
As variáveis armazenam somente o JWT iniciado por `eyJ`, sem o texto `Bearer` e
sem aspas.

Os e-mails e títulos são gerados com timestamp, permitindo repetir a demonstração sem conflito de unicidade.

## Notifications

Os HTTP Triggers da Azure Function são integração interna, não endpoints públicos do cliente. A criação do usuário e o processamento do pagamento chamam Notifications por HTTP. Dessa forma, todas as chamadas externas desta apresentação entram pelo Kong sem expor a Function indevidamente.
