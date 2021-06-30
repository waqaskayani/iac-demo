variable "eks_vpc_id" {
    default     = var_eks_vpc_id
    type        = string
    description = "This input variable will set VPC used by EKS."
}

variable "igw_id" {
    default     = var_igw_id
    type        = string
    description = "This input variable will set IGW used by public subnets."
}

variable "region" {
    default     = var_region
    type        = string
    description = "This input variable will set region of resources."
}

variable "project" {
    default     = "velocidata"
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


####################
###### Subnets #####
####################
variable "subnet_cidrs_private" {
    description = "Private Subnet CIDRs for eks"
    default = null
}

variable "subnet_cidrs_public" {
    description = "Public Subnet CIDRs for eks"
    default = null
}

# To change the subnet CIDRs, change the 201, 202, 203 etc. to desired values.
locals {
    private              = ["${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 201)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 202)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 203)}"]
    subnet_cidrs_private = var.subnet_cidrs_private == null ? local.private : var.subnet_cidrs_private
    public               = ["${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 204)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 205)}", "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 206)}"]
    subnet_cidrs_public  = var.subnet_cidrs_public == null ? local.public : var.subnet_cidrs_public
}


####################
###### EC2 Keys #####
####################
variable "key_name" {
    default     = ""                       # PEM key file name, without ".pem" extension
    type        = string
}

variable "private_key_path" {
    default     = ""                      # Absolute path to private PEM key file on instance where terraform scripts will run from 
    type        = string
}

########################
### EKS Modifications ##
########################

###### EKS Cluster
variable "cluster_name" {
    default     = "vd-staging-eks-cluster"
    type        = string
}

variable "cluster_version" {
    default     = "1.20"
    type        = string
}


###### EKS Access
variable "eks_public_access" {
    type        = bool
    default     = false
}

variable "eks_public_access_cidrs" {
    type    = list(string)
    default = [ "0.0.0.0/0" ]   # Enter any cidr to have access from, use only when public_access is true and private_access is false
}

variable "eks_private_access" {
    type        = bool
    default     = true          # when private access is true, EKS cluster automatically has access from within VPC
}


###### EKS Workers
variable "worker_names" {
    default     = "private-workers"
    type        = string
}

variable "worker_instance_type" {
    default     = "t2.small"
    type        = string
}

variable "worker_asg_max" {
    default     = "3"
    type        = string
}

variable "worker_asg_min" {
    default     = "1"
    type        = string
}

variable "worker_asg_desired" {
    default     = "1"
    type        = string
}

variable "worker_volume_size" {
    default     = "20"
    type        = string
}

