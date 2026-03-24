#--------------------------------------------------------------
# monitoring-storage — 하위 모듈(storage-account, key-vault, private-endpoint) AVM 정렬
#--------------------------------------------------------------
terraform {
  required_version = ">= 1.9.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
