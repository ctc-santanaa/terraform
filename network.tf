resource "azurerm_virtual_network" "abd-de-network" {
  name = "abd-de-network"
  address_space = ["10.129.0.0/16"]
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name

  tags = var.abd-de-tags
}

resource "azurerm_subnet" "abd-de-subnet" {
  name = "abd-de-subnet"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  virtual_network_name = azurerm_virtual_network.abd-de-network.name
  address_prefix = "10.129.2.0/24"
}

resource "azurerm_network_security_group" "abd-de-nsg" {
  name = "abd-de-nsg"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name

  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  tags = var.abd-de-tags
}

resource "azurerm_public_ip" "abd-de-ip" {
  name = "abd-de-ip"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  allocation_method = "Dynamic"

  tags = var.abd-de-tags
}

resource "azurerm_network_interface" "abd-de-nic" {
  name = "abd-de-nic"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  network_security_group_id = azurerm_network_security_group.abd-de-nsg.id

  ip_configuration {
    name = "abd-de-nic-config"
    subnet_id = azurerm_subnet.abd-de-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.abd-de-ip.id
  }

  tags = var.abd-de-tags
}