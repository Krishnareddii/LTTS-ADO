resource "azurerm_linux_virtual_machine" "myvm-Ltts" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  size                = "Standard_F2"
  }
}

resource "azurerm_resource_group" "TerraformExample01RG" { 
    name = TerraformExample01RG
    location = West US
    tags = {     
      InstanceType = Terraform_instance
       } 
  }