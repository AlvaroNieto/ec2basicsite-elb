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
  senstive    = true
}

variable "input_cert_arn" {
  description = "Input the generated certificated in ACM"
  type        = string
  senstive    = true
}

# VPC, Subnets, and Security Groups
resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-south-2a"  # First AZ
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-south-2b"  # Second AZ
  map_public_ip_on_launch = true
}

# Create an Internet Gateway
resource "aws_internet_gateway" "maingateway" {
  vpc_id = aws_vpc.mainvpc.id
}

# Create a Route Table to associate it with the Subnets
resource "aws_route_table" "mainroute" {
  vpc_id = aws_vpc.mainvpc.id
}

# Add the route for internet access
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.mainroute.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id            = aws_internet_gateway.maingateway.id
}

# Associate the Route Table with Subnet A and Subnet B
resource "aws_route_table_association" "subnet_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.mainroute.id
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.mainroute.id
}


resource "aws_security_group" "allow_http_https" {
  vpc_id = aws_vpc.mainvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB Module with HTTPS
module "elb" {
  source             = "./modules/elb"
  vpc_id             = aws_vpc.mainvpc.id
  subnet_ids       = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]  # Passing both subnets
  security_group_ids = [aws_security_group.allow_http_https.id]
  target_group_name  = "ec2-nginx-target-group"
  cert_arn           = var.input_cert_arn
}

# EC2 Module to deploy instances 1 and 2
module "ec2_instance_1" {
  source           = "./modules/ec2"
  instance_name    = "ec2-instance1"
  vpc_id           = aws_vpc.mainvpc.id
  subnet_id        = aws_subnet.subnet_a.id #subnet a
  security_group   = aws_security_group.allow_http_https.id
  target_group_arn = module.elb.target_group_arn
}

module "ec2_instance_2" {
  source           = "./modules/ec2"
  instance_name    = "ec2-instance2"
  vpc_id           = aws_vpc.mainvpc.id
  subnet_id        = aws_subnet.subnet_b.id #subnet b
  security_group   = aws_security_group.allow_http_https.id
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