# 1. Megmondjuk a Terraformnak, hogy az Azure-ral fogunk dolgozni
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. Létrehozunk egy Resource Groupot (csoportot), amibe a gépek kerülnek
resource "azurerm_resource_group" "rg" {
  name     = "rg-windows-demok"
  location = "West Europe"
}

# 3. Létrehozzuk a virtuális hálózatot (VNet), ami a gépek "alapja"
resource "azurerm_virtual_network" "vnet" {
  name                = "windows-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 4. Létrehozzuk az alhálózatot (Subnet)
resource "azurerm_subnet" "subnet" {
  name                 = "windows-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 5. Létrehozzuk a hálózati kártyákat mind a 3 géphez (itt jön be a mágikus "count = 3")
resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "win-nic-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                           = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 6. Maguk a Windows 10-es virtuális gépek (a count = 3 miatt egyszerre hármat épít fel!)
resource "azurerm_windows_virtual_machine" "win_vm" {
  count               = 3
  name                = "winvm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Ez egy olcsó, tesztelésre való gépmeret
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd12345!" # Élesben ilyet ne használj, ez csak teszt jelszó!

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "win10-22h2-pro" # Windows 10 Pro kiadás
    version   = "latest"
  }
}
