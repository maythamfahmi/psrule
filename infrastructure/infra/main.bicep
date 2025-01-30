targetScope = 'subscription'

// Parameters
@description('Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
@minLength(3)
@maxLength(4)
param environment string

@description('Deployment Location')
@allowed([
  'westeurope'
  'northeurope'
  'swedencentral'
])
param location string

@description('Solution Owner')
param owner string

param publicStorage bool = false

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-demo-ps-rule-${environment}'
  location: location
  tags: {
    Owner: owner
  }
}

module storageAccount './modules/storageAccountWithBlob.bicep' = {
  name: 'storage-deployment'
  scope: rg
  params: {
    name: 'sademopsrule${environment}'
    location: location
    tags: {
      Owner: owner
    }
    allowBlobPublicAccess: publicStorage
  }
}

// module storageAccountRaw './modules/storageAccountWithBlobRaw.bicep' = {
//   name: 'storage-raw-deployment'
//   scope: rg
//   params: {
//     storageAccountName: 'sademopsruleraw${environment}'
//     blobContainerName: 'default'
//     location: location
//   }
// }

output environment string = environment
