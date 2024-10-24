resource "aws_vpc_peering_connection" "owner" {
 peer_owner_id = "009160051410"
  peer_vpc_id   = aws_vpc.prod.id
  vpc_id        = aws_vpc.test.id
  peer_region =  "us-east-2"
  auto_accept = false
   tags = {
     "Name" = "prod-dev"
   }

}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider = aws.central
    vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
    auto_accept = true
    tags = {
        "Name" = "Accepter"
    }
  

}
