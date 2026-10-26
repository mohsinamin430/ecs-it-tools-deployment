variable "cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the ECS task"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

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
