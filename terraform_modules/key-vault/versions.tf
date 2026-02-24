#-------------------------------------------------------------------------------
# Key Vault 모듈 - Provider 요구 사항
#-------------------------------------------------------------------------------
# AVM 0.7.3 기준: Terraform ~> 1.6, azurerm ~> 3.71
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71"
    }
  }
}
