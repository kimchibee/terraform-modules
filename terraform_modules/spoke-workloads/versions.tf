#--------------------------------------------------------------
# spoke-workloads - Spoke RG, VNet, Subnets, NSGs, APIM, OpenAI, AI Foundry
#--------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
