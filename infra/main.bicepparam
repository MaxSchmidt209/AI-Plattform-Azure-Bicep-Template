using './main.bicep'

param environmentName = 'dev'
param location = 'westeurope'
param locationGermany = 'germanywestcentral'
param projectName = 'ingsoft-interwatt'
param publicNetworkAccess = 'Disabled'
param openAiPublicNetworkAccess = 'Enabled'
param searchPublicNetworkAccess = 'Enabled'
param containerImageTag = 'latest'
param logAnalyticsRetentionDays = 90
param openAiKeyVaultSecretUrl = ''
param searchKeyVaultSecretUrl = ''
