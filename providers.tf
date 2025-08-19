terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
        random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "YOUR_RESOURCE_GROUP"
    storage_account_name = "STORAGE ACCOUNT"
    container_name       = "CONTAINER"
    key                  = "FILENAME.tfstate"

  }
}

provider "azurerm" {
  features {}
  subscription_id = "YOUR SUB_ID"
}

