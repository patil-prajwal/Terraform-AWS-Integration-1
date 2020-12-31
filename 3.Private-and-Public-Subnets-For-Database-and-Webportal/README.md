# **Creating a Web-Portal with giving as much as security to its Database.**

**Description:**
<hr>

- *1) **Create a VPC.***

- *2) In that VPC we have to **create 2 Subnets:***

    ***a)  Public  Subnet [ Accessible for Public World ]***
    
    ***b)  Private Subnet [ Restricted for Public World ]***

- *3) **Create a Public facing Internet Gateway** for connect our VPC/Network to the internet world and attach this gateway to our VPC.*

- *4) **Create a Routing Table for Internet Gateway** so that instance can connect to outside world, update and associate it with Public Subnet.*

- *5) **Launch an EC2 instance which has WordPress** setup already having the security group **allowing  port 80** so that our client can connect to our wordpress site. Also attach the key to instance for further login into it.*

- *6) **Launch an EC2 instance which has MYSQL** setup already with security group **allowing  port 3306** in private subnet so that our wordpress vm can connect with the same. Also attach the key with the same.*

<hr>

- **For More Details Refer Article :** [**Article Link**](https://www.linkedin.com/pulse/creating-vpc-infrastructure-aws-using-terraform-prajwal-patil/)