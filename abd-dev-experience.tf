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
    Application = "Bottom Line Innovation"
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

resource "azurerm_subnet" "abd-de-subnet" {
  name = "abd-de-subnet"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  virtual_network_name = azurerm_virtual_network.abd-de-network.name
  address_prefix = "10.0.2.0/24"
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

  tags = {
    Environment = "Dev Experience"
  }
}

resource "azurerm_public_ip" "abd-de-ip" {
  name = "abd-de-ip"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  allocation_method = "Dynamic"

  tags = {
    Environment = "Dev Experience"
  }
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

  tags = {
    Environment = "Dev Experience"
  }
}

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

  tags = {
    Environment = "Dev Experience"
  }
}

resource "azurerm_virtual_machine" "abd-de-vm-01" {
  name = "abd-de-vm-01"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  network_interface_ids = [azurerm_network_interface.abd-de-nic.id]
  vm_size = "Standard_D2s_v3"

  storage_os_disk {
    name = "abd-de-vm-01-OS-disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04.0-LTS"
    version = "latest"
  }

  os_profile {
    computer_name = "vm01"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAocTmdfswVF5LZzWsr1fUNHesHo9Xb5/OOaA0DV96KYmy2kYP0KkG3gqvY9cMBcJ6cJYdsc563DN06BqQqaIp1e+SoVDuXIngACXlFotjidbsqoN+ffenqQKw3LjzjXmj6+IKWZEDt9gLtosxqIdizyPvTmAFiGsGQlhWeW/rWg2TPXvlFV4TZdmo12V/6stb3p6yQbqVcRhSFodoMSAhd99RlMJicTHhX+H5kIkRA7AOK1DDkDqIe4k66vwtud1qqhHuXbKvThg9mQtXuj6JUw3CDEs7V2IgepIN9RULyIMWh8oX4E5YHlqPVPQgz0wKApffnKESk8Rlpuo8HfwCgQ== shahn@ch12ldvdi227"
    }
  }

  boot_diagnostics {
    enabled = "true"
    storage_uri = azurerm_storage_account.abd-de-storage-acct.primary_blob_endpoint
  }

  tags = {
    Environment = "Dev Experience"
  }
}