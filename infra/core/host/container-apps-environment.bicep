param name string
param location string = resourceGroup().location
param tags object = {}

param logAnalyticsWorkspaceName string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource redis 'Microsoft.App/containerApps@2023-04-01-preview' = {
  name: 'redis'
  location: location
  tags: tags
  properties: {
    environmentId: containerAppsEnvironment.id
    configuration: {
      service: {
          type: 'redis'
      }
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

output defaultDomain string = containerAppsEnvironment.properties.defaultDomain
output name string = containerAppsEnvironment.name
