/*
Forcing terraform to always use the
same aws provider version
*/
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.31"
    }
  }
}

provider "aws" {
  region = var.aws_region
}