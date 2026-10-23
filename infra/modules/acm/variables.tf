variable "domain_name" {
  type    = string
  default = "mohsin430.com"
}

variable "alb_dns_name" {
  type = string
}

variable "alb_zone_id" {
  type = string
}

variable "sub_domain" {
  type = string
  default = "ecs"
}