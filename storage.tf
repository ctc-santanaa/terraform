resource "random_id" "abd-de-random-id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.abd-de-rg.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "abd-de-storage-acct" {
  name = format("diag%S", random_id.abd-de-random-id.hex)
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  location = "northcentralus"
  account_replication_type = "LRS"
  account_tier = "Standard"

  tags = var.abd-de-tags
}