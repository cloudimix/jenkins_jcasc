
module "compute-instance" {
  source                      = "./modules/compute-instance"
  compartment_ocid            = var.compartment_ocid
  ad_number                   = 1
  instance_count              = var.master_count
  instance_display_name       = "jenkins-master"
  instance_flex_memory_in_gbs = "24"
  instance_flex_ocpus         = "4"
  shape                       = "VM.Standard.A1.Flex"
  source_ocid                 = var.instance-ARM_source_image_id
  ssh_public_keys             = file(var.id_rsa_pub)
  public_ip                   = "EPHEMERAL"
  public_ip_display_name      = "JPubIP"
  subnet_ocids                = [module.main_vcn.subnet_id["jsubnet"]]
  block_storage_sizes_in_gbs  = [50]
  boot_volume_size_in_gbs     = "50"
}

module "main_vcn" {
  source                   = "./modules/main_vcn"
  compartment_id           = var.compartment_ocid
  lockdown_default_seclist = false
  create_internet_gateway  = true
  region                   = var.region
  vcn_cidrs                = ["10.0.0.0/16"]
  subnets = {
    sub1 = { name = "jsubnet", cidr_block = "10.0.1.0/24", type = "public" }
  }
}
