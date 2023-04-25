provider "aws" {
    region = "ap-south-1"
}

variable "vpc_cidr_block" {}

variable "private_subnet_cidr_blocks" {}

variable "public_subnet_cidr_blocks" {}


data "aws_availability_zones" "azs" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name = "my_vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.azs.names

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/my_eks_cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my_eks_cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my_eks_cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

