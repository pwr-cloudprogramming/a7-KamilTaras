# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# IAM Role Data Source
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Create Internet Gateway
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Create Route Table
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }
}

# Associate Subnet with Route Table
resource "aws_route_table_association" "main_route_table_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Create Security Group
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "main_security_group"

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

  ingress {
    from_port   = 3000
    to_port     = 3000
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

# Create ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "TicTacToe-FARGATE"
}

# Backend Module
module "backend" {
  source            = "./modules/backend"
  vpc_id            = aws_vpc.main_vpc.id
  subnet_id         = aws_subnet.main_subnet.id
  security_group_id = aws_security_group.main_sg.id
  cluster_id        = aws_ecs_cluster.app_cluster.id
  role_arn          = data.aws_iam_role.lab_role.arn
}

output "backend_output" {
  value = module.backend
}

# Frontend Module
module "frontend" {
  source            = "./modules/frontend"
  vpc_id            = aws_vpc.main_vpc.id
  subnet_id         = aws_subnet.main_subnet.id
  security_group_id = aws_security_group.main_sg.id
  backend_url       = module.backend.backend_url
  cluster_id        = aws_ecs_cluster.app_cluster.id
  role_arn          = data.aws_iam_role.lab_role.arn
}

output "frontend_output" {
  value = module.frontend
}
