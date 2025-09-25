provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
  }
resource "aws_instance" "ubuntu" {
  ami           = var.ami_id   
  instance_type = var.instance_type
  key_name = "ec2_key_1"
  depends_on    = [aws_key_pair.my_key] 
  security_groups = [aws_security_group.my_app_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_write_profile.name
  user_data = file("user_data.sh")

 
  tags = {
    ENV = "${var.stage}"
  }
  
}


resource "aws_security_group" "my_app_sg" {
  name        = "sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.my_app_port
    to_port     = var.my_app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "private_key/ec2_key_1.pem"
  
}


resource "aws_key_pair" "my_key" {
  key_name = "ec2_key_1"
  public_key = tls_private_key.example.public_key_openssh  # Path to your existing public key file
}




#update
#IAM read only
resource "aws_iam_role" "s3_read_role" {
  name = "S3ReadOnlyRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_read_policy" {
  name       = "attach_read_policy"
  roles      = [aws_iam_role.s3_read_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# IAM witre only
resource "aws_iam_role" "s3_write_role" {
  name = "S3WriteOnlyRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_write_policy" {
  name        = "S3WriteOnlyPolicy"
  description = "Allow creating buckets & uploading objects, deny read/list"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:CreateBucket", "s3:PutObject"]
        Resource = ["arn:aws:s3:::*", "arn:aws:s3:::*/*"]
      },
      {
        Effect = "Deny"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::*", "arn:aws:s3:::*/*"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_write_policy" {
  name       = "attach_write_policy"
  roles      = [aws_iam_role.s3_write_role.name]
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

#Attach Role 1.b to EC2 via Instance Profile
resource "aws_iam_instance_profile" "ec2_s3_write_profile" {
  name = "EC2S3WriteProfile"
  role = aws_iam_role.s3_write_role.name
}




#Create Private S3 Bucket

resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

# Optional: Terminate if bucket_name is empty
locals {
  validate_bucket = length(var.bucket_name) > 0 ? true : false
}

resource "null_resource" "check_bucket_name" {
  count = local.validate_bucket ? 0 : 1
  provisioner "local-exec" {
    command = "echo 'Bucket name not provided! Terminating...' && exit 1"
  }
}

#Add S3 Lifecycle Rule to Delete Logs after 7 Days

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {
      prefix = ""  # all objects
    }

    expiration {
      days = 7
    }
  }
}
