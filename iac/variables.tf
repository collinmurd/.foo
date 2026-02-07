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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmCb99kUnodJfzv+9eCQcZppfbN5MGqW2EHtm+w78C+cWNwCstnz9b0XfaoLO1PdZaWxAs5KjP5405wNtkWCwKvq0hGvsIAw9noVJDHrYY/eo+YQyzmAsqw+17uvgPpnFr3UlETB4UckUNHvjaV4XT+Ff93Njpd2/VfsGGuy5/KkvDCV7KAIo5mRzHHgYLhIek0t4vH188v/rnw1JqTAdYevMy7zvcZtsOM9etKyMxGFeKlqjxotkZcVimvbUEkyktFhF0kOR5QZWeJT1QwsGEefHoU0yrlP2730Q9xu+ilzWFHD7Q35vyMd96Ta+3bVTyzDULKAQsLp88UDAoo6DB2cOtB12HSjv8GH7AylzNwzJoZPalJO1LyeAx7zbh8IYB8qGSnyXTY1QjUXYNWafw616B5J01TNJfhYP+IrhVY2dNI84QoYxoSMjgefd3+sbcshGzh1p8mrTvTGTde/NnfCQ/8/XB++lXUclx8NKqc49oX5nWOsV5ukBAHaj/Qxk="
}

variable "ssh_authorized_keys_groceries" {
  description = "Public SSH keys for groceries user instance access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCp1nwE/3twf4IP61TGPYgEQT3v6k7W3Xh3/O4TsJMBruRIkw5Q2uN8xInWidWaJwy9gzYVZ/ljL/xA9X1xUQvrp2wzjh9yxgP0Ur4422OSIbjc33NFh77ZZpb7kFJTclgcc7b4rD6OjaifMd1gcie0Dd3ynIqy3E/DPbkVr0d9/6wb2/9OqKn5cCfYBba+YA5MOl5DlCfivh+i2Zm9sdt8Io+cHR7zOiHxAatjnmqq6vG+UYwis8n1wwtlAcQbN44hHfmvJ7G0wkjSKegP8gmzNqZeSYRCSb9QMFa38f1fc9syd2vYKOBhIWoAJqUumEcsk+n9s+taLtQMzkjuvDPYGzN7awUxQ5vO5ihoBCS4qkioljqSQNWJW3SqNSgMZYwyzC6OvbuId2No6x44ns8hsWkGP14yErreyIKKsPzykyQg6rrIObNr3mLuu3uuDz/oZWfp1Ss+K9U3T4zXby8NNCwFJRxFHB0Uj6vXotkaKGDAseELPBtq9qc4Y+fmE00xxr2Dgp0OmDicLwyapCdtntod2ESBo6DxG6HNilEgMg9tOmo1XMmCi79dJhSaH0iAGW+s+cNkIUPeDVS2h4DBcRM7+D+T6Wbx0fuGMqYtaS1adgirij3mI/15E2urW/PfJaLiRvCuvar4rSbLVIBGEe0un+TbApRamrgzLlLQXQ=="
}
