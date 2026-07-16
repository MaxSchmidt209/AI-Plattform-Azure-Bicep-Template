# AI-Plattform-Azure-Bicep-Template

Modulare, sichere Bicep-Infrastruktur für die Azure AI Platform in der Resource Group `ingsoft-interwatt-azure-ai-resource-group`.

## Architektur

Die Infrastruktur wird über `infra/main.bicep` orchestriert und in Module getrennt:

- Log Analytics Workspace (eigener Workspace im Stack)
- User Assigned Managed Identity
- Application Insights (an den neuen Workspace angebunden)
- Azure AI Search
- Azure OpenAI inkl. Deployments
- Azure Container Registry (ohne Admin User)
- RBAC Role Assignments für Managed Identity
- Container Apps Environment
- Container App (mit Managed Identity + Key Vault Secret References)

## Voraussetzungen

- Azure CLI (`az`) aktuell
- Bicep CLI (über `az bicep`)
- Rechte auf Resource Group `ingsoft-interwatt-azure-ai-resource-group`

## Deployment

### Validierung (What-If)

```bash
az deployment group what-if \
  --resource-group ingsoft-interwatt-azure-ai-resource-group \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam
```

### Deployment

```bash
az deployment group create \
  --resource-group ingsoft-interwatt-azure-ai-resource-group \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam
```

## Security-Entscheidungen

- ACR mit `adminUserEnabled: false`
- Container App Registry Pull ausschließlich über User Assigned Managed Identity (`AcrPull`)
- Keine Plaintext-Secrets in der Container App: nur Key Vault References
- Azure OpenAI mit `networkAcls.defaultAction: Deny`
- Azure OpenAI und AI Search `publicNetworkAccess` parametrisierbar
- Azure AI Search mit `disableLocalAuth: true` (nur AAD Auth)
- Defender for AI auf OpenAI aktiviert
- Container Apps Environment mit mTLS und Peer Traffic Encryption aktiviert

## Modulübersicht

```text
infra/
├── main.bicep
├── main.bicepparam
└── modules/
    ├── log-analytics.bicep
    ├── identity.bicep
    ├── monitoring.bicep
    ├── ai-search.bicep
    ├── openai.bicep
    ├── container-registry.bicep
    ├── container-apps-env.bicep
    ├── container-app.bicep
    └── rbac.bicep
```