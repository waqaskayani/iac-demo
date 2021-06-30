data "aws_eks_cluster" "cluster" {
    name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name  = module.eks.cluster_id
}

locals {
    cluster_name = var.cluster_name
}

module "eks" {
    source                          = "terraform-aws-modules/eks/aws"
    cluster_name                    = local.cluster_name
    cluster_version                 = var.cluster_version
    subnets                         = aws_subnet.private_subnets.*.id
    vpc_id                          = data.aws_vpc.vpc.id

    # Public Access
    cluster_endpoint_public_access                    = var.eks_public_access
    /* cluster_endpoint_public_access_cidrs              = var.eks_public_access_cidrs */

    # Private Access
    cluster_endpoint_private_access                   = var.eks_private_access
    cluster_create_endpoint_private_access_sg_rule    = var.eks_private_access
    /* cluster_endpoint_private_access_cidrs             = [ data.aws_vpc.vpc.cidr_block ]           # "18.191.140.48/32", "${aws_eip.eip[0].public_ip}/32"  */
    /* cluster_endpoint_private_access_sg                = [ aws_security_group.eks_cluster_sg.id ]  # List of sg ids that can access cluster. Edit "eks-cluster-sg" security group */

    cluster_enabled_log_types       = [ "api","audit","authenticator","controllerManager","scheduler" ]
    cluster_log_retention_in_days   = 60

    workers_additional_policies = [ aws_iam_policy.workers_autoscaling_policy.arn ]
    worker_groups = [
        {
            name                 = var.worker_names
            instance_type        = var.worker_instance_type
            asg_desired_capacity = var.worker_asg_desired
            asg_max_size         = var.worker_asg_max
            asg_min_size         = var.worker_asg_min
            root_volume_type     = "gp3"
            root_volume_size     = var.worker_volume_size
            key_name             = var.key_name
            /* ebs_optimized     = false
            enable_monitoring = false */

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
                },
                {
                    "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
                    "propagate_at_launch" = "true"
                    "value"               = "owned"
                },
                {
                    "key"                 = "k8s.io/cluster-autoscaler/enabled"
                    "propagate_at_launch" = "true"
                    "value"               = "true"
                }
            ]
        }
    ]

    map_users = [
        {
            userarn  = ""                   # add arn of the format: "arn:aws:iam::AWS_ACCOUNT_ID:user/USER_NAME"
            username = ""                   # add iam username
            groups   = ["system:masters"]
        }
    ]
}


#######################
####### EKS Cluster SG
#######################
#### Rule for Cluster SG
data "aws_security_group" "cluster_sg" {
    id = module.eks.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "cluster_sg_ingress_rule" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    description       = "Allow VPC CIDR to access EKS Private Cluster."
    cidr_blocks       = [ data.aws_vpc.vpc.cidr_block ]
    security_group_id = data.aws_security_group.cluster_sg.id      # security group to apply this rule to

    lifecycle {
        create_before_destroy = true
    }
}


############################
#### Helm Installations ####
############################

##### Addon Policies
/* resource "helm_release" "ebs_csi" {      # Pin version as desired
    name       = "aws-ebs-csi-driver"
    repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
    chart      = "aws-ebs-csi-driver"
    version    = ""
    namespace  = "kube-system"
}

resource "helm_release" "lb_controller" {        # Pin version as desired
    name       = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    version    = ""
    namespace  = "kube-system"
    set {
        name  = "clusterName"
        value = local.cluster_name
    }
} */
