provider "aws" {
  region = "us-east-1"
}

# Security group for Rocket.Chat
resource "aws_security_group" "rocket_chat_sg" {
  name        = "rocket-chat-sg"
  description = "Security group for Rocket.Chat server"

  ingress {
    from_port   = 3000 # Rocket.Chat default port
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "rocket-chat-server"

  instance_type          = "t3.micro" # Free tier eligible
  ami                    = "ami-0c7217cdde317cfec"
  monitoring             = false # Disabled to reduce costs
  vpc_security_group_ids = [aws_security_group.rocket_chat_sg.id]
  subnet_id              = "subnet-0daa08c7c1d6ee434"

  root_block_device = [{
    volume_size = 8 # Minimum required, stays within free tier
    volume_type = "gp3"
  }]

  tags = {
    Environment = "Development"
    Project     = "RocketChat"
    Terraform   = "true"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
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
