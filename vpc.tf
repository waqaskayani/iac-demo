module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "EKS-VPC"
  cidr = var.vpc_cidr

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Purpose = "Testing EKS working for Velocidata"
    CreatedBy = "Waqas Kayani"
  }
}