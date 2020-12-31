provider "aws" {
    region  =  "ap-south-1"
}

resource "tls_private_key" "mytask3key"  {
   algorithm  =  "RSA"
 }

resource "aws_key_pair" "keypair1"  {
    key_name  =  "mytask3key"
    public_key  = tls_private_key.mytask3key.public_key_openssh
 
    depends_on  =  [
               tls_private_key.mytask3key
    ]
   
}

resource "aws_vpc" "myvpc1" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc1"
  }
}

resource "aws_subnet" "publicsub1" {
  vpc_id     = aws_vpc.myvpc1.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
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

#launcing wordpress AMI 
resource "aws_instance" "wp_os1" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.publicsub1.id
  vpc_security_group_ids = [aws_security_group.sg_wp1.id]
  key_name = aws_key_pair.keypair1.key_name
  availability_zone = "ap-south-1a"


  tags = {
    Name = "wp_os1"
  }
}

#launching mysql AMI
resource "aws_instance" "mysql_os1" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.privatesub1.id
  vpc_security_group_ids = [aws_security_group.sg_mysql1.id]
  key_name = aws_key_pair.keypair1.key_name
  availability_zone = "ap-south-1b"
 tags ={
    
    Name= "mysql_os1"
  }
}

