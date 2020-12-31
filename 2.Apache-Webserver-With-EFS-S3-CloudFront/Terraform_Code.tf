provider "aws" {
    region  =  "ap-south-1"
}
resource "tls_private_key" "mytask2key"  {
   algorithm  =  "RSA"
 }

resource "aws_key_pair" "keypair"  {
    key_name  =  "mytask2key"
    public_key  = tls_private_key.mytask2key.public_key_openssh
 
    depends_on  =  [
               tls_private_key.mytask2key
    ]
   
}

resource "aws_security_group" "mytask2_sec_group1" {
        name           =  "mytask2_sec_group1"
        description  =  "Allow SSH and HTTP"
        vpc_id = "vpc-0ae1fc62"

        ingress {
           description   =  "SSH"
           from_port     =  22
           to_port         =  22
           protocol       =  "tcp"
           cidr_blocks  =  [ "0.0.0.0/0"]
         }
        
         ingress {
            description   =  "HTTP"
            from_port     =  80
            to_port         =  80
            protocol        =  "tcp"
            cidr_blocks   =  [ "0.0.0.0/0" ]
         }
         egress {
             from_port  =  0
             to_port      =  0
             protocol    =  "-1"
             cidr_blocks  =  [ "0.0.0.0/0" ]
        }
       tags  =  {
           Name  =  "mytask2_sec_group1"
        }
}

resource "aws_instance"  "myinstan"  {
    ami   =  "ami-0447a12f28fddb066"
    instance_type  =  "t2.micro"
    key_name  =  aws_key_pair.keypair.key_name
    security_groups  =  [ "mytask2_sec_group1" ]
   
    
   
    connection  {
              agent   =  "false"
              type     =  "ssh"
              user     =  "ec2-user"
              private_key  =  tls_private_key.mytask2key.private_key_pem
              host     =  aws_instance.myinstan.public_ip
          }
    provisioner  "remote-exec" {
             inline  =  [
                   "sudo  yum install httpd  php  git  -y",
                   "sudo  systemctl  restart  httpd",
                   "sudo systemctl  enable httpd",
               ]
         }
 
   tags  =  {
        Name = "myinstan"
     }
}

resource "aws_efs_file_system" "myefs" {
   creation_token = "myefs"
   performance_mode = "generalPurpose"
 tags = {
     Name = "myefs"
   }
 
}

resource "aws_efs_mount_target" "myefsmount" {
   file_system_id  = aws_efs_file_system.myefs.id
   subnet_id = aws_instance.myinstan.subnet_id
   security_groups = ["${aws_security_group.mytask2_sec_group1.id}"]
 }

resource  "null_resource"  "mounting" {
      depends_on = [
            aws_efs_mount_target.myefsmount,
      ]
      connection {
             type  =  "ssh"
             user  =  "ec2-user"
             private_key  =  tls_private_key.mytask2key.private_key_pem
             host  =  aws_instance.myinstan.public_ip
       }
      provisioner  "remote-exec" {
             inline  =  [
                 "sudo echo ${aws_efs_file_system.myefs.dns_name}:/var/www/html  efs  defaults, _netdev 0 0 >> sudo  /etc/fstab",
                 "sudo mount ${aws_efs_file_system.myefs.dns_name}:/ /var/www/html",
                 "sudo git clone https://github.com/kingslayer227/test-ws1.git    /var/www/html"

             ]
         }
    
}

resource "aws_s3_bucket"  "mytask2bucket"  {
            bucket  =  "mybucket278270"
            acl  =  "private"
            region = "ap-south-1"
        versioning {
                       enabled  =  true
        }
       tags  =  {
           Name  =  "mytask2bucket278270"
        }
}

resource "aws_s3_bucket_object"  "mytask2bucket_object"  {
         depends_on = [aws_s3_bucket.mytask2bucket , ]
          bucket  =  aws_s3_bucket.mytask2bucket.id
          key   =  "slayer.png"
          source  =  "slayer.png"
          acl  =  "public-read"
   
}

resource "aws_cloudfront_distribution" "mytask2cloudfront" {
        origin {
                domain_name = "mybucket.s3.amazonaws.com"
                origin_id   = "S3-mybucket278270-id"
                custom_origin_config  {
                      http_port  =  80
                      https_port  =  80
                      origin_protocol_policy  =  "match-viewer"
                      origin_ssl_protocols  =  [ "TLSv1" , "TLSv1.1" ,"TLSv1.2" ]
           }
}
enabled  =  true
default_cache_behavior {
            allowed_methods  =  ["DELETE" , "GET" , "HEAD" , "OPTIONS" ,"PATCH" , "POST" , "PUT" ]
            cached_methods = ["GET" , "HEAD"]
            target_origin_id  =  "S3-mybucket278270-id"
        
            forwarded_values  {
                query_string  =  false
                 cookies {
                               forward = "none"
                 }
 }
viewer_protocol_policy  =  "allow-all"
min_ttl  =  0
default_ttl  =  3600
max_ttl  =  86400
}
restrictions  {
             geo_restriction {
                              restriction_type = "none"
          }
}
viewer_certificate  {
           cloudfront_default_certificate = true
           }

   provisioner  "local-exec"  {
           command  =  "chrome ${aws_instance.myinstan.public_ip}"
   }
}

