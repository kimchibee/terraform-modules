#-------------------------------------------------------------------------------
# Log Analytics Workspace 모듈 - Provider 요구 사항
#-------------------------------------------------------------------------------
# 공식 AVM 모듈과 동일: Terraform >= 1.9
terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}
