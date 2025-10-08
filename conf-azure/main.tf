# -----------------------
# 1️⃣ Resource Group
# -----------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-students"
  location = "France Central"
}

# -----------------------
# 2️⃣ Réseau + Sous-réseau
# -----------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-students"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# -----------------------
# 3️⃣ Groupe de sécurité réseau (NSG)
# -----------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-students"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# -----------------------
# 4️⃣ Interfaces réseau (sans IP publique)
# -----------------------
resource "azurerm_network_interface" "vm1_nic" {
  name                = "vm1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "vm2_nic" {
  name                = "vm2-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# -----------------------
# 5️⃣ Association NSG
# -----------------------
resource "azurerm_network_interface_security_group_association" "vm1_assoc" {
  network_interface_id      = azurerm_network_interface.vm1_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "vm2_assoc" {
  network_interface_id      = azurerm_network_interface.vm2_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# -----------------------
# 6️⃣ Machines virtuelles Debian 12
# -----------------------
variable "ssh_public_key" {
  description = "Chemin vers ta clé publique SSH"
  default     = "~/.ssh/id_rsa.pub"
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "debian-vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm1_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key)
  }

  os_disk {
    name                 = "debian-vm1-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "debian-vm2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm2_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key)
  }

  os_disk {
    name                 = "debian-vm2-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }
}
