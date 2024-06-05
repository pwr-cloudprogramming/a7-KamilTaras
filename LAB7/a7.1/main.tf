# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "taras_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnet
resource "aws_subnet" "taras_subnet" {
  vpc_id     = aws_vpc.taras_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Create internet gateway
resource "aws_internet_gateway" "taras_igw" {
  vpc_id = aws_vpc.taras_vpc.id
}

# Create route table
resource "aws_route_table" "taras_route_table" {
  vpc_id = aws_vpc.taras_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.taras_igw.id
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "taras_subnet_association" {
  subnet_id      = aws_subnet.taras_subnet.id
  route_table_id = aws_route_table.taras_route_table.id
}

# Create security group
resource "aws_security_group" "taras_security_group" {
  name        = "taras-security-group"
  description = "Allow SSH, HTTP, and custom TicTacToe ports"
  vpc_id      = aws_vpc.taras_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
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

# Backend module
module "taras_backend" {
  source = "./modules/backend"
  id_my_vpc = aws_vpc.taras_vpc.id
  id_my_subnet = aws_subnet.taras_subnet.id
  id_my_security_group = aws_security_group.taras_security_group.id
}

output "taras_backend" {
  value = module.taras_backend
}

# Frontend module
module "taras_frontend" {
  source          = "./modules/frontend"
  id_my_vpc = aws_vpc.taras_vpc.id
  id_my_subnet = aws_subnet.taras_subnet.id
  id_my_security_group = aws_security_group.taras_security_group.id
  ip = module.taras_backend.ip
}

output "taras_frontend" {
  value = module.taras_frontend
}
