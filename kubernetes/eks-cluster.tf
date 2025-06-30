module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "myApp-eks-cluster"
  cluster_version = var.cluster_version

  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    # eks-pod-identity-agent is only supported on EKS 1.27 and above
    # Uncomment the following line if using EKS 1.27 or newer:
    # eks-pod-identity-agent = {}
  }

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.myApp-vpc.vpc_id
  subnet_ids               = module.myApp-vpc.private_subnets
  control_plane_subnet_ids = module.myApp-vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    # Default instance types for managed node groups; 'example' group overrides this with ["m5.xlarge"]
    instance_types = ["t3.medium", "t3.large", "m5.large", "m5n.large"]
    # but may lead to varied performance characteristics within the node group.
    instance_types = ["t3.medium", "t3.large", "m5.large", "m5n.large"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}