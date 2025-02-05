
resource "aws_ecs_cluster" "my_cluster" {
  name = "node-app-cluster" # Nom du cluster

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }

  service_connect_defaults {
    namespace = "arn:aws:servicediscovery:us-east-1:340752842134:namespace/ns-fsx4wzbphys5z5qn"
  }

  tags = {
    name = "node-app-cluster"
  }
}

output "cluster_arn" {
  value = aws_ecs_cluster.my_cluster.arn
}
