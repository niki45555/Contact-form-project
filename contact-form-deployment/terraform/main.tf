provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = { Name = "public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = { Name = "private-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow" {
  name   = "allow_ssh_http"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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

resource "aws_instance" "frontend" {
  ami                         = "ami-0f5ee92e2d63afc18"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow.id]
  associate_public_ip_address = true
  key_name                    = "my-key1"

  tags = {
    Name = "FRONTEND"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/akshay/.ssh/id_rsa")
    host        = self.public_ip
  }

  # ✅ Send the script to EC2
  provisioner "file" {
    source      = "../scripts/frontend.sh"
    destination = "/home/ubuntu/frontend.sh"
  }

  # ✅ Run the script on EC2
  provisioner "remote-exec" {
    inline = [
      "chmod +x frontend.sh",
      "sudo ./frontend.sh"
    ]
  }
}


resource "aws_instance" "backend" {
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow.id]
  associate_public_ip_address = false
  key_name               = "my-key1"

  tags = {
    Name = "BACKEND"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/akshay/.ssh/id_rsa")
    host        = self.private_ip
  }

  provisioner "file" {
    source      = "../scripts/backend.sh"
    destination = "/home/ubuntu/backend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x backend.sh",
      "sudo ./backend.sh"
    ]
  }
}


