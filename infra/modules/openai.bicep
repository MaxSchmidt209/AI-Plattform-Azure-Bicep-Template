@description('Azure OpenAI account name.')
param openAiName string

@description('Deployment location.')
param location string

@description('Public network access setting for Azure OpenAI.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

@description('Common tags for all resources.')
param tags object

@description('Deployment name for GPT-5.4 mini.')
param gptMiniDeploymentName string = 'gpt-5.4-mini-beispiel-fuer-julius'

@description('Deployment name for GPT-5.4 nano.')
param gptNanoDeploymentName string = 'gpt-5.4-nano'

@description('Deployment name for text-embedding-3-small.')
param embeddingDeploymentName string = 'text-embedding-3-small'

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: openAiName
  location: location
  kind: 'OpenAI'
  tags: tags
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAiName
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: publicNetworkAccess
  }
}

resource deploymentGptMini 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  name: gptMiniDeploymentName
  parent: openAiAccount
  sku: {
    name: 'GlobalStandard'
    capacity: 150
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5.4-mini'
      version: '1'
    }
    versionUpgradeOption: 'NoAutoUpgrade'
  }
}

resource deploymentGptNano 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  name: gptNanoDeploymentName
  parent: openAiAccount
  sku: {
    name: 'GlobalStandard'
    capacity: 250
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5.4-nano'
      version: '1'
    }
    versionUpgradeOption: 'NoAutoUpgrade'
  }
}

resource deploymentEmbedding 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  name: embeddingDeploymentName
  parent: openAiAccount
  sku: {
    name: 'GlobalStandard'
    capacity: 150
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-small'
      version: '1'
    }
    versionUpgradeOption: 'NoAutoUpgrade'
  }
}

resource defenderForAi 'Microsoft.CognitiveServices/accounts/defenderForAISettings@2025-04-01-preview' = {
  name: 'default'
  parent: openAiAccount
  properties: {
    state: 'Enabled'
  }
}

output openAiId string = openAiAccount.id
output openAiName string = openAiAccount.name
output openAiEndpoint string = openAiAccount.properties.endpoint
