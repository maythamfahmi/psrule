@minLength(3)
@maxLength(24)
@description('Required. Name of the Storage Account. Must be lower-case.')
param name string

@description('Optional. Location for all resources.')
param location string

@description('Tags')
param tags object

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
@description('Optional. Type of Storage Account to create.')
param kind string = 'StorageV2'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
@description('Optional. Storage Account Sku Name.')
param skuName string = 'Standard_GRS'

@description('Container name')
param saContainerName string = 'default'

@allowed([
  'Premium'
  'Hot'
  'Cool'
])
@description('Conditional. Required if the Storage Account kind is set to BlobStorage. The access tier is used for billing. The "Premium" access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.')
param accessTier string = 'Hot'

@description('Allow IP access')
param AllowedIps object[] = []

@description('Allow VNET access')
param subnetIds object[] = []

@description('Optional. Set if the storage account is accessible from the public internet. Default is false')
param allowBlobPublicAccess bool = false

@description('Log Analytics Workspace Id')
param logAnalyticsWorkspaceId string = ''

@description('User Assigned Identity Id')
param userAssignedId string = ''

@description('Container Delete Retention Policy')
param containerDeleteRetentionPolicy int = 7

@description('Delete Retention Policy')
param deleteRetentionPolicy int = 7

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  identity: empty(userAssignedId)
    ? null
    : {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${userAssignedId}': {}
        }
      }
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: subnetIds
      ipRules: AllowedIps
    }
    supportsHttpsTrafficOnly: true
  }
  tags: tags
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: deleteRetentionPolicy
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: containerDeleteRetentionPolicy
    }
  }
  resource container 'containers' = {
    name: saContainerName
  }
}

resource blobMonitoring 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${blobService.name}-logging'
  scope: blobService
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource saMonitoring 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${name}-logging'
  scope: storageAccount
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

@description('The resource ID of the deployed storage account.')
output resourceId string = storageAccount.id

@description('The name of the deployed storage account.')
output name string = storageAccount.name

@description('The resource group of the deployed storage account.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = storageAccount.location
