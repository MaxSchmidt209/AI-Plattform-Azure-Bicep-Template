@description('Application Insights resource name.')
param applicationInsightsName string

@description('Deployment location.')
param location string

@description('Resource ID of Log Analytics workspace.')
param workspaceResourceId string

@description('Common tags for all resources.')
param tags object

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceResourceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output applicationInsightsId string = applicationInsights.id
output connectionString string = applicationInsights.properties.ConnectionString
