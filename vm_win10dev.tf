resource "azurerm_public_ip" "abd-de-ip-win10dev" {
  name = "abd-de-ip-win10dev"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  allocation_method = "Dynamic"

  tags = var.abd-de-tags
}

resource "azurerm_network_interface" "abd-de-nic-win10dev" {
  name = "abd-de-nic-win10dev"
  location = "northcentralus"
  resource_group_name = azurerm_resource_group.abd-de-rg.name
  network_security_group_id = azurerm_network_security_group.abd-de-nsg.id

  ip_configuration {
    name = "abd-de-nic-config"
    subnet_id = azurerm_subnet.abd-de-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.abd-de-ip-win10dev.id
  }

  tags = var.abd-de-tags
}

resource "azurerm_virtual_machine" "abd-de-vm-win10dev" {
    name = "abd-de-vm-win10dev"
    location = "northcentralus"
    resource_group_name = azurerm_resource_group.abd-de-rg.name
    network_interface_ids = [azurerm_network_interface.abd-de-nic-win10dev.id]
    vm_size = "Standard_D8s_v3"

    storage_os_disk {
        name = "abd-de-vm-win10dev-OS-disk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "MicrosoftWindowsDesktop"
        offer = "Windows-10"
        sku = "19h2-pro"
        version = "latest"
    }

    os_profile {
        computer_name  = "win10dev"
        admin_username = "azureuser"
        admin_password = "a!!y0urba53"
    }

    os_profile_windows_config {
        enable_automatic_upgrades = true
        provision_vm_agent = true
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.abd-de-storage-acct.primary_blob_endpoint
    }

    tags = var.abd-de-tags
}