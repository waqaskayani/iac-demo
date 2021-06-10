data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "aws_service_linked_role" {
    name = "AWSServiceRoleForAutoScaling"
}


data "aws_ami" "aws-linux-2" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm*"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
}