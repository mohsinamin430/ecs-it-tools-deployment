variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "tags" {
  default = {
    Environment = "prod"
    Project     = "ecs_deployment"
  }
}

variable "sub_domain" {
  type    = string
}

variable "cpu" {
  description = "CPU units for the ECS task"
  type        = string
}

variable "memory" {
  description = "Memory for the ECS task"
  type        = string
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
}