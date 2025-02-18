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

##### Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(local.subnet_cidrs_public)
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = local.subnet_cidrs_public[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.additional_tags,
    {
    Name = "eks | Public-subnet | ${local.subnet_cidrs_public[count.index]} | ${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"             = "1"
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

##### Public Route Table
resource "aws_route_table" "rtb_public" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = merge(
    var.additional_tags,
    {
    Name = "eks-public-rtb",
    },
  )
}

resource "aws_route_table_association" "rta_public_subnet" {
  count = length(local.subnet_cidrs_public)
  route_table_id = aws_route_table.rtb_public.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
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
  subnet_id     = aws_subnet.public_subnets.0.id

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
##### RDS SG
resource "aws_security_group" "rds_sg" {
  name   = "velocidata-rds-sg"
  vpc_id = data.aws_vpc.vpc.id

  # SSH access from emumba vpn
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [ data.aws_vpc.vpc.cidr_block ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = merge(
        var.additional_tags,
        {
        "Name" = "velocidata-rds-sg"
        },
    )
}


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

    tags = merge(
        var.additional_tags,
        {
        "Name" = "wireguard-sg"
        },
    )
}
