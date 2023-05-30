# Define the VPC peering connection
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = aws_vpc.database_vpc.id
  vpc_id      = aws_vpc.main_vpc.id

  # Allow traffic between the VPCs
  auto_accept = true

  # Optional tags for the VPC peering connection
  tags = {
    Name = "vpc-peering-connection"
  }
}


  # Add a route for the VPC peering connection
  
  resource "aws_route" "main-vpc" {
    destination_cidr_block     = aws_vpc.main_vpc.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = aws_route_table.public_route_table_db.id
  }


  resource "aws_route" "database-vpc" {
    destination_cidr_block     = aws_vpc.database_vpc.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
    route_table_id = aws_route_table.public_route_table_main.id
  }

resource "aws_route" "main-private-route-1a" {
  route_table_id = aws_route_table.private_route_table_main_1.id
  destination_cidr_block = aws_vpc.database_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
 } 
 
 resource "aws_route" "main-private-route-1b" {
  route_table_id = aws_route_table.private_route_table_main_2.id
  destination_cidr_block = aws_vpc.database_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
 } 
 
 resource "aws_route" "database-private-route-1a" {
  route_table_id = aws_route_table.private_route_table_db_1.id
  destination_cidr_block = aws_vpc.main_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
 } 
 resource "aws_route" "database-private-route-1b" {
  route_table_id = aws_route_table.private_route_table_db_2.id
  destination_cidr_block = aws_vpc.main_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
 } 
