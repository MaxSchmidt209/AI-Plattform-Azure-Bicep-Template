@description('Principal ID of the user assigned managed identity.')
param principalId string

@description('Resource ID of the user assigned managed identity.')
param principalResourceId string

@description('Azure Container Registry resource name.')
param acrName string

@description('Azure OpenAI account resource name.')
param openAiName string

@description('Azure AI Search resource name.')
param searchName string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource openAi 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: openAiName
}

resource aiSearch 'Microsoft.Search/searchServices@2025-05-01' existing = {
  name: searchName
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, principalResourceId, 'acr-pull')
  scope: acr
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  }
}

resource openAiUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAi.id, principalResourceId, 'openai-user')
  scope: openAi
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  }
}

resource searchDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiSearch.id, principalResourceId, 'search-data-reader')
  scope: aiSearch
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1407120a-92aa-4202-b7e9-c0e197c71c8f')
  }
}

output acrPullRoleAssignmentId string = acrPullRoleAssignment.id
output openAiUserRoleAssignmentId string = openAiUserRoleAssignment.id
output searchDataReaderRoleAssignmentId string = searchDataReaderRoleAssignment.id
