@description('Azure AI Search service name.')
param searchName string

@description('Deployment location.')
param location string

@description('Public network access setting for search.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

@description('Common tags for all resources.')
param tags object

resource searchService 'Microsoft.Search/searchServices@2025-05-01' = {
  name: searchName
  location: location
  tags: tags
  sku: {
    name: 'basic'
  }
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: publicNetworkAccess
    replicaCount: 1
    partitionCount: 1
    semanticSearch: 'free'
    hostingMode: 'Default'
  }
}

output searchId string = searchService.id
output searchName string = searchService.name
output searchEndpoint string = 'https://${searchService.name}.search.windows.net'
