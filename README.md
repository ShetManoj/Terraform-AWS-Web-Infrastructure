# Terraform AWS Infrastructure Project

This repository contains Terraform code designed to provision an Apache web server on AWS EC2 instances and configure an Application Load Balancer (ALB) for efficient traffic distribution.

## Prerequisites

- **Terraform**: Ensure you have Terraform installed on your machine. You can download it from the [official Terraform website](https://www.terraform.io/downloads.html).
- **AWS Account**: An active AWS account is required. Make sure to configure your AWS credentials using the AWS CLI or by setting environment variables.

## Getting Started

1. **Clone the Repository**  
   Clone this repository to your local machine using Git. Navigate to the directory where you want to save the project and run the following command:

2. **Initialize Terraform**  
   Navigate into the cloned repository directory and initialize the Terraform configuration. This step downloads the necessary provider plugins and prepares your environment for deployment:

3. **Deploy the Infrastructure**  
   Execute the following command to deploy the infrastructure defined in the Terraform configuration files. Review the plan, and if everything looks good, confirm the deployment:

4. **Access the Web Server**  
   Once the deployment is complete, you can access the Apache web server via the Application Load Balancer's DNS name. This can be found in the AWS Management Console under the EC2 or Load Balancers section.

