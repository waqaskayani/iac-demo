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
resource "aws_iam_policy" "workers_autoscaling_policy" {
    name        = "workers-autoscaling-policy"
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
