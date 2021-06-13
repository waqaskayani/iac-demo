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

  ingress {
    from_port   = 54321
    to_port     = 54321
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
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


######################
##### VPC Peering ####
######################
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = "vpc-0e97b99574d5e3eb6"
  peer_owner_id = data.aws_caller_identity.current.account_id
  auto_accept   = true

  tags = {
    Name = "EKS VPC Peering Connection"
  }
}


#################
##### EKS SG ####
#################
resource "aws_security_group" "eks_cluster_sg" {
  name   = "eks-cluster-sg"
  vpc_id = module.vpc.vpc_id

  # SSH access from emumba vpn
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ module.vpc.vpc_cidr_block ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "18.191.140.48/32" ]   # Jenkins Public IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "eks-cluster-sg"
    }
}
