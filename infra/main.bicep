targetScope = 'resourceGroup'

@description('Environment name used for naming and tags.')
param environmentName string = 'dev'

@description('Primary location for West Europe resources.')
param location string = 'westeurope'

@description('Location for Germany West Central resources.')
param locationGermany string = 'germanywestcentral'

@description('Project name prefix used for consistent naming.')
param projectName string = 'ingsoft-interwatt'

@description('Global public network access default for services.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Public network access setting for Azure OpenAI.')
@allowed([
  'Enabled'
  'Disabled'
])
param openAiPublicNetworkAccess string = publicNetworkAccess

@description('Public network access setting for Azure AI Search.')
@allowed([
  'Enabled'
  'Disabled'
])
param searchPublicNetworkAccess string = publicNetworkAccess

@description('Container image tag to deploy.')
param containerImageTag string = 'latest'

@description('Log Analytics retention in days.')
@minValue(30)
param logAnalyticsRetentionDays int = 90

@description('Container image repository name inside ACR.')
param containerImageRepository string = 'interwatt-ai-chatbot-api'

@description('User assigned managed identity name.')
param identityName string = 'deployment-identity-user-ai-platform'

@description('Assignment restrictions object from the original export.')
param identityAssignmentRestrictions object = {}

@description('Application Insights name.')
param appInsightsName string = '${projectName}-ai-platform-application-insights'

@description('Azure AI Search service name.')
param searchName string = 'azureaixwikisearch'

@description('Azure OpenAI account name.')
param openAiName string = '${projectName}-azure-openai-instance'

@description('Container Registry name.')
param acrName string = 'ingsoftaiplattoform'

@description('Container Apps environment name.')
param containerAppsEnvironmentName string = 'managedEnvironment-ingsoftinterwat-a01c'

@description('Container App name.')
param containerAppName string = 'interwatt-ai-chatbot-api'

@description('Key Vault secret URL for Azure OpenAI key reference.')
param openAiKeyVaultSecretUrl string = ''

@description('Key Vault secret URL for Azure AI Search key reference.')
param searchKeyVaultSecretUrl string = ''

var tags = {
  Owner: 'Product Group IIW'
  Project: 'AI-Development'
  Environment: environmentName
}

module logAnalytics './modules/log-analytics.bicep' = {
  name: 'log-analytics-${environmentName}'
  params: {
    workspaceName: '${projectName}-ai-log-${environmentName}'
    location: location
    retentionInDays: logAnalyticsRetentionDays
    tags: tags
  }
}

module identity './modules/identity.bicep' = {
  name: 'identity-${environmentName}'
  params: {
    identityName: identityName
    location: location
    assignmentRestrictions: identityAssignmentRestrictions
    tags: tags
  }
  dependsOn: [
    logAnalytics
  ]
}

module monitoring './modules/monitoring.bicep' = {
  name: 'monitoring-${environmentName}'
  params: {
    applicationInsightsName: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.workspaceId
    tags: tags
  }
  dependsOn: [
    identity
  ]
}

module aiSearch './modules/ai-search.bicep' = {
  name: 'ai-search-${environmentName}'
  params: {
    searchName: searchName
    location: locationGermany
    publicNetworkAccess: searchPublicNetworkAccess
    tags: tags
  }
  dependsOn: [
    monitoring
  ]
}

module openAi './modules/openai.bicep' = {
  name: 'openai-${environmentName}'
  params: {
    openAiName: openAiName
    location: location
    publicNetworkAccess: openAiPublicNetworkAccess
    tags: tags
  }
  dependsOn: [
    aiSearch
  ]
}

module containerRegistry './modules/container-registry.bicep' = {
  name: 'container-registry-${environmentName}'
  params: {
    registryName: acrName
    location: locationGermany
    tags: tags
  }
  dependsOn: [
    openAi
  ]
}

module rbac './modules/rbac.bicep' = {
  name: 'rbac-${environmentName}'
  params: {
    principalId: identity.outputs.principalId
    principalResourceId: identity.outputs.identityId
    acrName: containerRegistry.outputs.registryName
    openAiName: openAi.outputs.openAiName
    searchName: aiSearch.outputs.searchName
  }
}

module containerAppsEnv './modules/container-apps-env.bicep' = {
  name: 'container-apps-env-${environmentName}'
  params: {
    environmentName: containerAppsEnvironmentName
    location: location
    logAnalyticsWorkspaceName: logAnalytics.outputs.workspaceName
    tags: tags
  }
  dependsOn: [
    rbac
  ]
}

module containerApp './modules/container-app.bicep' = {
  name: 'container-app-${environmentName}'
  params: {
    containerAppName: containerAppName
    location: location
    managedEnvironmentId: containerAppsEnv.outputs.managedEnvironmentId
    userAssignedIdentityResourceId: identity.outputs.identityId
    registryServer: containerRegistry.outputs.loginServer
    containerImageRepository: containerImageRepository
    containerImageTag: containerImageTag
    openAiKeyVaultSecretUrl: openAiKeyVaultSecretUrl
    searchKeyVaultSecretUrl: searchKeyVaultSecretUrl
    tags: tags
  }
}

output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.workspaceName
output applicationInsightsId string = monitoring.outputs.applicationInsightsId
output applicationInsightsConnectionString string = monitoring.outputs.connectionString
output identityResourceId string = identity.outputs.identityId
output identityPrincipalId string = identity.outputs.principalId
output aiSearchId string = aiSearch.outputs.searchId
output aiSearchEndpoint string = aiSearch.outputs.searchEndpoint
output openAiId string = openAi.outputs.openAiId
output openAiEndpoint string = openAi.outputs.openAiEndpoint
output containerRegistryId string = containerRegistry.outputs.registryId
output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
output containerAppsEnvironmentId string = containerAppsEnv.outputs.managedEnvironmentId
output containerAppId string = containerApp.outputs.containerAppId
output containerAppFqdn string = containerApp.outputs.containerAppFqdn
