# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create security group
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow SSH, HTTP, and custom TicTacToe ports"
  vpc_id      = aws_vpc.my_vpc.id

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

# Create EC2 instance
resource "aws_instance" "my_instance" {
  ami                         = "ami-00b535e0e5fc28916"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = true
  # Security group for EC2 instance
  vpc_security_group_ids = [aws_security_group.my_security_group.id]


  #installing dependencies and running TicTacToe app
  user_data                   = <<-EOF
              #!/bin/bash

              
              # Retrieve IP address using metadata script
              API_URL="http://169.254.169.254/latest/api"
              TOKEN=$(curl -X PUT "$API_URL/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600")
              TOKEN_HEADER="X-aws-ec2-metadata-token: $TOKEN"
              METADATA_URL="http://169.254.169.254/latest/meta-data"
              AZONE=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/placement/availability-zone)
              IP_V4=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/public-ipv4)
              INTERFACE=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/network/interfaces/macs/ | head -n1)
              SUBNET_ID=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/network/interfaces/macs/$INTERFACE/subnet-id)
              VPC_ID=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/network/interfaces/macs/$INTERFACE/vpc-id)

              echo "Your EC2 instance works in: AvailabilityZone: $AZONE, VPC: $VPC_ID, VPC subnet: $SUBNET_ID, IP address: $IP_V4"
              
              # Save IP address to a file
              echo "$IP_V4" > /tmp/ec2_ip_address.txt

              # Clone GitHub repository using deploy key
              #git clone https://github.com/pwr-cloudprogramming/a1-KamilTaras.git
              git clone https://github.com/pwr-cloudprogramming/a7-KamilTaras.git

              sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
              sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
              sudo chmod +x /usr/bin/docker-compose

              # Change to the directory containing your cloned repository
              cd a1-KamilTaras

              # Build Docker containers
              docker-compose build --build-arg ip="$IP_V4" --no-cache

              # Start Docker containers
              docker-compose up -d
              EOF
  user_data_replace_on_change = true
  tags = {
    Name = "Terraform-tictactoe"
  }

}
