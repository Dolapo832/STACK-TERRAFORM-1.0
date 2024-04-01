provider "aws" {
  region = local.creds.AWS_REGION



assume_role {
    # The role ARN within the Development account to AssumeRole into. 
    role_arn    = "arn:aws:iam::381492048000:role/Engineer"
  }
}

