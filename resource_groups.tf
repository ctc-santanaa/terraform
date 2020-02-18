resource "azurerm_resource_group" "abd-de-rg" {
  # Import from existing resource group
  # terraform import azurerm_resource_group azurerm_resource_group.abd-de-rg /subscriptions/378079de-70e6-423f-bf1a-93947a02ee38/resourceGroups/bottom-line-innovations-rg

  location = "northcentralus"
  name = "bottom-line-innovations-rg"
  tags = var.abd-de-tags
}