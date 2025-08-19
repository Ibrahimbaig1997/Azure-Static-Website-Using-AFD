project_name        = "globalweb"
resource_group_name = "rg-global-static"
primary_location    = "East US"
secondary_location  = "West Europe"

index_document = "index.html"
error_document = "404.html"

enable_replication = true

tags = {
  env   = "prod"
  owner = "platform"
}
