variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "target_group_name" {
  description = "The name of the target group"
  type        = string
}

variable "cert_arn" {
  description = "The ARN of the ACM certificate for HTTPS"
  type        = string
}
