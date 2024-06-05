resource "aws_ecs_task_definition" "backend_task" {
  family                   = "BackendTaskDef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.role_arn
  task_role_arn            = var.role_arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.ecr_uri
      cpu       = 256
      memory    = 512
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

resource "aws_ecs_service" "backend_service" {
  name            = "BackendService"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  enable_ecs_managed_tags = true
  wait_for_steady_state   = true
  
  network_configuration {
    assign_public_ip = true
    subnets          = [var.subnet_id]
    security_groups  = [var.security_group_id]
  }
}

data "aws_network_interface" "backend_interface_tags" {
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = [aws_ecs_service.backend_service.name]
  }
}
