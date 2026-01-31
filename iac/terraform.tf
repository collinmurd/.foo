# Terraform version and provider configuration
# OCI Provider version 7.32.0 (latest as of 2026-01-31)

terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.32.0"
    }
  }

  # OCI Object Storage backend for remote state
  # Stores state files in OCI Object Storage with state locking support
  backend "oci" {
    # Required
    bucket    = "terraform-state"
    namespace = "ax6bo5nrmnkl"
    key       = "infrastructure/terraform.tfstate"

    # Optional - Authentication will use:
    # 1. Environment variables (OCI_* variables), or
    # 2. ~/.oci/config file (default location)
    # 3. Uncomment below for explicit configuration:
    # tenancy_ocid     = var.tenancy_ocid
    # user_ocid        = var.user_ocid
    # fingerprint      = var.fingerprint
    # private_key_path = var.private_key_path
    # region           = var.region

    # Optional - Use OCI KMS for state encryption
    # kms_key_id = "ocid1.key.oc1.region.xxxxxxxxxxxxxx"

    # Optional - Workspace configuration
    # workspace_key_prefix = "envs"  # Default is "tf-state-env"
  }
}
