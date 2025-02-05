resource "aws_ecs_task_definition" "my_task" {
  family                   = "node-app-task2"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"  
  memory                   = "2048" 
  execution_role_arn       = "arn:aws:iam::340752842134:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::340752842134:role/ecsTaskExecutionRole"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name        = "node-app-cont"
      image       = "340752842134.dkr.ecr.us-east-1.amazonaws.com/node-app"
      #cpu         = 1024
      #memory      = 2048
      essential   = true

      portMappings = [
        {
          name          = "node-app-3000"
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/node-app-task2"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
          mode                  = "non-blocking"
          max-buffer-size       = "25m"
        }
      }

      environment       = []
      environmentFiles  = []
      mountPoints       = []
      systemControls    = []
      ulimits           = []
      volumesFrom       = []
    }
  ])
}
