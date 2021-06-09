data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    cluster_name    = "vd-cluster"
    cluster_version = "1.17"
    subnets         = data.aws_subnet_ids.private_subnets.ids
    vpc_id          = module.vpc.vpc_id

    worker_groups = [
        {
        instance_type = "t2.small"
        asg_max_size  = 1
        }
    ]
}
