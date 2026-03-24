#-------------------------------------------------------------------------------
# Storage Account — AVM 및 Provider (avm-res-storage-storageaccount 요구 사항 정렬)
#-------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.9.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}
