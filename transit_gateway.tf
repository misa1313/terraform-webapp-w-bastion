##########################################################################
# Transit gateway - VPC attachments
##########################################################################

resource "aws_ec2_transit_gateway" "transit-gtw" {
 
  description                     = "Transit Gateway for two VPCs"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = {
    Name        = "transit-gtw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "primary-vpc-attachment" {
 
  subnet_ids         = [aws_subnet.public-subnet.id, aws_subnet.private-subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.transit-gtw.id
  vpc_id             = aws_vpc.primary-vpc.id
  tags = {
    "Name" = "transit-gateway-attachment1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "secondary-vpc-attachment" {
 
  subnet_ids         = [aws_subnet.secondary-subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.transit-gtw.id
  vpc_id             = aws_vpc.secondary-vpc.id
  tags = {
    "Name" = "transit-gateway-attachment2"
  }
}

##########################################################################
# Routes that need to go through the transit gateway
##########################################################################

resource "aws_route" "tgw-route-1" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "172.16.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.transit-gtw.id
  depends_on = [
    aws_ec2_transit_gateway.transit-gtw
  ]
}

resource "aws_route" "tgw-route-2" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "172.16.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.transit-gtw.id
  depends_on = [
    aws_ec2_transit_gateway.transit-gtw
  ]
}

resource "aws_route" "tgw-route-3" {
  
  route_table_id         = aws_route_table.secondary-route-table.id
  destination_cidr_block = "172.32.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.transit-gtw.id
  depends_on = [
    aws_ec2_transit_gateway.transit-gtw
  ]
}