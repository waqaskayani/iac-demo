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

/* variable "access_vpc_name" {
    default     = var_access_vpc_name
    type        = string
    description = "This input variable will set VPC that will have access to EKS Cluster."
} */

variable "key_name" {
    default     = "vd-ohio-waqas"
    type        = string
}

variable "private_key_path" {
    default     = "/home/emumba/Work/07-Velocidata/ec2_pems/vd-ohio-waqas.pem"
    type        = string
}
