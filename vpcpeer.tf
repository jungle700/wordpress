resource "aws_vpc_peering_connection" "foo" {
 # peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.default.id
  vpc_id        = aws_vpc.foo.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between foo and bar"
  }
}

#....................................route VPC_A to VPC_B.....................................
resource "aws_route" "primary2secondary" {
  # ID of VPC 1 main route table.
  route_table_id = aws_route_table.eu-west-1a-prometh.id

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = "10.1.0.0/20"

  # ID of VPC peering connection.
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}


#.........................................route VPC_B to VPC_A..........................
resource "aws_route" "secondary2primary" {
  # ID of VPC 2 main route table.
  route_table_id = aws_route_table.eu-west-1a-prometh.id

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = "10.0.0.0/20"

  # ID of VPC peering connection.
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}