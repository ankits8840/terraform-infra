# Create a main vpc
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}
# Create internet gateway
resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-vpc-igw"
  }
}
# Create public subnets
resource "aws_subnet" "public_subnet_main_1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.0/26"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "public_subnet_main_2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.64/26"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"
  tags = {
    Name = "public-subnet-1b"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet_main_1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.128/26"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private-subnet-1a"
  }
}

resource "aws_subnet" "private_subnet_main_2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.192/26"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private-subnet-1b"
  }
}

resource "aws_subnet" "private_subnet_main_3" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/26"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private-subnet-1c"
  }
}

resource "aws_subnet" "private_subnet_main_4" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.64.0/26"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private-subnet-1d"
  }
}



#Create a elastic ip fot nat gateways
resource "aws_eip" "nat_gateway_main_1a" {
  vpc = true
}

resource "aws_eip" "nat_gateway_main_1b" {
  vpc = true
}

# Create NAT Gateway for each availability zone
resource "aws_nat_gateway" "nat_gateway_main_1" {
  allocation_id = aws_eip.nat_gateway_main_1a.id
  subnet_id = aws_subnet.public_subnet_main_1.id
  connectivity_type = "public"
}

resource "aws_nat_gateway" "nat_gateway_main_2" {
  allocation_id = aws_eip.nat_gateway_main_1b.id
  subnet_id = aws_subnet.public_subnet_main_2.id
  connectivity_type = "public"
}


# Create route table
resource "aws_route_table" "public_route_table_main" {
  vpc_id = aws_vpc.main_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.main_vpc_igw.id
     }
  tags = {
    Name = "public-route-table"
  }
}

# Create route table
resource "aws_route_table" "private_route_table_main_1" {
  vpc_id = aws_vpc.main_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat_gateway_main_1.id
     }
  tags = {
    Name = "private-route-table-1a"
  }
}
resource "aws_route_table" "private_route_table_main_2" {
  vpc_id = aws_vpc.main_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat_gateway_main_2.id
     }
  tags = {
    Name = "private-route-table-1b"
  }
}

# Associate public subnets with the route table
resource "aws_route_table_association" "public_subnet_main" {
  subnet_id = aws_subnet.public_subnet_main_1.id
  route_table_id = aws_route_table.public_route_table_main.id
}
# Associate public subnets with the route table
resource "aws_route_table_association" "public_subnet_main-1" {
  subnet_id = aws_subnet.public_subnet_main_2.id
  route_table_id = aws_route_table.public_route_table_main.id
}

# Associate private subnets with the route table
resource "aws_route_table_association" "private_subnet_main_1a" {
  subnet_id = aws_subnet.private_subnet_main_1.id
  route_table_id = aws_route_table.private_route_table_main_1.id
}

resource "aws_route_table_association" "private_subnet_main_1b" {
  subnet_id = aws_subnet.private_subnet_main_2.id
  route_table_id = aws_route_table.private_route_table_main_2.id
}



