provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "frankfurt" {}

data "aws_route53_zone" "route53_zone" {
  name = "cloudimix.com"
}

data "aws_ami" "ubuntu_22_04_lst" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
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
  key_name   = "jm_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "jm_sg" {
  name = "jenkins-sg"
  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = "jenkins-master"
  ami                    = data.aws_ami.ubuntu_22_04_lst.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.jm_key.key_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.jm_sg.id]
  subnet_id              = aws_default_subnet.az_1.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
output "alb_info" {
  value = module.alb.lb_dns_name
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "main-alb"

  load_balancer_type = "application"

  vpc_id          = aws_default_vpc.def_vpc.id
  subnets         = [aws_default_subnet.az_1.id, aws_default_subnet.az_2.id]
  security_groups = [aws_security_group.jm_sg.id]

  target_groups = [
    {
      name_prefix      = "jenkins"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_ec2 = {
          target_id = module.ec2_instance.id
          port      = 80
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  depends_on = [module.acm]
}
module "acm" {
  source                    = "terraform-aws-modules/acm/aws"
  version                   = "~> 4.0"
  domain_name               = "cloudimix.com"
  zone_id                   = data.aws_route53_zone.route53_zone.zone_id
  wait_for_validation       = true
  subject_alternative_names = ["*.cloudimix.com"]
  create_route53_records    = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "cloudimix.com"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
