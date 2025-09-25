# Tech Eazy DevOps Project

This repository demonstrates deploying a sample Java application on **AWS EC2** using **Terraform**.  
It supports both **development** and **production** environments.

---

## Prerequisites

- AWS account with permissions to create EC2 instances and security groups.  
- Terraform installed locally.  
- SSH key pair for EC2 access. 
- Access key and Secret access key for credentials of AWS Cloud
- If you have a key pair for an EC2 instance, then add to it the variables.tf otherwise it processed without a key pair    

---

## Usage

### 1. Provision Infrastructure with Terraform

For **development** environment:  
```bash
terraform init
terraform apply -var-file=dev_config.tfvars -auto-approve
```

For **production** environment:  
```bash
terraform init
terraform apply -var-file=prod_config.tfvars -auto-approve
 

## Notes

- Use `terraform destroy -var-file=<env>.tfvars` to clean up resources. 
- Make sure your cloud provider credentials are valid and have the required permissions 
  
