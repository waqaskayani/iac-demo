##############################################
########### VPC Configuration Start ##########
##############################################
data "aws_vpc" "vpc" {
  id = var.eks_vpc_id
}

##### Internet Gateway
data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

##### Public Subnets (as Data Source)
locals {
    public_subnet_id = "subnet-0fcb24caf9c0499e3"
}


##### Private Subnets
resource "aws_subnet" "private_subnets" {
  count                   = length(local.subnet_cidrs_private)
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = local.subnet_cidrs_private[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.additional_tags,
    {
    Name = "eks | Private-subnet | ${local.subnet_cidrs_private[count.index]} | ${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    },
  )
}

##### Private Route Table
resource "aws_route_table" "rtb_private" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = merge(
    var.additional_tags,
    {
    Name = "eks-private-rtb",
    },
  )
}

resource "aws_route_table_association" "rta_private_subnet" {
  count = length(local.subnet_cidrs_private)
  route_table_id = aws_route_table.rtb_private.id
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
}

##### EIP for NAT Gateway
resource "aws_eip" "eip_ngw" {
  vpc = true

  tags = merge(
    var.additional_tags,
    {
    Name = "eks-eip-ngw",
    },
  )
}

##### NAT Gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip_ngw.id
  subnet_id     = local.public_subnet_id

  tags = merge(
    var.additional_tags,
    {
    Name = "eks-ngw"
    },
  )
}

############################################
########### VPC Configuration End ##########
############################################


##### Wireguard SG
resource "aws_security_group" "wireguard_sg" {
  name   = "wireguard-sg"
  vpc_id = data.aws_vpc.vpc.id

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


#################
##### EKS SG ####
#################
resource "aws_security_group" "eks_cluster_sg" {
  name   = "eks-cluster-sg"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ data.aws_vpc.vpc.cidr_block ]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ module.eks.cluster_primary_security_group_id ]  # primary sg
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ module.eks.worker_security_group_id ]  # worker sg
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ module.eks.cluster_security_group_id ]  # additional sg
  }

ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
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

#### Rule for Worker SG
#### Worker SG
data "aws_security_group" "worker_sg" {
    id = module.eks.worker_security_group_id
}

resource "aws_security_group_rule" "worker_sg_rule_cluster" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks.cluster_primary_security_group_id
  security_group_id = data.aws_security_group.worker_sg.id

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "worker_sg_rule_access_sg" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id = data.aws_security_group.worker_sg.id

  lifecycle {
    create_before_destroy = true
  }
}

#### Rule for Additional SG
#### Additional SG
data "aws_security_group" "additional_sg" {
    id = module.eks.cluster_security_group_id
}

resource "aws_security_group_rule" "additional_sg_rule_cluster" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks.cluster_primary_security_group_id
  security_group_id = data.aws_security_group.additional_sg.id

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "additional_sg_rule_access_sg" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id = data.aws_security_group.additional_sg.id

  lifecycle {
    create_before_destroy = true
  }
}
