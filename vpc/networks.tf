#######################################################################################
#################### This tf file contains the following values: ######################
###################### VPC, Subnets, IGW, NAT GW, RTB, and SG #########################
#######################################################################################


# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.environment_tag}-vpc" }
}

# Subnets
resource "aws_subnet" "private" {
  count = 2  
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Private subnet-${(count.index + 1)}"
  }
}

resource "aws_subnet" "public" {
  count = 2  
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Public subnet-${(count.index + 1)}"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment_tag}-internet-gateway" 
  }
}


# NAT gateway
resource "aws_eip" "nat_gateway" {
  vpc = true
  count = 2
}

resource "aws_nat_gateway" "nat_gateway" {
  count = 2
  allocation_id = aws_eip.nat_gateway.*.id[count.index]
  subnet_id = aws_subnet.public.*.id[count.index]
  tags = {
    Name = "${var.environment_tag}-NAT-gateway-${(count.index + 1)}" 
  }
}


# Routing tables and associations
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { 
    Name = "${var.environment_tag}-public-rtb" 
    Description = "allows outbound traffic for the internet"
  }
}

resource "aws_route_table" "private-rtb" {
  count = 2
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.*.id[count.index]
  }
  tags = { 
    Name = "${var.environment_tag}-private-rtb-${(count.index + 1)}" 
    Description = "NAT gateway for private networks"
    }
}

resource "aws_route_table_association" "public-rtb" {
  count = 2 
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "private-rtb" {
  count = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private-rtb.*.id[count.index]
}


# Security groups for Web servers and DB
resource "aws_security_group" "web_servers" {
  name = "Web_servers"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {Name = "${var.environment_tag}-Web_servers"}
}

resource "aws_security_group" "db_servers" {
  name = "DB_servers"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {Name = "${var.environment_tag}-DB_servers"}
}