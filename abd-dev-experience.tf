provider "azurerm" {
  # This is the "Non-Production Metaverse(Converted to EA)" subscription
  subscription_id = "378079de-70e6-423f-bf1a-93947a02ee38"
  version = "1.44"
}

resource "azurerm_resource_group" "abd-de-rg" {
  # Import from existing resource group
  # id = "/subscriptions/378079de-70e6-423f-bf1a-93947a02ee38/resourceGroups/bottom-line-innovations-rg"

  location = "northcentralus"
  name = "bottom-line-innovations-rg"
  tags = {
    Application = "Bottom Line Innovation",
    Department = "Alt Business Development"
  }
}

resource "azurerm_virtual_network" "abd-de-network" {
    name = "abd-de-network"
    address_space = ["10.0.0.0/16"]
    location = "northcentralus"
    resource_group_name = azurerm_resource_group.abd-de-rg.name

    tags = {
        Environment = "Dev Experience"
    }
}