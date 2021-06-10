data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

module "eks" {
    source                          = "terraform-aws-modules/eks/aws"
    cluster_name                    = "vd-cluster"
    cluster_version                 = "1.20.4"
    subnets                         = data.aws_subnet_ids.private_subnets.ids
    vpc_id                          = module.vpc.vpc_id
    cluster_endpoint_public_access  = false
    cluster_endpoint_private_access = true
    cluster_create_endpoint_private_access_sg_rule = true
    cluster_endpoint_private_access_cidrs          = [ var.vpc_cidr ]

    worker_groups = [
        {
            name                 = "staging-vd-workers"
            instance_type        = "t2.small"
            asg_desired_capacity = 1
            asg_max_size         = 3
            asg_min_size         = 1
            tags = [
                {
                    "key"                 = "Environment"
                    "propagate_at_launch" = "true"
                    "value"               = "staging"
                },
                {
                    "key"                 = "Organization"
                    "propagate_at_launch" = "true"
                    "value"               = "Emumba"
                }
            ]
        }
    ]

    map_users = [
        {
            userarn  = "arn:aws:iam::390665042662:user/waqas.kiyani"
            username = "waqas.kiyani"
            groups   = ["system:masters"]
        }
    ]

    tags = {
        Environment = "staging"
        Organization = "Emumba"
    }
}
