# Availability Domain Data Source
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Compute Instance
resource "oci_core_instance" "main" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name  # AD-3
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  # Flexible shape configuration
  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  # Source details (boot volume from image)
  source_details {
    source_type             = "image"
    source_id               = var.instance_image_id
    boot_volume_size_in_gbs = var.instance_boot_volume_size_in_gbs
  }

  # Network configuration
  create_vnic_details {
    subnet_id                 = oci_core_subnet.public.id
    assign_public_ip          = true
    assign_private_dns_record = true
    display_name              = var.instance_display_name
    hostname_label            = var.instance_display_name
  }

  # Metadata (SSH keys and user data for initialization)
  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      ssh_authorized_keys           = var.ssh_authorized_keys
      ssh_authorized_keys_groceries = var.ssh_authorized_keys_groceries
    }))
  }

  # Agent configuration
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }

    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }

    plugins_config {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }

    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute RDMA GPU Monitoring"
    }

    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }

    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Auto-Configuration"
    }

    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Authentication"
    }

    plugins_config {
      desired_state = "ENABLED"
      name          = "Cloud Guard Workload Protection"
    }

    plugins_config {
      desired_state = "DISABLED"
      name          = "Block Volume Management"
    }

    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }

  # Availability configuration
  availability_config {
    is_live_migration_preferred = false
    recovery_action             = "RESTORE_INSTANCE"
  }

  # Launch options
  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = true
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
  }

  # Prevent accidental destruction
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,  # Ignore image updates
    ]
  }
}
