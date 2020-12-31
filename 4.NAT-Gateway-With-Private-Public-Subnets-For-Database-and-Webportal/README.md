# **Bation Host with Database in Private Subnet and Public Subnet**

**Description :**

<hr>

***1.**  Create a VPC.*

***2.**  In that VPC, create 2 Subnets:*

- *1. Public  Subnet [ Accessible for Public World ]*
- *2. Private Subnet [ Restricted for Public World ]*
    
***3.** Create a Public facing Internet Gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.*

***4.** Create  a Routing Table for Internet Gateway so that instance can connect to outside world, update and associate it with Public Subnet.*

***5.**  Create a NAT Gateway for connect our VPC/Network to the internet world  and attach this gateway to our VPC in the Public Network.*

***6.**  Update the Routing Table of the Private Subnet, so that to access the internet it uses the NAT Gateway created in the Public Subnet.*

***7.**  Launch an EC2 instance which has Wordpress setup already having the Security Group allowing  port 80 so that client can connect. Also attach the key to instance for further login into it.*

***8.**  Launch an EC2 instance which has MySQL setup already with Security Group allowing  port 3306 in Private Subnet so that our Wordpress Instance can connect with the same. Also attach the key with the same.*

**Note:**

  - *Wordpress instance is part of Public Subnet so that our client can connect our site.*

  - *MySQL instance is part of Private  Subnet so that outside world can't connect to it.*

<hr>


- **For More Details Refer Article :** [**Article Link**](https://www.linkedin.com/pulse/creating-infrastructure-aws-using-terraform-uses-nat-gateway-patil/)

