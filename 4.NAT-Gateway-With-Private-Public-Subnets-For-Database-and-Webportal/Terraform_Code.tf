provider "aws" {
    region  =  "ap-south-1"
}

resource "tls_private_key" "mytask4key"  {
   algorithm  =  "RSA"
 }

resource "aws_key_pair" "keypair1"  {
    key_name  =  "mytask4key"
    public_key  = tls_private_key.mytask4key.public_key_openssh
 
    depends_on  =  [
               tls_private_key.mytask4key
    ]
   
}

resource "local_file" "key-file" {
 content    = tls_private_key.mytask4key.private_key_pem
 filename   = "mytask4key.pem"
}

resource "aws_vpc" "myvpc1" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "myvpc1"
  }
}

resource "aws_subnet" "publicsub1" {
  vpc_id     = aws_vpc.myvpc1.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "publicsub1"
  }
}

resource "aws_subnet" "privatesub1" {
  vpc_id     = aws_vpc.myvpc1.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "privatesub1"
  }
}

resource "aws_internet_gateway" "ig_1" {
  vpc_id = aws_vpc.myvpc1.id

  tags = {
    Name = "ig_1"
  }
}

#public
resource "aws_route_table" "routet1" {
  vpc_id = aws_vpc.myvpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_1.id
  }
  tags = {
    Name = "routet1"
  }
}

resource "aws_route_table_association" "rta_sub_public" {
  subnet_id      = aws_subnet.publicsub1.id
  route_table_id = aws_route_table.routet1.id
}

resource "aws_eip" "eip1" {
  vpc = "true"
  tags = {
    Name = "eip1"
    }
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = "aws_eip.eip1.id"
  subnet_id     = "aws_subnet.publicsubnet1.id"
  
  tags = {
    Name = "nat_gateway1"
  }
}

#private
resource "aws_route_table" "routet2" {
  vpc_id = aws_vpc.myvpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "aws_internet_gateway.nat_gateway1.id"
  }
  tags = {
    name = "nat_gateway1"
  }
}

resource "aws_route_table_association" "rta_sub_private" {
  subnet_id      = aws_subnet.privatesub1.id
  route_table_id = aws_route_table.routet2.id
}

resource "aws_security_group" "sg_wp1" {
  name        = "My Wordpress Security Group"
  description = "HTTP , SSH , ICMP"
  vpc_id      =  aws_vpc.myvpc1.id


  ingress {
    description = "HTTP Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "MYSQL Port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "securitygroup"
  }
}

resource "aws_security_group" "sg_mysql1" {
  name = "My MYSQL Security Group"
  description = "MYSQL Security Group"
  vpc_id = aws_vpc.myvpc1.id
 
 ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.sg_wp1.id]
  }

  ingress {
      description = "Allow SSH for Bastion Host"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      security_groups = [aws_security_group.sg_bastion1.id]
   }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags ={
    
    Name= "mysql"
  }
}

#Creating S.G. for Bastion Host
resource "aws_security_group" "sg_bastion1" {
   name        = "allow_Bastion"
   description = "Allow SSH inbound traffic"
   vpc_id = aws_vpc.myvpc1.id
   ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
      Name = "sg_bastion1"
   }
}

#launcing wordpress AMI 
resource "aws_instance" "wp_os1" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.publicsub1.id
  vpc_security_group_ids = [aws_security_group.sg_wp1.id]
  key_name = aws_key_pair.keypair1.key_name
  availability_zone = "ap-south-1a"
  associate_public_ip_address = "true"

  tags = {
    Name = "wp_os1"
  }
}

#launching mysql AMI
resource "aws_instance" "mysql_os1" {
  ami           = "ami-0a7b8d5a2575a98f7"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.privatesub1.id
  vpc_security_group_ids = [aws_security_group.sg_mysql1.id , aws_security_group.sg_bastion1.id]
  key_name = aws_key_pair.keypair1.key_name
  availability_zone = "ap-south-1b"
  tags ={
    
    Name= "mysql_os1"
  }
}

#Creating EC2 instance for Bastion Host
resource "aws_instance" "bastion_host" {
    ami    = "ami-052c08d70def0ac62"
    instance_type   = "t2.micro"
    subnet_id   = aws_subnet.publicsub1.id    
    vpc_security_group_ids = [aws_security_group.sg_bastion1.id]
    key_name   = aws_key_pair.keypair1.key_name
    availability_zone = "ap-south-1a"
    associate_public_ip_address = "true"
    
    tags       = {
       Name   = "Bastion Host"
    }
}

