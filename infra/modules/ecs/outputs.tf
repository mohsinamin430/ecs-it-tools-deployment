output "ecs_cluster" {
  value = aws_ecs_cluster.ecs_threatapp.name
}

output "ecs_service" {
  value = aws_ecs_service.ecs_threatapp_service.name
}
