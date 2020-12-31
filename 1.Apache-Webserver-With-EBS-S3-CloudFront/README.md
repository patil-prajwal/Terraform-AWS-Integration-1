# **Details of This Terraform Code.**

**1.** Create the key and security group which allow the port 80.

**2.** Launch *EC2 instance.*

**3.** In this EC2 instance use the key and security group which we have created in step 1.

**4.** *Launch one Volume (EBS)* and *mount it into /var/www/html*

**5.** Developer have uploded the code into Github Repo also the Repo has some images.

**6.** *Copy the Github Repo Code into /var/www/html*

**7.** *Create S3 bucket,* and copy/deploy the images from Github Repo into the S3 Bucket and *Change the permission to public readable.*

**8.** *Create a Cloudfront using S3 Bucket* (which contains images) and use the Cloudfront URL to  update in code in /var/www/html

- **For More Details Refer Article:** [**Article Link**](https://www.linkedin.com/pulse/task-1-creating-launching-infrastructure-web-server-amazon-patil/)
