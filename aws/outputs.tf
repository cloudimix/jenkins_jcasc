output "jm_public-ip" {
  value = module.ec2_instance.public_ip
}

output "LB_DNS_name" {
  value = module.alb.lb_dns_name
}
