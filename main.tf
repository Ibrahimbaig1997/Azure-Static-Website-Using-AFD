resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.primary_location
  tags     = var.tags
}

# ---------------------------
# Storage accounts (static site + versioning prerequisites for ORS)
# ---------------------------
resource "azurerm_storage_account" "primary" {
  name                     = local.storage_primary_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.primary_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"


  # ORS prerequisites (safe to keep even if replication is disabled)
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_storage_account_static_website" "primary" {
  storage_account_id = azurerm_storage_account.primary.id
  error_404_document = var.error_document
  index_document     = var.index_document
  depends_on         = [azurerm_storage_account.primary]
}

resource "azurerm_storage_account" "secondary" {
  name                     = local.storage_secondary_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.secondary_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"


  blob_properties {
    versioning_enabled = true


    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}
resource "azurerm_storage_account_static_website" "secondary" {
  storage_account_id = azurerm_storage_account.secondary.id
  error_404_document = var.error_document
  index_document     = var.index_document
  depends_on         = [azurerm_storage_account.secondary]
}

# Optional: object replication from $web (primary -> secondary)
# Requires both accounts to have versioning + change feed enabled (done above).
# resource "azurerm_storage_account_object_replication" "web_replication" {
#   count = var.enable_replication ? 1 : 0

#   source_storage_account_id      = azurerm_storage_account.primary.id
#   destination_storage_account_id = azurerm_storage_account.secondary.id

#   rule {
#     source_container_name         = "$web"
#     destination_container_name    = "$web"
#     # Optional: only copy new/changed blobs after a timestamp
#     # copy_blobs_modified_after   = "2025-01-01T00:00:00Z"
#     # Optional exclude prefixes
#     # filter_out_blobs_with_prefix = ["drafts/", "tmp/"]
#   }
# }

# # ---------------------------
# (previous parts same—resource group and storage accounts)

# ==============================
# Azure Front Door (Standard_AzureFrontDoor)
# ==============================
resource "azurerm_cdn_frontdoor_profile" "afd" {
  name                = local.afd_profile_name
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "afd_ep" {
  name                     = local.afd_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
}

resource "azurerm_cdn_frontdoor_origin_group" "afd_og" {
  name                     = local.afd_origin_group
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
  health_probe {
    interval_in_seconds = 30
    path                = "/${var.index_document}"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  session_affinity_enabled = false
}

# Origins point to storage static website endpoints
resource "azurerm_cdn_frontdoor_origin" "primary" {
  name                           = "primary-origin"
  certificate_name_check_enabled = false
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.afd_og.id

  host_name  = trim(replace(azurerm_storage_account.primary.primary_web_endpoint, "https://", ""), "/")
  http_port  = 80
  https_port = 443
  priority   = 1
  weight     = 100
  enabled    = true
}

resource "azurerm_cdn_frontdoor_origin" "secondary" {
  name                           = "secondary-origin"
  certificate_name_check_enabled = false
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.afd_og.id

  host_name  = trim(replace(azurerm_storage_account.secondary.primary_web_endpoint, "https://", ""), "/")
  http_port  = 80
  https_port = 443
  priority   = 2
  weight     = 100
  enabled    = true
}

resource "azurerm_cdn_frontdoor_route" "all" {
  name                          = "route-all"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.afd_ep.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.afd_og.id
  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.primary.id,
    azurerm_cdn_frontdoor_origin.secondary.id
  ]

  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "MatchRequest"
  link_to_default_domain = true

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    compression_enabled           = true
    content_types_to_compress     = ["text/html", "application/javascript", "text/css", "application/json"]
  }
}
