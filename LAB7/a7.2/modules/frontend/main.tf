locals {
  frontend_app_env = {
    BACK_IP = var.backend_url
  }
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "TarasFrontendTaskDef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.role_arn
  task_role_arn            = var.role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.ecr_uri
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "BACK_IP"
          value = var.backend_url
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend_service" {
  name            = "TarasFrontendService"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    assign_public_ip = true
    subnets          = [var.subnet_id]
    security_groups  = [var.security_group_id]
  }
}
