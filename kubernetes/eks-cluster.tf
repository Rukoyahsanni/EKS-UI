module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  cluster_endpoint_public_access  = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  

  cluster_name = "myApp-eks-cluster"  
  cluster_version = "1.27"

  subnet_ids = module.myApp-vpc.private_subnets
  vpc_id = module.myApp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "myApp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 6
      desired_size = 3

      instance_types = ["t2.small"]
      key_name       = "sannikp"
    }
  }
}
