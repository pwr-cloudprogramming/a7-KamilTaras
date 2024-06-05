variable "backend_url" {
  description = "URL of the backend service"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group"
  type        = string
}

variable "ecr_uri" {
  description = "The URI of the ECR repository"
  type        = string
  default     = "730335331900.dkr.ecr.us-east-1.amazonaws.com/lab7front:latest"
}

variable "cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role"
  type        = string
}
