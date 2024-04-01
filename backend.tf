terraform{
         backend "s3"{
                bucket= "stack-terraformstate-newdolaposep11"
                key = "terraform.tfsate"
                region="us-east-1"
                dynamodb_table="statelock-tf"
                 }
        }