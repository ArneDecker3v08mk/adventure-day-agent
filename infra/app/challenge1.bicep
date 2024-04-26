param name string
param location string = resourceGroup().location
param tags object = {}

@minLength(1)
@description('Openai API key for the API to use.')
param openaiApiKey string

@minLength(1)
@description('Openai API Endpoint for the API to use.')
param openaiEndpoint string

@minLength(1)
@description('Name of the OpenAI Completion model deployment name.')
param completionDeploymentName string

param exists bool
param identityName string
param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param serviceName string = 'challenge1'
param imageName string

resource apiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module app '../core/host/container-app-upsert.bicep' = {
  name: '${serviceName}-container-app'
  params: {
    name: name
    location: location
    imageName: imageName
    tags: union(tags, { 'azd-service-name': serviceName })
    identityName: identityName
    exists: exists
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    env: [
      {
        name: 'AZURE_CLIENT_ID'
        value: apiIdentity.properties.clientId
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
      {
        name: 'AZURE_OPENAI_API_KEY'
        value: openaiApiKey
      }
      {
        name: 'AZURE_OPENAI_ENDPOINT'
        value: openaiEndpoint
      }
      {
        name: 'AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME'
        value: completionDeploymentName
      }
      {
        name: 'AZURE_OPENAI_VERSION'
        value: '2024-02-01'
      }
      {
        name: 'OPENAI_API_TYPE'
        value: 'azure'
      }
    ]
    targetPort: 80
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

output SERVICE_API_IDENTITY_PRINCIPAL_ID string = apiIdentity.properties.principalId
output SERVICE_API_NAME string = app.outputs.name
output SERVICE_API_URI string = app.outputs.uri
output SERVICE_API_IMAGE_NAME string = app.outputs.imageName