#ECS Cluster
resource "aws_ecs_cluster" "ecs_it_tools" {
  name = "ecs_it_tools"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_it_tools_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_it_tools.name

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
data "aws_ecr_image" "latest" {
  repository_name = "it_tools_repo"
  most_recent     = true
}

#ECS Task Definition and Service
resource "aws_ecs_task_definition" "ecs_it_tools_task" {
  family                   = "ecs_it_tools_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu    #variable
  memory                   = var.memory #variable
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "it_tools_container"
      image = data.aws_ecr_image.latest.name
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

resource "aws_ecs_service" "ecs_it_tools_service" {
  name            = "ecs_it_tools_service"
  cluster         = aws_ecs_cluster.ecs_it_tools.id
  task_definition = aws_ecs_task_definition.ecs_it_tools_task.arn
  desired_count   = var.desired_count #variable
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = "it_tools_container"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [
    desired_count,
    task_definition
  ]
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