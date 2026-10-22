variable "vpc_cidrblock" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tags" {
  type = map(string)
}

variable "ecs_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
  default = {
    public-1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-west-2a"
      type              = "public"
    }
    public-2 = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "eu-west-2b"
      type              = "public"
    }
    private-1 = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "eu-west-2a"
      type              = "private"
    }
    private-2 = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "eu-west-2b"
      type              = "private"
    }
  }
}