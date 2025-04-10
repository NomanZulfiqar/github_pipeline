provider "aws" {
  region = "us-east-1"
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Development"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "RocketChat"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnet from the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for Rocket.Chat
resource "aws_security_group" "rocket_chat_sg" {
  name_prefix = "rocket-chat-sg-${var.environment}-"
  description = "Security group for Rocket.Chat server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Rocket.Chat web access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "rocket-chat-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "rocket-chat-server-${var.environment}"

  instance_type          = "t2.micro"
  ami                    = data.aws_ami.amazon_linux_2.id
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.rocket_chat_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0] # Using first available subnet

  root_block_device = [{
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }]

  tags = {
    Name        = "rocket-chat-server-${var.environment}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install Docker
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              
              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Create docker-compose.yml
              cat > /root/docker-compose.yml <<'EOL'
              version: '3'
              services:
                rocketchat:
                  image: registry.rocket.chat/rocketchat/rocket.chat:latest
                  restart: always
                  ports:
                    - 3000:3000
                  environment:
                    - PORT=3000
                    - ROOT_URL=http://localhost:3000
                    - MONGO_URL=mongodb://mongo:27017/rocketchat
                    - MONGO_OPLOG_URL=mongodb://mongo:27017/local
                  depends_on:
                    - mongo
                
                mongo:
                  image: mongo:4.0
                  restart: always
                  volumes:
                    - /data/db:/data/db
                  command: mongod --smallfiles --oplogSize 128 --replSet rs0
EOL
              
              # Start Rocket.Chat
              cd /root && docker-compose up -d
              EOF
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "rocket_chat_url" {
  description = "URL to access Rocket.Chat"
  value       = "http://${module.ec2_instance.public_ip}:3000"
}
