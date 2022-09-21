# Retrieves the resource info from AWS
data "aws_vpc" "main_vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc-${var.environment}"]
  }
  depends_on = [aws_vpc.main_vpc]
}

data "aws_availability_zones" "available_azs" {
  state = "available"
}