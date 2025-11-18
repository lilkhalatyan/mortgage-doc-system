# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mortgage-docs"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  # Set via environment variable: export TF_VAR_db_password="YourPassword123!"
}

variable "my_ip" {
  description = "Your IP address for SSH access (find at: https://whatismyipaddress.com/)"
  type        = string
  # Set via: export TF_VAR_my_ip="123.456.789.0/32"
}

variable "ssh_key_name" {
  description = "Name of SSH key pair (create in EC2 console first)"
  type        = string
  # Set via: export TF_VAR_ssh_key_name="my-key-pair"
}