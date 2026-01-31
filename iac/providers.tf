# OCI Provider Configuration
# Authenticates using standard OCI configuration

provider "oci" {
    tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaahj7lgknz3zmkz2tabqidllay6c5bjjfydenbwyevkc6jieaevekq"
    user_ocid        = "ocid1.user.oc1..aaaaaaaaq52t4lvabfpb37zcfo5bjc7xcahes4fnd2n2opslob6au7qqlysa"
    fingerprint      = "78:7f:79:f2:4f:7b:5f:a1:9e:a9:04:43:3b:78:f4:99"
    private_key_path = "~/.oci/oci_api_key.pem"
    region           = "us-chicago-1"
}
