# Common configurations

variable "resource_name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "location" {
  description = "Azure geographical location where resources will be deployed"
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the resource group where Bastion will be deployed."
  type        = string
}

# Networking

variable "virtual_network_name" {
  description = "Virtual network where Bastion will be deployed"
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "Bastion subnet address prefix"
  type        = list(string)
  default     = ["10.0.3.0/27"]
}