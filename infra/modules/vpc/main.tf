#VPC
resource "aws_vpc" "vpc_it_tools" {
  cidr_block = var.vpc_cidrblock
}

#IGW
resource "aws_internet_gateway" "igw_it_tools" {
  vpc_id = aws_vpc.vpc_it_tools.id
}

#Subnets
resource "aws_subnet" "ecs_subnets" {
  for_each          = var.ecs_subnets
  vpc_id            = aws_vpc.vpc_it_tools.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = var.tags
}

#NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway_it_tools" {
  availability_mode = "regional"
  allocation_id     = aws_eip.nat_eip.id
  vpc_id            = aws_vpc.vpc_it_tools.id

  depends_on = [aws_internet_gateway.igw_it_tools]
}


#Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_it_tools.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_it_tools.id
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_it_tools.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_it_tools.id
  }
}



#Route Table Associations
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.ecs_subnets["public-1"].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.ecs_subnets["public-2"].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.ecs_subnets["private-1"].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.ecs_subnets["private-2"].id
  route_table_id = aws_route_table.private_route_table.id
}