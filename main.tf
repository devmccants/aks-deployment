# Configure Azure Source and Version
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Configure Resource Group (Virtual Network, Subnet, Network Interface, Linux Virtual Machine)
resource "azurerm_resource_group" "mac-rg" {
  name     = "mac-resources"
  location = "eastus"
}

resource "azurerm_virtual_network" "mac-vn" {
  name                = "mac-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mac-rg.location
  resource_group_name = azurerm_resource_group.mac-rg.name
}

resource "azurerm_subnet" "mac-sub" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.mac-rg.name
  virtual_network_name = azurerm_virtual_network.mac-vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "mac-nic" {
  name                = "mac-nic"
  location            = azurerm_resource_group.mac-rg.location
  resource_group_name = azurerm_resource_group.mac-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mac-sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "mac-linux" {
  name = "development-machine"
  resource_group_name = azurerm_resource_group.mac-rg.name
  location = azurerm_resource_group.mac-rg.location
  size = "Standard_F2"
  admin_username = var.admin_username
  admin_password = var.admin_password
  network_interface_ids = [
    
  ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }
  }

# Configure Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "mac-kube" {
  name                = "mac-aks1"
  location            = azurerm_resource_group.mac-rg.location
  resource_group_name = azurerm_resource_group.mac-rg.name
  dns_prefix          = "macasks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_V2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Development"
  }
} 