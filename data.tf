data "aws_ami" "stack_ami" {
  owners     = ["self"]
  name_regex = "^ami-stack-.*"
  most_recent = true
  filter {
    name   = "name"
    values = ["ami-stack-*"]
  }
}

data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = "creds"
 }

