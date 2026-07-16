@description('User assigned managed identity name.')
param identityName string

@description('Deployment location.')
param location string

@description('Assignment restrictions object from exported prototype.')
param assignmentRestrictions object = {}

@description('Common tags for all resources.')
param tags object

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: identityName
  location: location
  tags: tags
  properties: empty(assignmentRestrictions) ? {} : {
    assignmentRestrictions: assignmentRestrictions
  }
}

output identityId string = userAssignedIdentity.id
output principalId string = userAssignedIdentity.properties.principalId
output clientId string = userAssignedIdentity.properties.clientId
