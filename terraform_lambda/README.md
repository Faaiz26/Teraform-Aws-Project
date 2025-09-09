# AWS Lambda with Terraform

This project provisions an **AWS Lambda function** inside a custom **VPC** using Terraform.  
It includes all required networking, IAM roles, and permissions for Lambda to run and write logs to CloudWatch.

---

## 🚀 Features

- **VPC & Subnet**
  - Creates a VPC (`10.0.0.0/16`)
  - Creates a subnet (`10.0.1.0/24`) in availability zone `ap-south-1a`

- **Security Group**
  - Allows all inbound traffic (not recommended for production)
  - Allows all outbound traffic

- **IAM Role & Policy**
  - Execution role for Lambda with trust policy
  - Custom IAM policy to allow CloudWatch log operations
  - Attaches the policy to the Lambda role

- **AWS Lambda Function**
  - Runtime: `python3.12`
  - Handler: `lambda_function.lambda_handler`
  - Deployment package: `lambda_function.zip`
  - Uses `source_code_hash` to track code changes

---

## 📂 Project Structure

terraform_lambda/
├── main.tf # Terraform resources (VPC, SG, IAM, Lambda)
├── provider.tf # AWS provider configuration
├── lambda_function.py # Lambda function code
├── lambda_function.zip # Zipped Lambda function package
└── .terraform.lock.hcl # Provider dependency lock file



---

## ⚙️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.3
- AWS CLI configured with valid credentials (`aws configure`)
- An S3 bucket for remote state (optional but recommended)

---

## 🛠️ Usage

1. **Clone this repository**
   ```bash
   git clone https://github.com/Faaiz26/Teraform-Aws-Project.git
   cd Teraform-Aws-Project/terraform_lambda


terraform init
terraform validate
terraform validate
terraform apply -auto-approve
terraform destroy -auto-approve
