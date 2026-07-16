@description('Log Analytics workspace name.')
param workspaceName string

@description('Deployment location.')
param location string

@description('Retention period in days.')
@minValue(30)
param retentionInDays int

@description('Common tags for all resources.')
param tags object

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    retentionInDays: retentionInDays
    features: {
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
output customerId string = workspace.properties.customerId
