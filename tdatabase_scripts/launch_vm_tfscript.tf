locals {  
  resource_group_name = element(coalescelist(azurerm_resource_group.tempgroup.*.name, [""]), 0)
  location            = element(coalescelist(azurerm_resource_group.tempgroup.*.location, [""]), 0)
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "tempgroup" {
    name     = var.RG_Name
    location = var.R_Location

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "tempnetwork" {
    name                = var.R_Vnet
    address_space       = var.R_Vnet_address
    location            = local.location
    resource_group_name = azurerm_resource_group.tempgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "terraformtempsubnet" {
    name                 = var.R_Vnet_subnets
    resource_group_name  = local.resource_group_name
    virtual_network_name = azurerm_virtual_network.tempnetwork.name
    address_prefixes       = var.R_Vnet_subnets_address
}

# Create public IPs
resource "azurerm_public_ip" "terraformtemppublicip" {
    name                         = "myPublicIP"
    location                     = local.location
    resource_group_name          = azurerm_resource_group.tempgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "mytempnsg" {
    name                = var.R_SG
    location            = local.location
    resource_group_name = azurerm_resource_group.tempgroup.name
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

    tags = {
        environment = "Terraform Demo"
    }
}


resource "azurerm_storage_account" "storage_account" {
  name                     = var.R_st_acc
  resource_group_name      = azurerm_resource_group.tempgroup.name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mysql_server" "mysql-server" {
  name                         = var.R_mysql_server
  resource_group_name          = azurerm_resource_group.tempgroup.name
  location                     = local.location
  version                      = var.mysql-version
  administrator_login          = var.R_mysql_admin_login
  administrator_login_password = var.R_mysql_admin_password
  sku_name       = var.mysql-sku-name
  ssl_enforcement_enabled = true
  storage_mb = var.mysql-storage
  auto_grow_enabled = true
  public_network_access_enabled = true
  backup_retention_days = 7

}

resource "azurerm_mysql_database" "sqldb" {
  name           = var.mysql-db
  resource_group_name = azurerm_resource_group.tempgroup.name
  server_name    = azurerm_mysql_server.mysql-server.name
  collation      = "utf8_unicode_ci"
  charset = "utf8"

}

output "mysql-server"{
 value = azurerm_mysql_server.mysql-server
 sensitive = true
}
