resource "oci_core_instance" "instance" {
  count = "1"
  # https://docs.oracle.com/ja-jp/iaas/Content/API/SDKDocs/terraformbestpractices_topic-Availability_Domains.htm
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "${var.header_var}-instance"
  create_vnic_details {
    subnet_id = oci_core_subnet.subnet.id
  }
  source_details {
    source_id   = var.instance_image_ocid[var.region]
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = file("./id_rsa.pub")
    user_data           = base64encode(file("./user_data.tpl"))
  }
}

## https://docs.oracle.com/en-us/iaas/images/
variable "instance_image_ocid" {
  type = map(string)
  default = {
    # CensOs
    #ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaarbv25hiqjivdj2rn5vvlkp3glxcn3zai4zxhy44xodqhsf6czapa"
    # ubuntu
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaadeswedg2atub26mnfyu2wbqrjigremlvcf4neoluz4jumq3wawaq"
  }
}

variable "region" {
  default = "ap-tokyo-1"
}

output "ip" {
  value = oci_core_instance.instance[0].public_ip
}
