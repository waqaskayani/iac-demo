module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Velocidata-EKS-VPC"
  cidr = var.eks_vpc_cidr

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = ["${cidrsubnet(var.eks_vpc_cidr, 8, 1)}", "${cidrsubnet(var.eks_vpc_cidr, 8, 2)}", "${cidrsubnet(var.eks_vpc_cidr, 8, 3)}"]
  public_subnets  = ["${cidrsubnet(var.eks_vpc_cidr, 8, 101)}", "${cidrsubnet(var.eks_vpc_cidr, 8, 102)}", "${cidrsubnet(var.eks_vpc_cidr, 8, 103)}"]

  enable_nat_gateway = true
  single_nat_gateway  = true

  enable_dns_hostnames = true

  tags = {
    Purpose = "Testing EKS working for Velocidata"
    CreatedBy = "Waqas Kayani"
    ManagedBy = "Terraform"
  }
}


#######################
##### Wireguard SG ####
#######################
resource "aws_security_group" "wireguard_sg" {
  name   = "wireguard-sg"
  vpc_id = module.vpc.vpc_id

  # SSH access from emumba vpn
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["182.191.83.208/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "wireguard-sg"
    }
}

/* 
######################
##### VPC Peering ####
######################
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = element(tolist(data.aws_vpcs.vpc.ids), 0)
  peer_owner_id = data.aws_caller_identity.current.account_id
  auto_accept   = true

  tags = {
    Name = "EKS VPC Peering Connection"
  }
}


# Retreiving vpc using vpc name to allow access to EKS Custer
data "aws_vpcs" "vpc" {
  tags = {
    Name = var.access_vpc_name
  }
} */
