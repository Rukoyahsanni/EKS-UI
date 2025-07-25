# configured aws provider with proper credentials
provider "aws" {
  region    = "us-east-1"
  profile   = "sanni"
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group_sonarqube" {
  name        = "ec2 security group_sonarqube"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  # allow access on port 8080
  ingress {
    description      = "sonarqube access"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "sonarqube server security group"
  }
}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

# launch the ec2 instance 
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group_sonarqube.id]
  key_name               = "sannikp"

  tags = {
    Name = "sonarqube_server"
  }
}

# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:/Users/HP/Downloads/sannikp.pem") 
    host        = aws_instance.ec2_instance.public_ip
  }

 # copy the install_sonarqube.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "install_sonarqube.sh"
    destination = "/home/ubuntu/install_sonarqube.sh"
  }

  # set permissions and run the install_sonarqube.sh file
  provisioner "remote-exec" {
    inline = [
        "sed -i 's/\\r$//' /home/ubuntu/install_sonarqube.sh",
        "sudo chmod +x /home/ubuntu/install_sonarqube.sh",
        "sudo bash /home/ubuntu/install_sonarqube.sh ",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.ec2_instance]
}
# print the url of the sonarqube server
output "website_url" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "9000"])
}
