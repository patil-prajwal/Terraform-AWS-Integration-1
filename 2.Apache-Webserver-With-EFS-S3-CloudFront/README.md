# **Create/launch Application using Terraform**

***<h3>Description</h3>***
<hr>

- *1. Create Security Group which allow the port 80.*
- *2. Launch EC2 instance.*
- *3. In this EC2 instance use the existing key or provided key and security group which we have created in above step.*
- *4. Launch one Volume using the **EFS service** and attach it in your VPC, then mount that volume into Root Directory of Apache Webserver*
- *5. Developer have uploded the code into Github Repo also the Repo has some images.*
- *6. Copy the Github Repo code into Root Directory of Apache Webserver*
- *7. **Create S3 bucket**, and copy/deploy the images from Github Repo into the S3 Bucket and Change the permission to public readable.*
- *8 **Create a Cloudfront** using S3 Bucket(which contains images) and use the Cloudfront URL to  update in code in Root Directory of Apache Webserver*

<hr>

- **For More Details Refer Article:** [**Article Link**](https://www.linkedin.com/pulse/using-terraform-deploying-webserver-aws-prajwal-patil/)
