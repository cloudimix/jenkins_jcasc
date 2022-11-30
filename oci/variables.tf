variable "instance-ARM_source_image_id" { default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaj6g2lci5ed7nfhk46olwkhmwkzrobyo3jntnhkk7fnm2vqflorna" }
variable "region" { default = "eu-frankfurt-1" }
variable "compartment_ocid" { default = "ocid1.tenancy.oc1..aaaaaaaahtactnba6jjmlnozlgyi3nkzupcl2hu6ymsuw6bplpq3rjrsmlqa" }
variable "tenancy_ocid" { default = "ocid1.tenancy.oc1..aaaaaaaahtactnba6jjmlnozlgyi3nkzupcl2hu6ymsuw6bplpq3rjrsmlqa" }
variable "id_rsa_pub" { default = "~/.ssh/id_rsa.pub" }
variable "oci_auth" { default = "SecurityToken" }
variable "oci_config_file_profile" { default = "DEFAULT" }
variable "master_count" { default = "1" }
