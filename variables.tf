variable "eks_vpc_cidr" {
    default     = var_eks_vpc_cidr
    type        = string
    description = "This input variable will set CIDR range of VPC used by EKS."
}

variable "region" {
    default     = var_region
    type        = string
    description = "This input variable will set region of resources."
}

variable "access_vpc_cidr" {
    default     = var_access_vpc_cidr
    type        = string
    description = "This input variable will set CIDR range of VPC that will have access to EKS Cluster."
}
