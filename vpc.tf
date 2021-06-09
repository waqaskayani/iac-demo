module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Velocidata-EKS-VPC"
  cidr = var.vpc_cidr

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = ["${cidrsubnet(var.vpc_cidr, 8, 1)}", "${cidrsubnet(var.vpc_cidr, 8, 2)}", "${cidrsubnet(var.vpc_cidr, 8, 3)}"]
  public_subnets  = ["${cidrsubnet(var.vpc_cidr, 8, 101)}", "${cidrsubnet(var.vpc_cidr, 8, 102)}", "${cidrsubnet(var.vpc_cidr, 8, 103)}"]

  enable_nat_gateway = true
  single_nat_gateway  = true

  tags = {
    Purpose = "Testing EKS working for Velocidata"
    CreatedBy = "Waqas Kayani"
    ManagedBy = "Terraform"
  }
}