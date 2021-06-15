data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

locals {
    cluster_name = "vd-staging-eks-cluster"
}

module "eks" {
    source                          = "terraform-aws-modules/eks/aws"
    cluster_name                    = local.cluster_name
    cluster_version                 = "1.20"
    subnets                         = aws_subnet.private_subnets.*.id
    vpc_id                          = data.aws_vpc.vpc.id

    # Public Access
    cluster_endpoint_public_access                    = false
    /* cluster_endpoint_public_access_cidrs              = [ "${aws_eip.eip.public_ip}/32", "18.191.140.48/32" ] */

    # Private Access
    cluster_endpoint_private_access                   = true
    cluster_create_endpoint_private_access_sg_rule    = true
    /* cluster_endpoint_private_access_cidrs             = [ data.aws_vpc.vpc.cidr_block ]           # "18.191.140.48/32", "${aws_eip.eip.public_ip}/32"  */
    /* cluster_endpoint_private_access_sg                = [ aws_security_group.eks_cluster_sg.id ]  # List of sg ids that can access cluster. Edit "eks-cluster-sg" security group */

    cluster_enabled_log_types       = [ "api","audit","authenticator","controllerManager","scheduler" ]
    cluster_log_retention_in_days   = 60

    worker_groups = [
        {
            name                 = "private-workers"
            instance_type        = "t2.small"
            asg_desired_capacity = 1
            asg_max_size         = 3
            asg_min_size         = 1
            root_volume_type     = "gp3"
            root_volume_size     = 8
            workers_additional_policies = [ aws_iam_policy.policy_for_workers.arn ]
            /* ami_id               = "ami-0000000000"
            ebs_optimized     = false
            key_name          = "all"
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
            userarn  = "arn:aws:iam::390665042662:user/waqas.kiyani"
            username = "waqas.kiyani"
            groups   = ["system:masters"]
        },
        {
            userarn  = "arn:aws:iam::390665042662:user/Husnerabbi"
            username = "Husnerabbi"
            groups   = ["system:masters"]
        }
    ]
}


############################
#### Helm Installations ####
############################

##### Addon Policies
/* resource "helm_release" "ebs_csi" {      # Pin versions
    name       = "aws-ebs-csi-driver"
    repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
    chart      = "aws-ebs-csi-driver"
    namespace  = "kube-system"
}

resource "helm_release" "lb_controller" {        # Pin versions
    name       = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace  = "kube-system"
    set {
        name  = "clusterName"
        value = local.cluster_name
    }
} */

resource "helm_release" "cluster_autoscaler" {      # Pin versions
    name       = "autoscaler"
    repository = "https://kubernetes.github.io/autoscaler"
    chart      = "cluster-autoscaler"
    namespace  = "kube-system"
    version    = "9.9.2"
    set {
        name  = "autoDiscovery.clusterName"
        value = local.cluster_name
    }
    set {
        name  = "autoscalingGroups[0].name"
        value = module.eks.workers_asg_names[0]
    }
}


/* ##### Ingress Controller
resource "helm_release" "emissary_ingress" {
    name       = "emissary-ingress"
    repository = "https://s3.amazonaws.com/datawire-static-files/emissary-charts"
    chart      = "emissary-ingress"
    create_namespace = true
    namespace  = "ambassador"
    set {
        name      = "metadata.annotations.kubernetes\\.io/ingress\\.class"
        value     = "alb"
        type      = "string"
    }
} */
