variable "private_subnet_ids" {
  description = "IDs of the private subnets for ECS service"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where ECS service will be deployed"
  type        = string
}

variable "alb_tg_arn" {
  description = "ARN of the ALB target group for ECS service"
  type        = string
}

variable "alb_sg_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to ECS resources"
  type        = map(string)
}
