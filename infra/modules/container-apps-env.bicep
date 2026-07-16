@description('Container Apps environment name.')
param environmentName string

@description('Deployment location.')
param location string

@description('Log Analytics workspace name for Container Apps diagnostics.')
param logAnalyticsWorkspaceName string

@description('Common tags for all resources.')
param tags object

var workspaceResourceId = resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)
var workspaceSharedKeys = listKeys(workspaceResourceId, '2023-09-01')

resource managedEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(workspaceResourceId, '2023-09-01').customerId
        sharedKey: workspaceSharedKeys.primarySharedKey
      }
    }
    peerAuthentication: {
      mtls: {
        enabled: true
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: true
      }
    }
    zoneRedundant: false
  }
}

output managedEnvironmentId string = managedEnvironment.id
