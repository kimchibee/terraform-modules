#--------------------------------------------------------------
# shared-services - Provider 선언
# Log Analytics Solutions, Action Group, Dashboard
#--------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}
