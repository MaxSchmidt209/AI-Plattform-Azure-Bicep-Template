@description('Container App resource name.')
param containerAppName string

@description('Deployment location.')
param location string

@description('Managed environment resource ID.')
param managedEnvironmentId string

@description('User assigned identity resource ID used by the Container App.')
param userAssignedIdentityResourceId string

@description('ACR login server hostname.')
param registryServer string

@description('Container image repository path.')
param containerImageRepository string

@description('Container image tag.')
param containerImageTag string

@description('Key Vault URL for OpenAI key secret reference.')
param openAiKeyVaultSecretUrl string

@description('Key Vault URL for Search key secret reference.')
param searchKeyVaultSecretUrl string

@description('Key Vault URL for legacy registry password secret reference.')
param registryPasswordKeyVaultSecretUrl string

@description('Common tags for all resources.')
param tags object

resource containerApp 'Microsoft.App/containerApps@2025-02-02-preview' = {
  name: containerAppName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      activeRevisionsMode: 'Single'
      registries: [
        {
          server: registryServer
          identity: userAssignedIdentityResourceId
        }
      ]
      secrets: [
        {
          name: 'azureopenaikey'
          keyVaultUrl: openAiKeyVaultSecretUrl
          identity: userAssignedIdentityResourceId
        }
        {
          name: 'azuresearchkey'
          keyVaultUrl: searchKeyVaultSecretUrl
          identity: userAssignedIdentityResourceId
        }
        {
          name: 'reg-pswd'
          keyVaultUrl: registryPasswordKeyVaultSecretUrl
          identity: userAssignedIdentityResourceId
        }
      ]
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: '${registryServer}/${containerImageRepository}:${containerImageTag}'
          env: [
            {
              name: 'AZURE_OPENAI_KEY'
              secretRef: 'azureopenaikey'
            }
            {
              name: 'AZURE_SEARCH_KEY'
              secretRef: 'azuresearchkey'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

output containerAppId string = containerApp.id
output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
