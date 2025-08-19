locals {
  # Keep names short to satisfy Azure length rules
  prefix = "${var.project_name}"

  storage_primary_name   = lower(replace("${local.prefix}pri${random_integer.suffix.result}", "/[^a-z0-9]/", ""))
  storage_secondary_name = lower(replace("${local.prefix}sec${random_integer.suffix.result}", "/[^a-z0-9]/", ""))

  cdn_profile_name = "${local.prefix}-cdn"
  cdn_primary_ep   = "${local.prefix}-cdn-pri"
  cdn_secondary_ep = "${local.prefix}-cdn-sec"

  afd_profile_name  = "${local.prefix}-afd"
  afd_endpoint_name = "${local.prefix}-afd-ep"
  afd_origin_group  = "${local.prefix}-og"

  health_probe_path = "/index.html"
}
