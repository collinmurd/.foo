# IAM Dynamic Group and Policy for Instance Access

# Dynamic Group for the groceries instance
# Allows the instance to authenticate and use OCI services
resource "oci_identity_dynamic_group" "groceries" {
  compartment_id = var.compartment_id
  name           = "groceries"
  description    = "Dynamic group for groceries compute instance"

  # Matching rule - matches the specific instance
  # This will be updated automatically to match the new instance ID
  matching_rule = "Any {All {instance.id = '${oci_core_instance.main.id}'}}"
}

# Policy granting permissions to the dynamic group
resource "oci_identity_policy" "groceries_instance" {
  compartment_id = var.compartment_id
  name           = "groceries-instance"
  description    = "Access for groceries instances"

  # Policy statements defining what the instance can do
  statements = [
    "Allow dynamic-group 'Default'/'${oci_identity_dynamic_group.groceries.name}' to use secret-family in tenancy",
    "Allow dynamic-group 'Default'/'${oci_identity_dynamic_group.groceries.name}' to use generative-ai-chat in tenancy",
  ]
}
