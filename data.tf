data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "aws_service_linked_role" {
    name = "AWSServiceRoleForAutoScaling"
}

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

locals {
    cluster_name = var.cluster_name
}

