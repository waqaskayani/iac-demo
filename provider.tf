terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "3.43.0"
      }
      kubernetes = {
        source = "hashicorp/kubernetes"
        version = "1.13.4"
      }
      kubectl = {
        source  = "gavinbunney/kubectl"
        version = "1.11.1"
      }
      helm = {
        source = "hashicorp/helm"
        version = "2.2.0"
      }
    }
}



provider "aws" {
  region = var.region
}

provider "kubernetes" {
    host                   = data.aws_eks_cluster[0].cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster[0].cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth[0].cluster.token
    load_config_file       = false
}


provider "kubectl" {
    host                   = data.aws_eks_cluster[0].cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster[0].cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth[0].cluster.token
    load_config_file       = false
}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster[0].cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster[0].cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth[0].cluster.token
  }
}
