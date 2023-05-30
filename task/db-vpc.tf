# Create a database vpc
resource "aws_vpc" "database_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "database-vpc"
  }
}
# Create internet gateway
resource "aws_internet_gateway" "database_vpc_igw" {
  vpc_id = aws_vpc.database_vpc.id
  tags = {
    Name = "database-vpc-igw"
     }
 depends_on = [aws_subnet.public_subnet_db_1, aws_subnet.public_subnet_db_2]
}
# Create public subnets
resource "aws_subnet" "public_subnet_db_1" {
  vpc_id = aws_vpc.database_vpc.id
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "public_subnet_db_2" {
  vpc_id = aws_vpc.database_vpc.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"
  tags = {
    Name = "public-subnet-1b"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet_db_1" {
  vpc_id = aws_vpc.database_vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private-subnet-1a"
  }
}

resource "aws_subnet" "private_subnet_db_2" {
  vpc_id = aws_vpc.database_vpc.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private-subnet-1b"
  }
}

resource "aws_subnet" "private_subnet_db_3" {
  vpc_id = aws_vpc.database_vpc.id
  cidr_block = "192.168.4.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private-subnet-1c"
  }
}

resource "aws_subnet" "private_subnet_db_4" {
  vpc_id = aws_vpc.database_vpc.id
  cidr_block = "192.168.5.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private-subnet-1d"
  }
}



#Create a elastic ip fot nat gateways
resource "aws_eip" "nat_gateway_db_1a" {
  vpc = true
}

resource "aws_eip" "nat_gateway_db_1b" {
  vpc = true
}

# Create NAT Gateway for each availability zone
resource "aws_nat_gateway" "nat_gateway_db_1" {
  allocation_id = aws_eip.nat_gateway_db_1a.id
  subnet_id = aws_subnet.public_subnet_db_1.id
  connectivity_type = "public"
  depends_on = [aws_eip.nat_gateway_db_1a]
}

resource "aws_nat_gateway" "nat_gateway_db_2" {
  allocation_id = aws_eip.nat_gateway_db_1b.id
  subnet_id = aws_subnet.public_subnet_db_2.id
  connectivity_type = "public"
    depends_on = [aws_eip.nat_gateway_db_1b]
}


# Create route table
resource "aws_route_table" "public_route_table_db" {
  vpc_id = aws_vpc.database_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.database_vpc_igw.id
     }
  tags = {
    Name = "public-route-table"
  }
  depends_on = [aws_internet_gateway.database_vpc_igw]
}

# Create route table
resource "aws_route_table" "private_route_table_db_1" {
  vpc_id = aws_vpc.database_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat_gateway_db_1.id
     }
  tags = {
    Name = "private-route-table-1a"
  }
  depends_on = [aws_nat_gateway.nat_gateway_db_1]
}
resource "aws_route_table" "private_route_table_db_2" {
  vpc_id = aws_vpc.database_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat_gateway_db_2.id
     }
  tags = {
    Name = "private-route-table-1b"
  }
  depends_on = [aws_nat_gateway.nat_gateway_db_2]
}

# Associate public subnets with the route table
resource "aws_route_table_association" "public_subnet_db" {
  subnet_id = aws_subnet.public_subnet_db_1.id
  route_table_id = aws_route_table.public_route_table_db.id
  depends_on = [aws_route_table.public_route_table_db]
}
# Associate public subnets with the route table
resource "aws_route_table_association" "public_subnet_db-1" {
  subnet_id = aws_subnet.public_subnet_db_2.id
  route_table_id = aws_route_table.public_route_table_db.id
  depends_on = [aws_route_table.public_route_table_db]
}

# Associate private subnets with the route table
resource "aws_route_table_association" "private_subnet_db_1a" {
  subnet_id = aws_subnet.private_subnet_db_1.id
  route_table_id = aws_route_table.private_route_table_db_1.id
  depends_on = [aws_route_table.private_route_table_db_1]
}

resource "aws_route_table_association" "private_subnet_db_1b" {
  subnet_id = aws_subnet.private_subnet_db_2.id
  route_table_id = aws_route_table.private_route_table_db_2.id
  depends_on = [aws_route_table.private_route_table_db_2]
}


