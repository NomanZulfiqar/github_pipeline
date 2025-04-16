# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "rocket-chat-vpc"
    Environment = "Development"
    Project     = "RocketChat"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "rocket-chat-igw"
    Environment = "Development"
    Project     = "RocketChat"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block             = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "rocket-chat-public-subnet"
    Environment = "Development"
    Project     = "RocketChat"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "rocket-chat-public-rt"
    Environment = "Development"
    Project     = "RocketChat"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "rocket_chat_sg" {
  name        = "rocket-chat-sg"
  description = "Security group for Rocket.Chat server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Rocket.Chat"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rocket-chat-security-group"
    Environment = "Development"
    Project     = "RocketChat"
  }
}

# EC2 Instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "rocket-chat-server"

  ami                    = "ami-053b0d53c279acc90"  # Ubuntu 22.04
  instance_type          = "t3.small"
  key_name              = "rocketchat"              # Replace with your key pair name
  
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.rocket_chat_sg.id]

  root_block_device = [{
    volume_size = 16
    volume_type = "gp3"
    encrypted   = true
  }]

  tags = {
    Name        = "rocket-chat-server"
    Environment = "Development"
    Project     = "RocketChat"
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/rocketchat.pem ec2-user@${module.ec2_instance.public_ip}"
}
