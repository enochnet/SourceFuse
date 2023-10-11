provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Change this to match your desired availability zone
  map_public_ip_on_launch = true
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Change this to match your desired availability zone
}

# Create ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}

# Create ECS task definition
resource "aws_ecs_task_definition" "my_task" {
  family                = "my-task"
  container_definitions = jsonencode([{
    name  = "nginx-container"
    image = "nginx:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

# Create ECS service
resource "aws_ecs_service" "my_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 2 # Adjust as needed
}

# Create ALB
resource "aws_lb" "my_lb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
}

# Create ALB target group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# Attach ALB target group to ECS service
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    status_code      = "200"
    content_type     = "text/plain"
    response_body    = "OK"
  }
}

resource "aws_lb_target_group_attachment" "my_target_group_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_ecs_service.my_service.id
  port             = 80
}

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-nginx-bucket" # Change this to your desired bucket name
  acl    = "private"

  lifecycle_configuration {
    rule {
      status = "Enabled"

      transition {
        days          = 30
        storage_class = "STANDARD_IA"
      }

      transition {
        days          = 60
        storage_class = "GLACIER"
      }
    }
  }
}

# Attach policy to ECS task to allow writing to S3 bucket
resource "aws_ecs_task_definition" "my_task_with_policy" {
  family                = "my-task"
  container_definitions = jsonencode([{
    name  = "nginx-container"
    image = "nginx:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_iam_role_policy_attachment" "my_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # This grants full access to S3. Adjust as needed.
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

