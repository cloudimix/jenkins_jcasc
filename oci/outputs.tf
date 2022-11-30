output "ARM_Master_public_ip" {
  value = module.compute-instance.public_ip[*]
}
