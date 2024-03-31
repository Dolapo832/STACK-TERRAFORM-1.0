#creating vpc
resource "aws_vpc" "stack-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "stack-vpc"
  }
}


#creating the private-subnet-1
resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.stack-vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

#creating the private-subnet-2
resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.stack-vpc.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

#creating the public-subnet-1
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.stack-vpc.id
  cidr_block = "10.0.20.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

#creating the public-subnet-2
resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.stack-vpc.id
  cidr_block = "10.0.21.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

#Creating the Internet gateway 
resource "aws_internet_gateway" "stack-igw" {
  vpc_id = aws_vpc.stack-vpc.id
  tags = {
    Name = "stack-vpc-IGW"
    }
}

#Creating the Route the table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.stack-vpc.id
  tags = {
    Name = "public-route-table"
  }
}

#route table association
resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.stack-igw.id
}

resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}

#Create an EIP for the NAT-gateway 
resource "aws_eip" "nat-eip" {
   tags = {
      Name = "nat-eip"
      }
}

#Create a NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
      Name = "nat-gateway"
      }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         =  aws_route_table.private-route-table.id # Specify the ID of your route table
  destination_cidr_block = "0.0.0.0/0"     # Route all internet-bound traffic
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id  # Specify the ID of your NAT Gateway
}


#creating a private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.stack-vpc.id
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private-subnet-1-association" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "private-subnet-2-association" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_instance" "baston-server" {
  depends_on = [aws_efs_mount_target.alpha_subnet1,aws_efs_mount_target.alpha_subnet2, aws_db_instance.CLIXX_DB]
  ami                     = data.aws_ami.stack_ami.id
  instance_type           = var.instance_type
  user_data = base64encode(data.template_file.bootstrap.rendered)
  key_name                = aws_key_pair.Stack_KP.key_name
  associate_public_ip_address = true
  subnet_id               = aws_subnet.public-subnet-1.id
  security_groups         = [aws_security_group.stack-sg.id]
     root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted= "true"
  }
  tags = {
   Name = "Application_Server_blog"
   Environment = var.environment
   OwnerEmail = var.OwnerEmail
}
}

resource "aws_instance" "baston-server2" {
  depends_on = [aws_efs_mount_target.alpha_subnet1,aws_efs_mount_target.alpha_subnet2, aws_db_instance.CLIXX_DB]
  ami                     = data.aws_ami.stack_ami.id
  instance_type           = var.instance_type
  user_data = base64encode(data.template_file.bootstrap.rendered)
  key_name                = aws_key_pair.Stack_KP.key_name
  associate_public_ip_address = true
  subnet_id               = aws_subnet.public-subnet-2.id
  security_groups         = [aws_security_group.stack-sg.id]
     root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted= "true"
  }
  tags = {
   Name = "Application_Server_blog"
   Environment = var.environment
   OwnerEmail = var.OwnerEmail
}
}



