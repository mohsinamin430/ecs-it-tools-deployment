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