# Peace Garden App – Terraform Project Structure and Code

## Root Files

### `main.tf`
```hcl
module "ec2" {
  source = "./modules/ec2"
}

module "vpn" {
  source = "./modules/vpn"
}

module "honeypot" {
  source = "./modules/honeypot"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "monitoring" {
  source = "./modules/monitoring"
}
```

### `provider.tf`
```hcl
provider "aws" {
  region = var.aws_region
}
```

### `variables.tf`
```hcl
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}
```

### `terraform.tfvars`
```hcl
aws_region = "ap-south-1"
```

### `outputs.tf`
```hcl
output "ec2_public_ip" {
  value = module.ec2.public_ip
}
```

## Modules

### `modules/ec2/main.tf`
```hcl
resource "aws_instance" "app" {
  ami                    = "ami-0c55b159cbfafe1f0" # Replace with valid AMI
  instance_type          = "t2.micro"
  key_name               = "my-key"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = file("${path.module}/../../scripts/cloudwatch_agent.sh")

  tags = {
    Name = "peace-garden-ec2"
  }
}

resource "aws_security_group" "sg" {
  name_prefix = "peace-garden-sg"

  ingress {
    from_port   = 22
    to_port     = 22
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
```

### `modules/vpn/main.tf`
```hcl
resource "null_resource" "vpn_setup" {
  provisioner "local-exec" {
    command = "bash ${path.module}/../../scripts/setup_openvpn.sh"
  }
}
```

### `modules/honeypot/main.tf`
```hcl
resource "null_resource" "honeypot" {
  provisioner "local-exec" {
    command = "bash ${path.module}/../../scripts/honeypot_deploy.sh"
  }
}
```

### `modules/dynamodb/main.tf`
```hcl
resource "aws_dynamodb_table" "peace_garden" {
  name         = "PeaceGardenTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "peace-garden-dynamo"
  }
}
```

### `modules/monitoring/main.tf`
```hcl
resource "aws_cloudwatch_log_group" "peace_garden" {
  name              = "/aws/ec2/peace-garden"
  retention_in_days = 14
}
```

## Scripts

### `scripts/setup_openvpn.sh`
```bash
#!/bin/bash
sudo apt update -y
sudo apt install -y openvpn easy-rsa
```

### `scripts/honeypot_deploy.sh`
```bash
#!/bin/bash
sudo apt update -y
sudo apt install -y cowrie || echo "Install honeypot manually"
```

### `scripts/cloudwatch_agent.sh`
```bash
#!/bin/bash
sudo yum install amazon-cloudwatch-agent -y
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
```

## Docs (to be completed manually)

### `docs/user_guide.md`
> A markdown file describing how to initialize, plan, apply Terraform, and manage deployments.

### `docs/architecture.png`
> A diagram showing AWS EC2 + VPN + DynamoDB + CloudWatch with flow arrows.

### `docs/cost_optimization.md`
> Recommendations such as:
- Use of `t2.micro`
- PAY_PER_REQUEST DynamoDB
- Retention of logs
- Auto-scaling and idle resource alerts
