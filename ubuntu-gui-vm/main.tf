provider "azurerm" {
  features {}
}

# Erőforráscsoport az East US régióban
resource "azurerm_resource_group" "rg" {
  name     = "teszgep-csoport"
  location = "eastus" 
}

resource "azurerm_virtual_network" "vnet" {
  name                = "linux-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "linux-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "linux-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "linux-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "193.110.63.36/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "193.110.63.36/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "linux-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                  = "teszgep"
  computer_name         = "teszgep"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_D2s_v3"
  admin_username        = "azureuser"
  admin_password        = "Password1234"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y xfce4 xfce4-goodies xrdp
    systemctl enable xrdp
    systemctl start xrdp
    echo "xfce4-session" > /home/azureuser/.xsession
    chown azureuser:azureuser /home/azureuser/.xsession
    echo "xfce4-session" > /etc/skel/.xsession
    sed -i.bak '/fi/a xfce4-session' /etc/xrdp/startwm.sh
    systemctl restart xrdp
  EOF
  )
}

output "public_ip_address" {
  value = azurerm_public_ip.pip.ip_address
}