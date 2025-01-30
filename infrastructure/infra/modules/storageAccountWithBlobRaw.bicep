@description('Location of the data factory.')
param location string = resourceGroup().location

@description('Name of the Azure storage account')
param storageAccountName string

@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageAccount.name}/default/${blobContainerName}'
}

// ----------- outputs ------------
output id string = storageAccount.id
