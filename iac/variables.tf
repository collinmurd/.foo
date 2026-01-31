# Input variables for Oracle Cloud Infrastructure

# Compartment Configuration
variable "compartment_id" {
  description = "The OCID of the compartment where resources will be created"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaahj7lgknz3zmkz2tabqidllay6c5bjjfydenbwyevkc6jieaevekq"
}

# Region Configuration
variable "region" {
  description = "The OCI region where resources will be created"
  type        = string
  default     = "us-chicago-1"
}

# VCN Configuration
variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_display_name" {
  description = "Display name for the VCN"
  type        = string
  default     = "groceries"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN"
  type        = string
  default     = "groceries"
}

# Subnet Configuration
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Compute Instance Configuration
variable "instance_display_name" {
  description = "Display name for the compute instance"
  type        = string
  default     = "groceries-2"
}

variable "instance_shape" {
  description = "Shape for the compute instance"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs for the instance"
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory in GB for the instance"
  type        = number
  default     = 6
}

variable "instance_boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GB"
  type        = number
  default     = 50
}

# Image Configuration - Ubuntu 22.04 ARM
variable "instance_image_id" {
  description = "OCID of the image to use for the instance (Ubuntu 22.04 ARM)"
  type        = string
  default     = "ocid1.image.oc1.us-chicago-1.aaaaaaaamaljxueclulcdsva5klc4mmflt7mkcjiymhok6lvn6o63ks4wnsa"
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys for instance access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmCb99kUnodJfzv+9eCQcZppfbN5MGqW2EHtm+w78C+cWNwCstnz9b0XfaoLO1PdZaWxAs5KjP5405wNtkWCwKvq0hGvsIAw9noVJDHrYY/eo+YQyzmAsqw+17uvgPpnFr3UlETB4UckUNHvjaV4XT+Ff93Njpd2/VfsGGuy5/KkvDCV7KAIo5mRzHHgYLhIek0t4vH188v/rnw1JqTAdYevMy7zvcZtsOM9etKyMxGFeKlqjxotkZcVimvbUEkyktFhF0kOR5QZWeJT1QwsGEefHoU0yrlP2730Q9xu+ilzWFHD7Q35vyMd96Ta+3bVTyzDULKAQsLp88UDAoo6DB2cOtB12HSjv8GH7AylzNwzJoZPalJO1LyeAx7zbh8IYB8qGSnyXTY1QjUXYNWafw616B5J01TNJfhYP+IrhVY2dNI84QoYxoSMjgefd3+sbcshGzh1p8mrTvTGTde/NnfCQ/8/XB++lXUclx8NKqc49oX5nWOsV5ukBAHaj/Qxk= collin@DESKTOP-29NFFDK"
}
