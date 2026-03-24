#-------------------------------------------------------------------------------
# VNet — AVM avm-res-network-virtualnetwork (AzAPI + azurerm)
#-------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.9.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0, < 5.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.0, < 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3.0"
    }
  }
}
