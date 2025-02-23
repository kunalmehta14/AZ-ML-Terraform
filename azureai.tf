# AzAPI AIServices
resource "azapi_resource" "AIServicesResource"{
  type = "Microsoft.CognitiveServices/accounts@2023-10-01-preview"
  name = "AIServicesResource${random_string.suffix.result}"
  location = var.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type = "SystemAssigned"
  }

  body = {
    name = "AIServicesResource${random_string.suffix.result}"
    properties = {
      #restore = true
      customSubDomainName = "${random_string.suffix.result}domain"
        apiProperties = {
            statisticsEnabled = false
        }
    }
    kind = "AIServices"
    sku = {
        name = var.azaisku
    }
    }

  response_export_values = ["*"]
  tags = var.resource_tags
}

# Azure AI Hub
resource "azapi_resource" "hub" {
  type = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name = var.ai_hub
  location = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      description = "This is my Azure AI hub"
      friendlyName = var.ai_hub
      storageAccount = azurerm_storage_account.sa.id
      keyVault = azurerm_key_vault.kv.id
      encryption = {
        status = "Enabled"
        keyVaultProperties = {
            keyVaultArmId = azurerm_key_vault.kv.id
            keyIdentifier = azurerm_key_vault.kv.id
        }
      }
    }
    kind = "hub"
  }
}

# Azure AI Project
resource "azapi_resource" "project" {
  type = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name = var.ai_project
  location = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      description = "This is my Azure AI PROJECT"
      friendlyName = var.ai_project
      hubResourceId = azapi_resource.hub.id
    }
    kind = "project"
  }
}

# AzAPI AI Services Connection
resource "azapi_resource" "AIServicesConnection" {
  type = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview"
  name = "Default_AIServices${random_string.suffix.result}"
  parent_id = azapi_resource.hub.id

  body = {
      properties = {
        category = "AIServices",
        target = azapi_resource.AIServicesResource.output.properties.endpoint,
        authType = "AAD",
        isSharedToAll = true,
        metadata = {
          ApiType = "Azure",
          ResourceId = azapi_resource.AIServicesResource.id
        }
      }
    }
  response_export_values = ["*"]
}