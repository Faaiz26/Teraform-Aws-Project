# Terraform AWS Infrastructure Project

## Project Overview

This Terraform project provisions a custom AWS infrastructure in the Mumbai region. It creates a Virtual Private Cloud (VPC) with multiple subnets, security groups, an internet gateway, route tables, EC2 instances, an Application Load Balancer (ALB) setup, and an S3 bucket with specific controls.

---

## Infrastructure Components

### 1. VPC and Networking

- **VPC**: Custom VPC created with the CIDR block specified by the variable `cidr`.
- **Subnets**: Two public subnets in availability zones `ap-south-1a` and `ap-south-1b` with public IPs auto-assigned.
- **Internet Gateway**: To enable internet connectivity for the VPC.
- **Route Table**: Associated with both subnets to route outbound traffic through the internet gateway.

### 2. Security Groups

- **Security Group `mumbai_sg`**: Allows inbound HTTP (port 80) and SSH (port 22) traffic from anywhere (`0.0.0.0/0`).
- Outbound traffic is unrestricted.

### 3. EC2 Instances

- Two `t3.micro` instances launched in separate subnets (`sub1` and `sub2`).
- Both use the security group `mumbai_sg`.
- Custom user data scripts are encoded and passed for initialization (`userdata.sh` and `userdata1.sh`).

### 4. Load Balancer Configuration

- **Application Load Balancer (ALB)**: Public ALB spanning the two subnets.
- **Target Group**: Configured to route HTTP traffic to the EC2 instances.
- **Listeners & Attachments**: ALB listener on port 80 forwards requests to the target group.

### 5. S3 Bucket

- Bucket named `mumbai-bucket-20251`.
- Ownership controls set to `BucketOwnerPreferred`.
- Public access controls are explicitly set but allow public read access (`public-read` ACL).

---

## Variables

- `cidr`: CIDR block for the custom VPC.
- `cidr_subnet` and `cidr_subnet_2`: CIDR blocks for the two subnets.
- `ami_image`: AMI ID for the EC2 instances.

You can customize these variables in your `variables.tf` (not shown here).

---

## Usage Instructions

1. Ensure you have AWS credentials configured with sufficient permissions.
2. Modify variables as per your environment.
3. Run the following commands in order:

    ```
    terraform init
    terraform plan
    terraform apply
    ```
4. After apply, outputs will provide the Application Load Balancer DNS name.

---

## Output

- `loadbalancedns`: The DNS name of the created Application Load Balancer.

---

## Notes

- The EC2 instances security group allows public HTTP and SSH access, which is suitable for testing but should be restricted in production.
- The S3 bucket has public read access; if sensitive data is stored, consider stricter policies.
- Customize the user data scripts (`userdata.sh` and `userdata1.sh`) as needed for instance initialization.

---

This project provides a foundational AWS infrastructure setup which you can extend according to your application needs.
