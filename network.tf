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
  security_rule {
    name = "Port80"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Port8080"
    priority = 1003
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "8080"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Port7999"
    priority = 1004
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "7999"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Port3389_RDP"
    priority = 1005
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Port8000"
    priority = 1006
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "8000"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Port4646"
    priority = 1007
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "4646"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  tags = var.abd-de-tags
}