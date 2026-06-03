resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-ecs-cluster"

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-cluster"
    Environment = var.environment
    Project     = var.project_name
  }
}
resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project_name}-${var.environment}-nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "256"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image = "658140043880.dkr.ecr.us-east-1.amazonaws.com/apex-nginx:latest"
      essential = true

logConfiguration = {
  logDriver = "awslogs"

  options = {
    awslogs-group         = "/ecs/apex-dev"
    awslogs-region        = "us-east-1"
    awslogs-stream-prefix = "nginx"
  }
}
     portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-nginx-task"
    Environment = var.environment
    Project     = var.project_name
  }
}
resource "aws_ecs_service" "nginx" {
  name            = "${var.project_name}-${var.environment}-nginx-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_security_group_id]
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-nginx-service"
    Environment = var.environment
    Project     = var.project_name
  }
}
