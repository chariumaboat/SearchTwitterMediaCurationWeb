variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "my_ip" {}

variable "all_allow" {
  default = "0.0.0.0/0"
}

# VCN
resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.header_var}-vcn"
  dns_label      = "${var.header_var}vcn"
}

# IGW
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.header_var}-igw"
  enabled        = true
}

# RTB
resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_ocid
  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
    destination       = var.all_allow
  }
  vcn_id       = oci_core_vcn.vcn.id
  display_name = "${var.header_var}-rtb"
}

# AZ
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Subnet
resource "oci_core_subnet" "subnet" {
  # https://docs.oracle.com/ja-jp/iaas/Content/API/SDKDocs/terraformbestpractices_topic-Availability_Domains.htm  
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")
  cidr_block          = var.subnet_cidr
  compartment_id      = var.compartment_ocid
  security_list_ids   = ["${oci_core_security_list.security_list.id}"]
  vcn_id              = oci_core_vcn.vcn.id

  display_name               = "${var.header_var}-subnet"
  dns_label                  = "${var.header_var}subnet"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.route_table.id
}

# FW
resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_ocid
  egress_security_rules {
    destination = var.all_allow
    protocol    = "all"
    stateless   = false
  }
  ingress_security_rules {
    source    = var.my_ip
    protocol  = "6"
    stateless = false
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    source    = var.my_ip
    protocol  = "6"
    stateless = false
    tcp_options {
      max = "5432"
      min = "5432"
    }
  }
  ingress_security_rules {
    source    = var.all_allow
    protocol  = "6"
    stateless = false
    tcp_options {
      max = "80"
      min = "80"
    }
  }
  ingress_security_rules {
    source    = var.all_allow
    protocol  = "6"
    stateless = false
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  vcn_id       = oci_core_vcn.vcn.id
  display_name = "${var.header_var}-sw"
}
