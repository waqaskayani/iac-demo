data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    cluster_name    = "vd-cluster"
    cluster_version = "1.17"  # use latest version
    subnets         = data.aws_subnet_ids.private_subnets.ids
    vpc_id          = module.vpc.vpc_id

    node_groups = {    # user worker
        private = {
            subnets          = data.aws_subnet_ids.private_subnets.ids
            desired_capacity = 1
            max_capacity     = 3
            min_capacity     = 1

            name_prefix      = "staging-vd-workers-"
            instance_types   = ["t2.small"]
            k8s_labels = {
                Environment  = "private"
            }

            tags = {
                Environment  = "staging"
                Organization = "Emumba"
            }
        }
    }

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
