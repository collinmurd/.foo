# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}

# Internet Gateway
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Internet gateway-${var.vcn_display_name}"
  enabled        = true
}

# NAT Gateway
resource "oci_core_nat_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "NAT gateway-${var.vcn_display_name}"
  block_traffic  = false
}

# Service Gateway
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Service gateway-${var.vcn_display_name}"

  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}

# Route Table for Public Subnet
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "default route table for ${var.vcn_display_name}"

  route_rules {
    description       = "Route all internet traffic through Internet Gateway"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

# Route Table for Private Subnet
resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "route table for private subnet-${var.vcn_display_name}"

  route_rules {
    description       = "Route all internet traffic through NAT Gateway"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.main.id
  }

  route_rules {
    description       = "Route Oracle Services traffic through Service Gateway"
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.main.id
  }
}

# Security List for Public Subnet
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "Default Security List for ${var.vcn_display_name}"

  # Egress Rules
  egress_security_rules {
    description = "Allow all outbound traffic"
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Ingress Rules
  ingress_security_rules {
    description = "Allow SSH from anywhere"
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    description = "HTTP ingress"
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    description = "HTTPS ingress"
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      max = 443
      min = 443
    }
  }

  ingress_security_rules {
    description = "Allow ICMP for MTU negotiation"
    protocol    = "1"  # ICMP
    source      = "0.0.0.0/0"
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "Allow ICMP from VCN"
    protocol    = "1"  # ICMP
    source      = var.vcn_cidr_block
    stateless   = false

    icmp_options {
      type = 3
    }
  }
}

# Security List for Private Subnet
resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "security list for private subnet-${var.vcn_display_name}"

  # Egress Rules
  egress_security_rules {
    description = "Allow all outbound traffic"
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  egress_security_rules {
    description      = "Allow Oracle Services traffic"
    destination      = data.oci_core_services.all_services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"  # TCP
    stateless        = false
  }

  # Ingress Rules
  ingress_security_rules {
    description = "Allow SSH from VCN"
    protocol    = "6"  # TCP
    source      = var.vcn_cidr_block
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    description = "Allow ICMP for MTU negotiation"
    protocol    = "1"  # ICMP
    source      = "0.0.0.0/0"
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "Allow ICMP from VCN"
    protocol    = "1"  # ICMP
    source      = var.vcn_cidr_block
    stateless   = false

    icmp_options {
      type = 3
    }
  }
}

# Public Subnet
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "public subnet-${var.vcn_display_name}"
  dns_label                  = "sub08262316490"
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
}

# Private Subnet
resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "private subnet-${var.vcn_display_name}"
  dns_label                  = "sub08262316491"
  prohibit_internet_ingress  = true
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
}
