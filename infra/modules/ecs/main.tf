#ECS Cluster
resource "aws_ecs_cluster" "ecs_threatapp" {
  name = "ecs_threatapp"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "ecs_threatapp_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_threatapp.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

#IAM
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

#Pull ECR repo URL
data "aws_ecr_repository" "threatapp_repo" {
  name = "threatapp_repo"
}

#ECS Task Definition and Service
resource "aws_ecs_task_definition" "ecs_threatapp_task" {
  family                   = "ecs_threatapp_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu    #variable
  memory                   = var.memory #variable
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "threatapp_container"
      image = "666709165403.dkr.ecr.eu-west-2.amazonaws.com/threatapp_repo:3fe22ee97ca435133f6c8fa9e90c8fcbf8b73baa"
      #"${data.aws_ecr_repository.threatapp_repo.repository_url}:image-tag"
      # Uncomment the line above and remove the '#' to use the image from ECR with the specified tag
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_threatapp_service" {
  name            = "ecs_threatapp_service"
  cluster         = aws_ecs_cluster.ecs_threatapp.id
  task_definition = aws_ecs_task_definition.ecs_threatapp_task.arn
  desired_count   = var.desired_count #variable
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = "threatapp_container"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [
    desired_count]
  }
}

#ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}