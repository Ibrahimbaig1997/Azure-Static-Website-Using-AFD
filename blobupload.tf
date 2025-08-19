# Upload files to primary storage account
resource "azurerm_storage_blob" "primary_index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.primary.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/index.html"
  content_type           = "text/html"
}

resource "azurerm_storage_blob" "primary_404" {
  name                   = "404.html"
  storage_account_name   = azurerm_storage_account.primary.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/404.html"
  content_type           = "text/html"
}

# Upload files to secondary storage account
resource "azurerm_storage_blob" "secondary_index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.secondary.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/index.html"
  content_type           = "text/html"
}

resource "azurerm_storage_blob" "secondary_404" {
  name                   = "404.html"
  storage_account_name   = azurerm_storage_account.secondary.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/404.html"
  content_type           = "text/html"
}
