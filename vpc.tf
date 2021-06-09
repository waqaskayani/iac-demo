module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Velocidata-EKS-VPC"
  cidr = var.vpc_cidr

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = ["${cidrsubnet(var.vpc_cidr, 8, 1)}", "${cidrsubnet(var.vpc_cidr, 8, 2)}", "${cidrsubnet(var.vpc_cidr, 8, 3)}"]
  public_subnets  = ["${cidrsubnet(var.vpc_cidr, 8, 101)}", "${cidrsubnet(var.vpc_cidr, 8, 102)}", "${cidrsubnet(var.vpc_cidr, 8, 103)}"]

  enable_nat_gateway = true
  single_nat_gateway  = true

  enable_dns_hostnames = true

  tags = {
    Purpose = "Testing EKS working for Velocidata"
    CreatedBy = "Waqas Kayani"
    ManagedBy = "Terraform"
  }
}


data "aws_subnet_ids" "private_subnets" {
  vpc_id = module.vpc.vpc_id

  filter {
    name   = "cidr-block"
    values = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 3)]
  }
}