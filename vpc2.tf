
resource "aws_vpc" "prod" {
  provider = aws.central
  cidr_block           = var.cidr_block_1
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.vpc1_name}"
  }

}

resource "aws_internet_gateway" "prodigw" {
  provider = aws.central
  vpc_id = aws_vpc.prod.id
  tags = {
    "Name" = "${var.vpc1_name}-igw"
  }
}

resource "aws_subnet" "publicsubnet1" {
  count=2
  provider = aws.central
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = element(var.publicsubnet1_cidr_block,count.index)
  availability_zone       = element(var.azs1,count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.vpc1_name}-public${count.index+1}"
  }
}



resource "aws_route_table" "rtable" {
  provider = aws.central
  vpc_id = aws_vpc.prod.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prodigw.id
  }
  tags = {
    "Name" = "${var.vpc1_name}-rt"
  }
}

resource "aws_route_table_association" "publicsubnet_1" {
  count=2
  provider = aws.central
  subnet_id      = element(aws_subnet.publicsubnet1.*.id,count.index)
  route_table_id = aws_route_table.rtable.id
}

resource "aws_route" "communication1" {
   provider = aws.central
    route_table_id = aws_route_table.rtable.id
    destination_cidr_block = var.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
}
resource "aws_security_group" "prod-sg" {
  provider = aws.central
  vpc_id      = aws_vpc.prod.id
  name        = "allow all rules"
  description = "allow inbound and outbound rules"
  tags = {
    "Name" = "${var.vpc1_name}-sg"
  }
  ingress {
    description = "allow all rules"
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all rules"
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "prod-instance" {
  provider = aws.central
  ami                         = "ami-024e6efaf93d85776"
  key_name                    = "krishika"
  instance_type               = "t2.micro"
  vpc_security_group_ids =  [aws_security_group.prod-sg.id]
  subnet_id                   = aws_subnet.publicsubnet1[0].id
  availability_zone           = "us-east-2a"
  private_ip = "10.30.1.5"
  associate_public_ip_address = true
  tags = {
    "Name" = "${var.vpc1_name}-server"
  }

}