provider "aws" {
  region  = "us-east-1"
  profile = "sanni" # Ensure this AWS CLI profile is configured
}

# Create default VPC if one does not exist
resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

# Get availability zones
data "aws_availability_zones" "available" {}

# Create default subnet
resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "default-subnet"
  }
}

# Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins (8080)"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "jenkins-sg"
  }
}

# Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = aws_default_subnet.default.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "sannikp"

  tags = {
    Name = "jenkins-server"
  }
}

# Install Jenkins
resource "null_resource" "jenkins_setup" {
  depends_on = [aws_instance.jenkins]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:/Users/HP/Downloads/sannikp.pem")
    host        = aws_instance.jenkins.public_ip
  }

  provisioner "file" {
    source      = "install_jenkins.sh"
    destination = "/home/ubuntu/install_jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i 's/\\r$//' /home/ubuntu/install_jenkins.sh", # fix Windows line endings
      "chmod +x /home/ubuntu/install_jenkins.sh",
      "sudo bash /home/ubuntu/install_jenkins.sh"
    ]
  }
}

# Output Jenkins URL
output "jenkins_url" {
  description = "Access your Jenkins server at this URL"
  value       = "http://${aws_instance.jenkins.public_dns}:8080"
}
