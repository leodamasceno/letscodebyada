# Creates the VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_range
  instance_tenancy = var.vpc_tenancy

  tags = {
    Name = "vpc-${var.environment}"
    Environment = var.environment
  }
}