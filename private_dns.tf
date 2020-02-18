resource "azurerm_private_dns_zone" "abd-de-azure-ctc" {
    name = "abd-de.azure.ctc"
    resource_group_name = azurerm_resource_group.abd-de-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "abd-de-azure-ctc-link" {
    name = "abd-de-azure-ctc-link"
    resource_group_name = azurerm_resource_group.abd-de-rg.name
    private_dns_zone_name = azurerm_private_dns_zone.abd-de-azure-ctc.name
    virtual_network_id = azurerm_virtual_network.abd-de-network.id
    registration_enabled = true
}