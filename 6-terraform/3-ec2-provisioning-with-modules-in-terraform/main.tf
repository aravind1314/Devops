provider "aws" {}

resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name = "${var.env_prefix}-vpc"
    }
}

module "subnet-module" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.my_vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id
}

module "server-module" {
  source = "./modules/server"
  vpc_id = aws_vpc.my_vpc.id
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.subnet-module.aws_subnet_op.id
  avail_zone = var.avail_zone
  script_location = var.script_location
}