output "ecs_cluster" {
  value = aws_ecs_cluster.ecs_it_tools.name
}

output "ecs_service" {
  value = aws_ecs_service.ecs_it_tools_service.name
}
