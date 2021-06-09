data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
    version                = "~> 1.9"
}

module "my-cluster" {
    source          = "terraform-aws-modules/eks/aws"
    cluster_name    = "vd-cluster"
    cluster_version = "1.17"
    subnets         = data.aws_subnet_ids.private_subnets.ids
    vpc_id          = module.vpc.vpc_id

    worker_groups = [
        {
        instance_type = "t2.medium"
        asg_max_size  = 1
        }
    ]
}
