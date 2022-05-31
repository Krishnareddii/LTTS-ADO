# Configure the Microsoft Azure Provider
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
  
  subscription_id = "488407a5-b2e4-4437-a2df-ae3d974d0375"
  client_id       = "6c7d6690-1a39-4e83-9acc-97d884eccb45"
  client_secret   = var.client_secret
  tenant_id       = "df7b3572-e484-4fcf-a072-6edd5d73f11f"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup1"
    location = "${var.location_name[1]}"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "${var.vnet[2]}"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "${var.subnetid}"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = azurerm_resource_group.myterraformgroup.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "${var.netsecuritygroup}"
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

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

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "${var.nic}"
    location                  = azurerm_resource_group.myterraformgroup.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = azurerm_resource_group.myterraformgroup.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "${var.virtualmachine}"
    location              = azurerm_resource_group.myterraformgroup.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "${var.os_disk_name}"
        caching           = "${var.os_disk_caching}"
        storage_account_type = "${var.os_disk_storage}"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
   }
}
resource "azurerm_sql_server" "example" {
  name                         = "${var.mysqlserver}"
  resource_group_name          = azurerm_resource_group.myterraformgroup.name
  location                     = azurerm_resource_group.myterraformgroup.location
  version                      = "12.0"
  administrator_login          = "serverlogin"
  administrator_login_password = "S_123erverpassword"

  tags = {
    environment = "testing"
  }
}
resource "azurerm_sql_database" "example" {
  name                = "${var.mysqldatabase}"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  location            = azurerm_resource_group.myterraformgroup.location
  server_name         = azurerm_sql_server.example.name

  tags = {
    environment = "testing"
  }
}