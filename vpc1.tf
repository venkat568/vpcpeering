resource "aws_vpc" "test" {
 
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.vpc_name}"
  }

}

resource "aws_internet_gateway" "testigw" {

  vpc_id = aws_vpc.test.id
  tags = {
    "Name" = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public1" {
  
  vpc_id                  = aws_vpc.test.id
  cidr_block              = var.public1_cidr_block
  availability_zone       = var.azs
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.vpc_name}-public1"
  }
}


resource "aws_subnet" "public2" {
 
  vpc_id                  = aws_vpc.test.id
  cidr_block              = var.public2_cidr_block
  availability_zone       = var.azs1
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.vpc_name}-public12"
  }
}

resource "aws_route_table" "rt" {
   vpc_id = aws_vpc.test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testigw.id
    
  }
  tags = {
    "Name" = "${var.vpc_name}-rt"
  }
}


resource "aws_route_table_association" "publicsubnet1" {

  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "publicsubnet2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route" "communication" {

    route_table_id = aws_route_table.rt.id
    destination_cidr_block = var.cidr_block_1
    vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id
  
}
resource "aws_security_group" "test-sg" {
  vpc_id      = aws_vpc.test.id
  name        = "allow all rules"
  description = "allow inbound and outbound rules"
  tags = {
    "Name" = "${var.vpc_name}-sg"
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


resource "aws_instance" "test-instance" {

  ami                         = "ami-0261755bbcb8c4a84"
  key_name                    = "krishika"
  instance_type               = "t2.micro"
  vpc_security_group_ids =  [aws_security_group.test-sg.id]
  subnet_id                   = aws_subnet.public1.id
  availability_zone           = "us-east-1a"
  private_ip = "10.20.1.5"
  associate_public_ip_address = true
  tags = {
    "Name" = "${var.vpc_name}-server"
  }

}