provider "aws" {
  region = "ap-south-1"
}

# Create a key pair
resource "aws_key_pair" "example" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a security group allowing SSH and HTTP access
resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Allow SSH and HTTP access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

# Create a target group
resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-xxxxxxxx"  # 🔁 Replace with your actual VPC ID

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Create a load balancer
resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example.id]
  subnets            = ["subnet-12345678", "subnet-87654321"]  # 🔁 Replace with your subnet IDs

  tags = {
    Name = "example-lb"
  }
}

# Create a listener
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# Launch Template
resource "aws_launch_template" "example" {
  name_prefix   = "example-lt"
  image_id      = "ami-12345678"  # 🔁 Replace with your AMI ID (Amazon Linux 2 or Ubuntu)
  instance_type = "t2.micro"

  key_name = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.example.id]

  user_data = base64encode(<<EOF
              #!/bin/bash
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "<h1>Hello from EC2 instance in ASG behind ALB!</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "example-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  name                      = "example-asg"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = ["subnet-12345678", "subnet-87654321"]  # 🔁 Replace

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.example.arn]

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

# Output the ALB DNS
output "alb_dns_name" {
  value = aws_lb.example.dns_name
}
