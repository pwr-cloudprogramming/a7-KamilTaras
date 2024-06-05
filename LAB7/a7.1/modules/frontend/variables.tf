variable "region" {
  description = "The AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The type of instance to deploy"
  type        = string
  default     = "t2.micro"
}

variable "taras_security_group_id" {
  description = "The ID of the security group"
  type        = string
}

variable "taras_vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "taras_subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "taras_ec2_key_name" {
  description = "The name of the EC2 key pair"
  type        = string
}
