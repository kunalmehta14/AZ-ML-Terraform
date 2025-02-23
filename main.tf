#################################
### INITIAL SETUP ENVIRONMENT ###
#################################

resource "azurerm_resource_group" "rg" {
  name     = var.resourcegroup
  location = var.location
  tags = var.resource_tags
}

resource "azurerm_application_insights" "app_insights" {
  name                = var.azappinsights
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags = var.resource_tags
}

# Create an Azure Key Vault for storing
# required secrets strings created via
# AI/ML environment
resource "azurerm_key_vault" "kv" {
  name                = var.azkeyvault.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = var.ARM_TENANT_ID
  sku_name            = var.azkeyvault.sku
  tags = var.resource_tags
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.azvnet.name
  address_space       = var.azvnet.address_prefixes
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.resource_tags
}

resource "azurerm_subnet" "snet01" {    
  name                 = var.azsnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.azsnet.address_prefixes
}

# Create an Storage account for storing all 
# required data files for ML/AI operations
resource "azurerm_storage_account" "sa" {
  name                     = var.azsa.name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = var.azsa.account_tier
  account_replication_type = var.azsa.account_replication_type
  tags = var.resource_tags
}

# Azure Container Registery
resource "azurerm_container_registry" "acr" {
  name                     = var.azacr.name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = var.azacr.sku
  admin_enabled            = true
}