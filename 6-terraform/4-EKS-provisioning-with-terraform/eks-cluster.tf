provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
  api_version = "client.authentication.k8s.io/v1beta1"
  args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  command     = "aws"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name = "my_eks_cluster"
  cluster_version = "1.25"

  cluster_endpoint_public_access = true

  subnet_ids = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  tags = {
    environment = "dev"
  }

  eks_managed_node_groups = {
    my_node_group = {
        instance_types = ["t2.micro"]
        min_size = 1
        max_size = 3
        desired_size = 2
        subnet_ids = [module.vpc.private_subnets[0]]
    }
  }
}