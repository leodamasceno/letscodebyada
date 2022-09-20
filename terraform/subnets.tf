# Private Subnet
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets)
  vpc_id                  = data.aws_vpc.main_vpc.id
  cidr_block              = element(var.private_subnets, count.index)
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${data.aws_availability_zones.available_azs.names[count.index]}-private-subnet"
    Environment = var.environment
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = data.aws_vpc.main_vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${data.aws_availability_zones.available_azs.names[count.index]}-public-subnet"
    Environment = var.environment
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.main_vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  count      = length(var.public_subnets)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# NAT
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnets)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)

  tags = {
    Name        = "${var.environment}-${data.aws_availability_zones.available_azs.names[count.index]}-nat"
    Environment = var.environment
  }
}

# Private route table
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = data.aws_vpc.main_vpc.id

  tags = {
    Name        = "${var.environment}-private-route-table-${count.index}"
    Environment = var.environment
  }
}

# Public route table
resource "aws_route_table" "public" {
  count  = length(var.public_subnets)
  vpc_id = data.aws_vpc.main_vpc.id

  tags = {
    Name        = "${var.environment}-public-route-table-${count.index}"
    Environment = var.environment
  }
}

# Route for IGW
resource "aws_route" "public_internet_gateway" {
  count                  = length(var.public_subnets)
  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  count                  = length(var.private_subnets)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}

# Route table associations for public subnet
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

# Route table associations for private subnet
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}