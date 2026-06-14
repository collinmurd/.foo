# App data block volume
resource "oci_core_volume" "app_data" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
  compartment_id      = var.compartment_id
  display_name        = var.block_volume_display_name
  size_in_gbs         = var.block_volume_size_in_gbs

  lifecycle {
    # Keep persistent app data safe unless explicitly overridden.
    prevent_destroy = true
  }
}

# Attach app data volume to compute instance
resource "oci_core_volume_attachment" "app_data" {
  attachment_type = var.block_volume_attachment_type
  instance_id     = oci_core_instance.main.id
  volume_id       = oci_core_volume.app_data.id
  is_read_only    = false
  is_shareable    = false
}
