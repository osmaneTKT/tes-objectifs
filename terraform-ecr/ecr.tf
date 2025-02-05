provider "aws" {
  region = "us-east-1"  
}

resource "aws_ecr_repository" "node-app" {
  name = "node-app"  
}