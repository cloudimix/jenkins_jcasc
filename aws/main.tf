provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "frankfurt" {}

data "aws_route53_zone" "route53_zone" {
  name = var.d_name
}

data "aws_ami" "ubuntu_22_04_lst" {
  most_recent = var.most_recent
  owners      = var.owners
  filter {
    name   = "name"
    values = var.name_filter
  }
  filter {
    name   = "virtualization-type"
    values = var.virtualization_type
  }
}

resource "aws_default_subnet" "az_1" {
  availability_zone = data.aws_availability_zones.frankfurt.names[0]
}

resource "aws_default_subnet" "az_2" {
  availability_zone = data.aws_availability_zones.frankfurt.names[1]
}

resource "aws_default_vpc" "def_vpc" {}

resource "aws_key_pair" "jm_key" {
  key_name   = var.key_name
  public_key = file(var.public_key)
}

resource "aws_security_group" "jm_sg" {
  name = var.sg_name
  dynamic "ingress" {
    for_each = var.open_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.sg_protocol
      cidr_blocks = var.all_addresses
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.all_addresses
  }
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = var.instance_name
  ami                    = data.aws_ami.ubuntu_22_04_lst.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.jm_key.key_name
  monitoring             = var.monitoring
  vpc_security_group_ids = [aws_security_group.jm_sg.id]
  subnet_id              = aws_default_subnet.az_1.id

  tags = var.common_tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name               = var.lb_name
  load_balancer_type = var.lb_type
  vpc_id             = aws_default_vpc.def_vpc.id
  subnets            = [aws_default_subnet.az_1.id, aws_default_subnet.az_2.id]
  security_groups    = [aws_security_group.jm_sg.id]

  target_groups = [
    {
      name_prefix      = var.tg1_name_pref
      backend_protocol = var.backend_protocol
      backend_port     = var.backend_port
      target_type      = var.target_type
      targets = {
        my_ec2 = {
          target_id = module.ec2_instance.id
          port      = var.backend_port
        }
      }
    }
  ]
  https_listeners = [
    {
      port               = var.listener_port_https
      protocol           = var.listener_protocol_https
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]
  http_tcp_listeners = [
    {
      port        = var.from_port_redirect
      protocol    = var.listener_protocol_http
      action_type = var.action_type
      redirect = {
        port        = var.to_port_redirect
        protocol    = var.redirect_listener_protocol_https
        status_code = var.status_code
      }
    }
  ]

  depends_on = [module.acm]
}
module "acm" {
  source                    = "terraform-aws-modules/acm/aws"
  version                   = "~> 4.0"
  domain_name               = var.d_name
  zone_id                   = data.aws_route53_zone.route53_zone.zone_id
  wait_for_validation       = var.wait_for_validation
  subject_alternative_names = ["*.${var.d_name}"]
  create_route53_records    = var.create_route53_records
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.d_name
  type    = var.record_type

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}
