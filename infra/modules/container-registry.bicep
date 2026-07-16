@description('Azure Container Registry name.')
param registryName string

@description('Deployment location.')
param location string

@description('Common tags for all resources.')
param tags object

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
    }
  }
}

output registryId string = registry.id
output registryName string = registry.name
output loginServer string = registry.properties.loginServer
