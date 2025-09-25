variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
  
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  description = "Ubuntu"
  default     = "ami-02d26659fd82cf299" 
}

variable "instance_type" {
  default = "t3.micro"
}


variable "vpc_id" {
  description = "my_vpc"
  default = "vpc-02306e6e355f9c6a0"
}

variable "my_app_port" {
  default = 80
}

variable "stage" {
  default = "Dev"
}

variable "repo_url" {
  default = "https://github.com/Trainings-TechEazy/test-repo-for-devops"
}

variable "key_name" {
  description = "Key pair to use for EC2 instance"
  type        = string
  default     = null
}
# update
variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}



