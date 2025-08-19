output "primary_storage_account" {
  value = azurerm_storage_account.primary.name
}

output "secondary_storage_account" {
  value = azurerm_storage_account.secondary.name
}

# output "primary_static_website_url" {
#   value = azurerm_storage_account.primary.primary_web_endpoint
# }

# output "secondary_static_website_url" {
#   value = azurerm_storage_account.secondary.primary_web_endpoint
# }

# output "cdn_primary_hostname" {
#   value = "${azurerm_cdn_endpoint.cdn_primary.name}.azureedge.net"
# }

# output "cdn_secondary_hostname" {
#   value = "${azurerm_cdn_endpoint.cdn_secondary.name}.azureedge.net"
# }

# output "afd_endpoint_hostname" {
#   value = azurerm_cdn_frontdoor_endpoint.afd_ep.host_name
# }

# output "afd_default_url" {
#   value = "https://${azurerm_cdn_frontdoor_endpoint.afd_ep.host_name}"
# }
