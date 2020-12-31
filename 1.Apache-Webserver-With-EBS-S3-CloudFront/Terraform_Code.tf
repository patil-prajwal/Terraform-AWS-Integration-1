#Access codes for AWS
provider "aws" {
  region     = "<Add_Region_ID>"
  access_key = "<Add_Your_AWS_Access_Key>"
  secret_key = "<Add_Your_AWS_Security_Key>"
}


#Creating Security group
resource "aws_security_group" "sg_1" {
  name        = "sg_1"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-0ae1fc62"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = "sg_1"
  }
}

#Creating EBS volume
resource "aws_ebs_volume" "ebsvol1" {
  availability_zone = "${aws_instance.web_server1.availability_zone}"
  size = 1
  tags = {
    Name = "ebsvol1"
  }
}

#Creating EC2 instance

resource "aws_instance" "web_server1" {
    ami = "ami-0447a12f28fddb066"
    instance_type = "t2.micro"
    key_name = "Key1"
    security_groups = ["sg_1"]
    connection {
        type = "ssh"
        user = "ec2-user"
        # Add Your Key Location
        private_key = file("Key1.pem")
        host = aws_instance.web_server1.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum install httpd  php git -y",
            "sudo systemctl restart httpd",
            "sudo systemctl enable httpd",
        ]
    }
    tags = {
        Name = "web_server1"
    }
}

#Configuration and Mounting Github repo
resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.AttachVol,
]

connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("Key1.pem")
    host = aws_instance.web_server1.public_ip
}
provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",

      # Add Github Repository URL Below
      "sudo git clone https://github.com/<Repo_URL> /var/www/html/"
    ]
  }
}

#Attaching EBS with EC2
resource "aws_volume_attachment" "AttachVol" {
   device_name = "/dev/sdh"
   volume_id   =  "${aws_ebs_volume.ebsvol1.id}"
   instance_id = "${aws_instance.web_server1.id}"
   depends_on = [
       aws_ebs_volume.ebsvol1,
       aws_instance.web_server1
   ]
 }

#Creating S3 bucket
resource "aws_s3_bucket" "psp278270" {
  bucket = "psp278270"
  acl    = "public-read"
}

#Uploading file to S3 bucket
resource "aws_s3_bucket_object" "object1" {
  bucket = "<Your_Bucket_Name>"
  key    = "slayer.png"
  source = "slayer.png"
  acl = "public-read"
  content_type = "image/png"
  depends_on = [
      aws_s3_bucket.<Your_Bucket_Name>
  ]
}


#Creating Cloud-front and attching S3 bucket to it,
#And creating security settings for it
resource "aws_cloudfront_distribution" "myCloudfront1" {
    origin {
        domain_name = "<Your_Bucket_Name>.s3.amazonaws.com"
        origin_id   = "S3-<Your_Bucket_Name>" 

        custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"] 
        }
    }
       
    enabled = true
    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-<Your_Bucket_Name>"

        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
    depends_on = [
        aws_s3_bucket_object.object1
    ]
}