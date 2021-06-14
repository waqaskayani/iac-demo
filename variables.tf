variable "eks_vpc_id" {
    default     = var_eks_vpc_id
    type        = string
    description = "This input variable will set VPC used by EKS."
}

variable "region" {
    default     = var_region
    type        = string
    description = "This input variable will set region of resources."
}

variable "subnet_cidrs_private" {
    description = "Private Subnet CIDRs for eks"
    default = ["${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 201)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 202)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 203)}"]
    type = list
}

variable "subnet_cidrs_public" {
    description = "Public Subnet CIDRs for eks"
    default = ["${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 204)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 205)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 206)}"]
    type = list
}

variable "key_name" {
    default     = "vd-ohio-waqas"
    type        = string
}

variable "private_key_path" {
    default     = "/home/emumba/Work/07-Velocidata/ec2_pems/vd-ohio-waqas.pem"
    type        = string
}

variable "additional_tags" {
    default = {
        "CreatedBy" = "Waqas Kayani"
        "Purpose"   = "Testing EKS working for Velocidata"
    }
    description = "Additional resource tags"
    type        = map(string)
}
