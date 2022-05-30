variable "RG_Name" {
  description = "Name of the Resource Group"
  type = string
  default = "RahamatRG"
}

variable "R_Location" {
   default = "eastus"
   description = "Location of the resource group"
}

variable "R_Vnet" {
  description = "Name of your Azure Virtual Network"
  default     = "RahmatVNet"
}

variable "R_Vnet_address" {
  description = "Address need to use for AZ Vnet"
  default     = ["10.0.0.0/16"]
}

variable "R_Vnet_subnets" {
  description = "Subnet for AZ Vnet"
  default     = "RahmatSnet"
}

variable "R_Vnet_subnets_address" {
  description = "Address prefix to use inside subnet"
  default = ["10.0.1.0/24"]
}

variable "R_SG" { 
 description = "Network Security Group"
 type = string
 default = "R_nsg"
}

variable "R_st_acc" { 
 description = "name of the storage account"
 type = string
 default = "rahamtstorageaccount"
}

variable "R_mysql_admin_login"{
 description = "Mysql admin username"
 type = string
 default = "Rmysqlusername"
}

variable "R_mysql_admin_password"{
 description = "Mysql admin password"
 type = string
 default = "Raham@123"
}

variable "mysql-sku-name"{
 description = "mysql sku name"
 type = string
 default = "B_Gen5_1"
}

variable "mysql-storage"{
 description = "mysql storage"
 type = string
 default = "5120"
}

variable "mysql-db"{
 description = "mysql dbname"
 type = string
 default = "Rahmat"
}

variable "R_mysql_server"{
 description = "mysql server"
 type = string
 default = "rahammysql"
}

variable "mysql-version"{
 description = "mysql version"
 type = string
 default = "8.0"
}
