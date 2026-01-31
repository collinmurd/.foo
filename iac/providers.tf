# OCI Provider Configuration
# Authenticates using standard OCI configuration

provider "oci" {
  # Authentication will use:
  # 1. Environment variables (OCI_* variables), or
  # 2. ~/.oci/config file (default location)
  # 3. Instance Principal (if running on OCI compute)

  # Optional: Uncomment and set these if not using standard config
  # region           = var.region
  # tenancy_ocid     = var.tenancy_ocid
  # user_ocid        = var.user_ocid
  # fingerprint      = var.fingerprint
  # private_key_path = var.private_key_path
}
