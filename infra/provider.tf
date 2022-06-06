provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region_name
}

# https://docs.oracle.com/ja-jp/iaas/Content/API/SDKDocs/terraformUsingObjectStore.htm
# terraform {
#   backend "http" {
#     address       = ""
#     update_method = "PUT"
#   }
# }
