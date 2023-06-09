provider "aws" {}


variable "vpc_cidr_block" {}

variable "subnet_cidr_block" {}

variable "env_prefix" {}

variable "instance_type" {}

variable "avail_zone" {}

variable "public_key_location" {}

variable "private_key_location" {}


resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

resource "aws_default_route_table" "default_rtb" {
    default_route_table_id = aws_vpc.my_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-default-rtb"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_security_group" "my_sg" {
    name = "my-sg"
    description = "my security group"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh-key-pair"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "my_server" {
  ami = data.aws_ami.latest_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  availability_zone = var.avail_zone
  key_name = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source = "script.sh"
    destination = "/home/ubuntu/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x script.sh",
      "./script.sh"
    ]
  }

  /*provisioner "remote-exec" {
    script = file("script.sh")
  }*/

  provisioner "local-exec" {
    command = "echo ${self.public_ip}"
  }

  tags = {
    Name = "${var.env_prefix}-server"
  }
}

