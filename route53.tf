resource "aws_route53_resolver_endpoint" "eks_endpoint" {
    name      = "Inbound-EKS-Endpoint"
    direction = "INBOUND"

    security_group_ids = [
        aws_security_group.route53_sg.id
    ]

    ip_address {
        subnet_id = module.vpc.private_subnets[0]
    }

    tags = {
        Name      = "Inbound-EKS-Endpoint"
    }
}