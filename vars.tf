variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {}


variable "environment" {
  default = "dev"
}

# variable "default_vpc_id" {
#   default = "vpc-0b16376d2cbed43aa" 
# }

variable "system" {
  default = "Retail Reporting"
}

variable "subsystem" {
  default = "CliXX"
}


variable "subnets_cidrs" {
  type = list(string)
  default = [
    "172.31.32.0/20"
  ]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "my_key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "my_key.pub"
}

variable "OwnerEmail" {
  default = "Dolapo832@gmail.com"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-stack-1.0"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

#   variable "subnets" {
#   type    = map(string)
#   default = {
#    id1="subnet-04deb661ac66ba4e6",
#    id2="subnet-0654326ffc23e2e55",
#    id3="subnet-0b1720eacf1056482",
#    id4="subnet-0918a43a58a8a01be",
#    id5= "subnet-0603ede3c2a289ac8"
#   }
# }

variable "subnet_id" {
  default ="subnet-04deb661ac66ba4e6"
}



variable "DB_USER" {}

variable "DB_PASS" {}

variable "DB_NAME" {}

variable "DB_USER1" {}

variable "DB_PASSWORD" {}

variable "DB_NAME1" {}

variable "MOUNT_POINT" {
  default="/var/www/html"
}

variable "GIT_REPO" {
  default="https://github.com/stackitgit/CliXX_Retail_Repository.git"
}

variable "MOUNT_POINT1" {
  default="/var/www/html"
}

variable "GIT_REPO1" {
  default="https://github.com/Dolapo832/STACK_BLOG.git"
}

variable "availability_zone" {
  default = [
     "us-east-1a",
     "us-east-1b"      
  ]
}
















