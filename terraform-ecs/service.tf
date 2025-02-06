resource "aws_security_group" "alb_sg" {
  name        = "ecs-alb-sg"
  description = "Security Group for ECS ALB"
  vpc_id      = "vpc-0e939fdbc65455851"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ecs_alb" {
  name               = "nodeappplbsecs3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    "subnet-00b832f45a83e7ea8",
    "subnet-071f03f664fa3417b",
    "subnet-09268996b273aa2b0",
    "subnet-0abee90b6b482f3e5",
    "subnet-0dbb0281ec79b8779",
    "subnet-0ecdfbeaafa257c29"
  ]
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-node-a-nodeappservice3"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-0e939fdbc65455851"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-service-sg"
  description = "Security Group for ECS tasks"
  vpc_id      = "vpc-0e939fdbc65455851"

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "my_service" {
  name            = "nodeappservice3"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = [
      "subnet-00b832f45a83e7ea8",
      "subnet-071f03f664fa3417b",
      "subnet-09268996b273aa2b0",
      "subnet-0abee90b6b482f3e5",
      "subnet-0dbb0281ec79b8779",
      "subnet-0ecdfbeaafa257c29"
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "node-app-cont"
    container_port   = 3000
  }
}
