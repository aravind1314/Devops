resource "aws_security_group" "my_sg" {
    name = "my-sg"
    description = "my security group"
  vpc_id = var.vpc_id
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
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  availability_zone = var.avail_zone
  key_name = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true

  user_data = file(var.script_location)

  tags = {
    Name = "${var.env_prefix}-server"
  }
}