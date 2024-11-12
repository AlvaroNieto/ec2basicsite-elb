terraform {
  backend "s3" {
    bucket         = "terraform-state-alvaronl"
    key            = "ec2basicsite-elb/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-south-2"
}

#Senstive vars 
variable "input_hosted_zone_id" {
  description = "Input the domain hosted zone id"
  type        = string
  sensitive   = true
}

variable "input_cert_arn" {
  description = "Input the generated certificated in ACM"
  type        = string
  sensitive   = true
}


# Network/VPC Module
module "network" {
  source              = "./modules/network"
  vpc_cidr_block_net  = "10.0.0.0/16"
  subnet_a_cidr_block = "10.0.1.0/24"
  subnet_a_az         = "eu-south-2a"
  subnet_b_cidr_block = "10.0.2.0/24"
  subnet_b_az         = "eu-south-2b"
}


# ALB Module with HTTPS
module "elb" {
  source             = "./modules/elb"
  vpc_id             = module.network.mainvpc_id
  subnet_ids         = [module.network.subnet_a_id, module.network.subnet_b_id] # Passing both subnets
  security_group_ids = [module.network.sec_group]
  target_group_name  = "ec2-nginx-target-group"
  cert_arn           = var.input_cert_arn
}

# EC2 Module to deploy instances 1 and 2
module "ec2_instance_1" {
  source           = "./modules/ec2"
  instance_name    = "ec2-instance1"
  vpc_id           = module.network.mainvpc_id
  subnet_id        = module.network.subnet_a_id #subnet a
  security_group   = module.network.sec_group
  target_group_arn = module.elb.target_group_arn
}

module "ec2_instance_2" {
  source           = "./modules/ec2"
  instance_name    = "ec2-instance2"
  vpc_id           = module.network.mainvpc_id
  subnet_id        = module.network.subnet_b_id #subnet b
  security_group   = module.network.sec_group
  target_group_arn = module.elb.target_group_arn
}

# Route 53 DNS Record
resource "aws_route53_record" "elb_record" {
  zone_id = var.input_hosted_zone_id
  name    = "ec2-elb.alvaronl.com"
  type    = "A"

  alias {
    name                   = module.elb.elb_dns_name
    zone_id                = module.elb.elb_zone_id
    evaluate_target_health = true
  }
}