provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "my-ec2-instance"

  instance_type          = "t3a.micro"
  ami                    = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI in us-east-1
  monitoring             = true
  vpc_security_group_ids = ["sg-054279651426b29ad"]   # Replace with your security group ID
  subnet_id              = "subnet-0daa08c7c1d6ee434" # Replace with your subnet ID

  tags = {
    Environment = "Development"
    Project     = "MyProject"
    Terraform   = "true"
  }
}

# Output the instance ID and public IP
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}
