resource "azurerm_public_ip" "abd-de-ip-bitbucket" {
  name = "abd-de-ip-bitbucket"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  allocation_method = "Dynamic"

  tags = var.abd-de-tags
}

resource "azurerm_network_interface" "abd-de-nic-bitbucket" {
  name = "abd-de-nic-bitbucket"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  network_security_group_id = azurerm_network_security_group.abd-de-nsg.id

  ip_configuration {
    name = "abd-de-nic-config"
    subnet_id = azurerm_subnet.abd-de-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.abd-de-ip-bitbucket.id
  }

  tags = var.abd-de-tags
}

resource "azurerm_virtual_machine" "abd-de-vm-bitbucket" {
    name = "abd-de-vm-bitbucket"
    location = "northcentralus"
    resource_group_name = azurerm_resource_group.abd-de-rg.name
    network_interface_ids = [azurerm_network_interface.abd-de-nic-bitbucket.id]
    vm_size = "Standard_D2s_v3"

    storage_os_disk {
        name = "abd-de-vm-bitbucket-OS-disk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }

    os_profile {
        computer_name = "bitbucket"
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

    tags = var.abd-de-tags
}