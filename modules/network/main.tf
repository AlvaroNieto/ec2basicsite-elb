
# VPC, Subnets
resource "aws_vpc" "mainvpc" {
  cidr_block = var.vpc_cidr_block_net
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = var.subnet_a_cidr_block
  availability_zone       = var.subnet_a_az # First AZ
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = var.subnet_b_cidr_block
  availability_zone       = var.subnet_b_az  # Second AZ
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

#Security Groups for inbound and outbound HTTP/S connection.
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

    ingress {
    from_port   = 22
    to_port     = 22
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