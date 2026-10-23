variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "tags" {
  default = {
    Environment = "staging"
    Project     = "ecs_deployment"
  }
}