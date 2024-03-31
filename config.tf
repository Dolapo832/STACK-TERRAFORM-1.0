data "template_file" "bootstrap" {
  template = file(format("%s/scripts/bootstrap.tpl", path.module))
  vars={
    GIT_REPO=var.GIT_REPO
    MOUNT_POINT=var.MOUNT_POINT
    efs= aws_efs_file_system.foo.dns_name
    DB_USER = local.creds.DB_USER
    DB_PASS = local.creds.DB_PASS
    DB_NAME =local.creds.DB_NAME
    DB_HOST=aws_db_instance.CLIXX_DB.endpoint
    CLIXX_LB= aws_lb.test.dns_name
   
  }
}

data "aws_db_snapshot" "CLIXXSNAP" {
  db_snapshot_identifier = "arn:aws:rds:us-east-1:381492048000:snapshot:wordpressdbclixx-snapshot"
  most_recent            = true
}

data "template_file" "blogbootstap" {
  template = file(format("%s/scripts/blogbootstap.tpl", path.module))
  vars={
    GIT_REPO1=var.GIT_REPO1
    MOUNT_POINT1=var.MOUNT_POINT1
    efs1= aws_efs_file_system.fool.dns_name
    DB_NAME1= local.creds.DB_NAME1
    DB_USER1=local.creds.DB_USER1
    DB_PASSWORD=local.creds.DB_PASSWORD
    RDS_INSTANCE=aws_db_instance.blog_DB.endpoint
    Blog_LB=aws_lb.test1.dns_name
    
  }
}

data "aws_db_snapshot" "BLOGSNAP" {
  db_snapshot_identifier = "arn:aws:rds:us-east-1:381492048000:snapshot:wordpressinstance-1-snapshot"
  most_recent            = true
}



