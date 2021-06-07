resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cird
  instance_tenancy = "default"

  tags = {
    Name = "demo-vpc"
    Purpose = "Jenkins Demo"
  }
}
