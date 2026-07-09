# Output values for the infrastructure

# VCN Outputs
output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.main.id
}

output "vcn_cidr_block" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.main.cidr_blocks[0]
}

output "vcn_domain_name" {
  description = "Domain name for the VCN"
  value       = oci_core_vcn.main.vcn_domain_name
}

# Subnet Outputs
output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet"
  value       = oci_core_subnet.private.id
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway"
  value       = oci_core_nat_gateway.main.id
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway"
  value       = oci_core_service_gateway.main.id
}

# Compute Instance Outputs
output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.main.id
}

output "instance_display_name" {
  description = "Display name of the compute instance"
  value       = oci_core_instance.main.display_name
}

output "instance_public_ip" {
  description = "Public IP address of the compute instance"
  value       = oci_core_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the compute instance"
  value       = oci_core_instance.main.private_ip
}

output "instance_state" {
  description = "Current state of the compute instance"
  value       = oci_core_instance.main.state
}

# Monitoring Outputs
output "apm_domain_id" {
  description = "OCID of the APM domain"
  value       = oci_apm_apm_domain.main.id
}

output "apm_data_upload_endpoint" {
  description = "APM domain data upload endpoint — use this as the OTEL exporter endpoint for future app instrumentation"
  value       = oci_apm_apm_domain.main.data_upload_endpoint
}

output "alert_topic_id" {
  description = "OCID of the OCI Notifications topic for site alerts"
  value       = oci_ons_notification_topic.site_alerts.topic_id
}

output "instance_region" {
  description = "Region where the instance is running"
  value       = oci_core_instance.main.region
}

output "instance_availability_domain" {
  description = "Availability domain where the instance is running"
  value       = oci_core_instance.main.availability_domain
}

output "instance_shape" {
  description = "Shape of the compute instance"
  value       = oci_core_instance.main.shape
}

# Block Volume Outputs
output "block_volume_id" {
  description = "OCID of the application data block volume"
  value       = oci_core_volume.app_data.id
}

output "block_volume_attachment_id" {
  description = "OCID of the block volume attachment"
  value       = oci_core_volume_attachment.app_data.id
}

output "block_volume_device" {
  description = "Device path exposed by OCI for the attached block volume"
  value       = try(oci_core_volume_attachment.app_data.device, null)
}

# Ansible Inventory Output
output "ansible_inventory" {
  description = "Ansible inventory file content"
  value       = <<-EOT
[groceries_servers]
${oci_core_instance.main.display_name} ansible_host=${oci_core_instance.main.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[groceries_servers:vars]
ansible_python_interpreter=/usr/bin/python3
EOT
}
