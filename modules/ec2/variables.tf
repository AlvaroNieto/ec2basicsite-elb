variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to deploy the instance in"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "security_group" {
  description = "Security group for the EC2 instance"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN for the ALB"
  type        = string
}
