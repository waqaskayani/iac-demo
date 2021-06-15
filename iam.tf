resource "aws_iam_instance_profile" "wireguard_instance_profile" {
    name = "wireguard-instance-profile"
    role = aws_iam_role.role_for_wg_instance.name
}

resource "aws_iam_role" "role_for_wg_instance" {
    name = "role-for-wg-instance"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": [
            "ec2.amazonaws.com"
            ]
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF

    tags = {
            Name = "role-for-wg-instance"
        }
}

resource "aws_iam_policy" "policy_for_wg_instance" {
    name        = "policy-for-wg-instance"
    policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEIPUpdate",
            "Effect": "Allow",
            "Action": [
                "ec2:DisassociateAddress",
                "ec2:AssociateAddress",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        }       
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
    role      = aws_iam_role.role_for_wg_instance.name
    policy_arn = aws_iam_policy.policy_for_wg_instance.arn
}



#########################
####### Role for Workers
#########################
resource "aws_iam_role" "role_for_workers" {
    name = "role-for-workers"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "EKSWorkerAssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF

    tags = {
            Name = "role-for-workers"
        }
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
    arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
    arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
    arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy" "policy_for_workers" {
    name        = "policy-for-workers"
    policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }       
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_1" {
    role      = aws_iam_role.role_for_workers.name
    policy_arn = aws_iam_policy.policy_for_workers.arn
}
resource "aws_iam_role_policy_attachment" "policy_attach_2" {
    role      = aws_iam_role.role_for_workers.name
    policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
}
resource "aws_iam_role_policy_attachment" "policy_attach_3" {
    role      = aws_iam_role.role_for_workers.name
    policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}
resource "aws_iam_role_policy_attachment" "policy_attach_4" {
    role      = aws_iam_role.role_for_workers.name
    policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
}
