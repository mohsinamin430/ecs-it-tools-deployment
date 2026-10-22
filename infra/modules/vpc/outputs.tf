output "vpc_id" {
  value = aws_vpc.vpc_threatapp.id
}

output "private_subnet_ids" {
  value = [for key, subnet in aws_subnet.ecs_subnets :
    subnet.id
  if var.ecs_subnets[key].type == "private"]
}

output "public_subnet_ids" {
  value = [for key, subnet in aws_subnet.ecs_subnets :
    subnet.id
  if var.ecs_subnets[key].type == "public"]
}