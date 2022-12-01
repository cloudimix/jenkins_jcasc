variable "aws_region" {
  description = "AWS region for infrastructure placing"
  type        = string
  default     = "eu-central-1"
}

variable "d_name" {
  description = "Name of route53 record (like test.com)"
  type        = string
}

variable "most_recent" {
  description = "Do you want the latest ami?"
  type        = bool
  default     = true
}

variable "owners" {
  description = "The ami´s owners"
  type        = list(string)
  default     = ["099720109477"]
}

variable "name_filter" {
  description = "Name filter for ami selection"
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

variable "virtualization_type" {
  description = "Virtualization-type filter for ami selection"
  type        = list(string)
  default     = ["hvm"]
}

variable "key_name" {
  description = "AWS key pair name?"
  type        = string
  default     = "jm_key"
}

variable "public_key" {
  description = "AWS public ssh key path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "sg_name" {
  description = "AWS security group name"
  type        = string
  default     = "jenkins-sg"
}

variable "open_ports" {
  description = "List of ports to open"
  type        = list(string)
  default     = ["22", "80", "443"]
}

variable "sg_protocol" {
  description = "SG protocol"
  type        = string
  default     = "tcp"
}

variable "all_addresses" {
  description = "Al IP addresses"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_name" {
  description = "AWS instance name"
  type        = string
  default     = "jenkins-master"
}

variable "instance_type" {
  description = "AWS instance_type"
  type        = string
  default     = "t2.micro"
}

variable "monitoring" {
  description = "Is monitoring enabled?"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Infrastructure common tags"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "lb_name" {
  description = "AWS load balancer name"
  type        = string
  default     = "main-alb"
}

variable "lb_type" {
  description = "Type og load balancer"
  type        = string
  default     = "application"
}

variable "tg1_name_pref" {
  description = "Name prefix of target group"
  type        = string
  default     = "jenk"
}

variable "backend_protocol" {
  description = "Backend protocol for tg1 group"
  type        = string
  default     = "HTTP"
}

variable "backend_port" {
  description = "HTTP common port"
  type        = string
  default     = "80"
}

variable "target_type" {
  description = "Type of target"
  type        = string
  default     = "instance"
}

variable "listener_port_https" {
  description = "HTTPS common port"
  type        = string
  default     = "443"
}

variable "listener_protocol_https" {
  description = "HTTPS protocol"
  type        = string
  default     = "HTTPS"
}

variable "redirect_listener_protocol_https" {
  description = "HTTPS protocol"
  type        = string
  default     = "HTTPS"
}

variable "from_port_redirect" {
  description = "ALB redirect from port"
  type        = string
  default     = "80"
}

variable "to_port_redirect" {
  description = "ALB redirect to port"
  type        = string
  default     = "443"
}

variable "listener_port_http" {
  description = "HTTP common port"
  type        = string
  default     = "80"
}

variable "listener_protocol_http" {
  description = "Protocol to listen"
  default     = "HTTP"
}

variable "action_type" {
  description = "Listener redirect from port to port"
  type        = string
  default     = "redirect"
}
variable "status_code" {
  description = "Status code response when redirection"
  type        = string
  default     = "HTTP_301"
}
