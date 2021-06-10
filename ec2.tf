resource "aws_launch_configuration" "wireguard_lc" {
    name_prefix           = "wireguard-lc"
    image_id              = data.aws_ami.ubuntu.id
    instance_type         = "t2.small"
    key_name              = var.key_name
    enable_monitoring     = false
    ebs_optimized         = false
    security_groups       = [aws_security_group.wireguard_sg.id]
    user_data = <<-EOF
    #!/bin/bash
    apt update -y

EOF
    lifecycle {
        create_before_destroy = true
    }
}

### APP Autoscaling Group ###

resource "aws_autoscaling_group" "wireguard_asg" {
    name                 = "wireguard-asg"
    launch_configuration = aws_launch_configuration.wireguard_lc.name
    min_size             = 1
    max_size             = 1
    desired_capacity     = 1
    health_check_type    = "EC2"
    health_check_grace_period = 240
    vpc_zone_identifier   = data.aws_subnet_ids.public_subnets.ids
    service_linked_role_arn = data.aws_iam_role.aws_service_linked_role.arn

    lifecycle {
        create_before_destroy = true
    }

    tags = concat(
    [
        {
        "key" = "Name"
        "value" = "wireguard-asg"
        "propagate_at_launch" = true
        },
        {
        "key" = "CreatedBy"
        "value" = "Waqas Kayani"
        "propagate_at_launch" = true
        }
    ])
}
