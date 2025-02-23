
resource "azurerm_machine_learning_workspace" "mlw" {
  name                    = var.resourcegroup
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.app_insights.id
  key_vault_id            = azurerm_key_vault.kv.id
  storage_account_id      = azurerm_storage_account.sa.id
  public_network_access_enabled = true
  tags = var.resource_tags
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_machine_learning_compute_instance" "mlc01" {
  name                          = var.mlcompute.name
  machine_learning_workspace_id = azurerm_machine_learning_workspace.mlw.id
  virtual_machine_size          = var.mlcompute.virtual_machine_size
  authorization_type            = var.mlcompute.authorization_type
  ssh {
    public_key = var.mlcompute.ssh_key
  }
  subnet_resource_id = azurerm_subnet.snet01.id
  tags = var.resource_tags
}

resource "azurerm_machine_learning_compute_cluster" "mlcc01" {
  name                          = var.mlcompute.name
  location                      = var.location
  vm_priority                   = var.mlcompute.vm_priority
  vm_size                       = var.mlcompute.virtual_machine_size
  machine_learning_workspace_id = azurerm_machine_learning_workspace.mlw.id
  subnet_resource_id            = azurerm_subnet.snet01.id
  ssh {
    admin_username = var.mlcompute.ssh_admin_user
    key_value = var.mlcompute.ssh_key
  }
  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 1
    scale_down_nodes_after_idle_duration = "PT30S" # 30 seconds
  }
  identity {
    type = "SystemAssigned"
  }
  tags = var.resource_tags
}

resource "azurerm_storage_container" "const" {
  name                  = var.mlcontainer
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_machine_learning_datastore_blobstorage" "dsml"{
  name                  = var.mldatastore
  workspace_id          = azurerm_machine_learning_workspace.mlw.id
  storage_container_id  = azurerm_storage_container.const.resource_manager_id
  account_key           = azurerm_storage_account.sa.primary_access_key
  #tags = var.resource_tags
}

resource "azurerm_data_factory" "df" {
  name                = var.datafactory
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.resource_tags
}