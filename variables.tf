variable "project_name" {
  description = "Short name used in resource naming."
  type        = string
  default     = "globalstatic"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
  default     = "East US"
}

variable "secondary_location" {
  description = "Secondary Azure region"
  type        = string
  default     = "West Europe"
}

variable "enable_replication" {
  description = "Enable blob object replication from primary to secondary"
  type        = bool
  default     = true
}

variable "index_document" {
  description = "Static website index document"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Static website 404 error document"
  type        = string
  default     = "404.html"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "cdn_sku" {
  description = "Azure CDN SKU"
  type        = string
  default     = "Standard_Akamai"

}
