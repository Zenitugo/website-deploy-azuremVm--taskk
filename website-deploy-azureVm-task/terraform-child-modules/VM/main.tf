# Create a public Ip address that will be attached to the virtual machine
resource "azurerm_public_ip" "public-ip" {
  name                         = "${var.name}-publicip"
  resource_group_name          = var.rg-name
  location                     = var.rg-location
  allocation_method            = var.allocation_method
}


######################################################################
######################################################################

# Create a network interface to manage the VM's network
resource "azurerm_network_interface" "nic" {
  name                            = "${var.name}-nic"
  location                        = var.rg-location
  resource_group_name             = var.rg-name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[1]
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }
}


########################################################################
########################################################################

# Create network security group
resource "azurerm_network_security_group" "sg" {
  name                = "${var.name}-sg"
  location            = var.rg-location
  resource_group_name = var.rg-name

  security_rule {
    name                       = "tls"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }

  security_rule {
    name                       = "tls"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "HTTP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_network_interface.nic.private_ip_address
  }
}


########################################################################################
########################################################################################

# Create a network interface security group association
resource "azurerm_network_interface_security_group_association" "nic-sg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

##########################################################################################
#########################################################################################


# Create the azure VM
resource "azurerm_linux_virtual_machine" "linuxVm" {
  name                = "${var.name}-linuxVm"
  resource_group_name = var.rg-name
  location            = var.rg-location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}


##############################################################################
##############################################################################

# Copy files to desired path an install nginx
resource "null_resource" "web" {
  provisioner "file" {
    source      = var.source_file_path
    destination = var.destination_file_path
    }


    connection {
      type     = "ssh"
      user     = "adminuser"
      host     = azurerm_public_ip.public-ip.ip_address
    }
  

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2",
      "sudo cp ${var.destination_file_path}/* /var/www/html/"
    ]
    
    connection {
      type     = "ssh"
      user     = "adminuser"
      host     = azurerm_public_ip.public-ip.ip_address
    }
  }
}




