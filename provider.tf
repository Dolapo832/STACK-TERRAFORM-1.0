provider "aws" {
  region = local.creds.AWS_REGION
access_key = var.AWS_ACCESS_KEY
secret_key = var.AWS_SECRET_KEY


assume_role {
    # The role ARN within the Development account to AssumeRole into. 
    role_arn    = "arn:aws:iam::381492048000:role/Engineer"
  }
}

