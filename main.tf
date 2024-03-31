locals {
  creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}
#creating my efs
resource "aws_efs_file_system" "foo" {
  creation_token = "my-efs"
  tags = {
    Name = "MyProduct"
  }
}


resource "aws_efs_mount_target" "alpha_subnet1" {
  file_system_id =  aws_efs_file_system.foo.id
  subnet_id      = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.stack-sg.id]
}

resource "aws_efs_mount_target" "alpha_subnet2" {
  file_system_id = aws_efs_file_system.foo.id
  subnet_id      = aws_subnet.public-subnet-2.id
  security_groups = [aws_security_group.stack-sg.id]
}


#load balancer
 resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.stack-sg.id]
  subnets = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id
  ]
   

   enable_deletion_protection = false

   tags = {
         Environment = "Development"
  }
 }



resource "aws_launch_configuration" "stack_pre" {
  name_prefix          = "stack-pre-"
  depends_on    = [
    aws_efs_mount_target.alpha_subnet1,
    aws_efs_mount_target.alpha_subnet2, 
    aws_db_instance.CLIXX_DB
  ]
  image_id             = data.aws_ami.stack_ami.id
  instance_type        = var.instance_type
  user_data            = base64encode(data.template_file.bootstrap.rendered)
  security_groups      = [aws_security_group.stack-sg.id]

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdc"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdd"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sde"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
}


resource "aws_autoscaling_group" "app_asg" {
  name                      = "app_asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  vpc_zone_identifier       = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  launch_configuration      = aws_launch_configuration.stack_pre.id
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.app_target_group.arn]

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}


 # Create a target group
 resource "aws_lb_target_group" "app_target_group" {
   name     = "app-target-group"
   port     = 80
   protocol = "HTTP"
   vpc_id   = aws_vpc.stack-vpc.id    # Specify your VPC ID here
            
  

    health_check {
    path                = "/"
     protocol            = "HTTP"
     port                = 80
     healthy_threshold   = 2
     unhealthy_threshold = 2
     timeout             = 3
     interval            = 30
   }
 }

 resource "aws_lb_listener" "example" {
   load_balancer_arn = aws_lb.test.arn
   port              = 80
   protocol          = "HTTP"

   default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.app_target_group.arn
   }
 }


resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
 subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]# Specify the private subnet IDs
}

resource "aws_db_instance" "CLIXX_DB" {
  identifier             = "clixx"
  instance_class         = "db.m6gd.large"
  db_name                = ""
  username               = "wordpressuser"
  password               = "W3lcome123"
  snapshot_identifier    = data.aws_db_snapshot.CLIXXSNAP.id
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
  db_subnet_group_name  = aws_db_subnet_group.db-subnet-group.name

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}

#creating ebs volumes for clixx-app


#My blog deployment

#creating my efs
resource "aws_efs_file_system" "fool" {
  creation_token = "my-blog-efs"
  tags = {
    Name = "My-Blog "
  }
}

#mounting the efs
resource "aws_efs_mount_target" "alpha_blog1" {
  file_system_id =  aws_efs_file_system.fool.id
  subnet_id      = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.stack-sg.id]
}

resource "aws_efs_mount_target" "alpha_blog2" {
  file_system_id = aws_efs_file_system.fool.id
  subnet_id      = aws_subnet.public-subnet-2.id
  security_groups = [aws_security_group.stack-sg.id]
}


# #load balancer
 resource "aws_lb" "test1" {
  name               = "test-blog-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.stack-sg.id]
   subnets = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id
  ]
   

   enable_deletion_protection = false

   tags = {
         Environment = "Development"
  }
 }


resource "aws_launch_configuration" "stack_blog" {
  name_prefix   = "stack_blog"
  depends_on = [aws_efs_mount_target.alpha_blog1,aws_efs_mount_target.alpha_blog2]
  image_id      = data.aws_ami.stack_ami.id
  instance_type = var.instance_type
  user_data = base64encode(data.template_file.blogbootstap.rendered)
  security_groups      = [aws_security_group.stack-sg.id]

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdc"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdd"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sde"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "app_blog" {
  name                      = "app_blog"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  vpc_zone_identifier       = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  launch_configuration      = aws_launch_configuration.stack_blog.id
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.app_target_blog.arn]

  tag {
    key                 = "Name"
    value               = "app-instance-blog"
    propagate_at_launch = true
  }

  timeouts {
    delete = "20m"
  }
}


  
 #Create a target group
 resource "aws_lb_target_group" "app_target_blog" {
   name     = "app-target-blog"
   port     = 80
   protocol = "HTTP"
   vpc_id   = aws_vpc.stack-vpc.id  # Specify your VPC ID here
            
  

    health_check {
    path                = "/"
     protocol            = "HTTP"
     port                = 80
     healthy_threshold   = 2
     unhealthy_threshold = 2
     timeout             = 3
     interval            = 30
   }
 }

 resource "aws_lb_listener" "example-blog" {
   load_balancer_arn = aws_lb.test1.arn
   port              = 80
   protocol          = "HTTP"

   default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.app_target_blog.arn
   }
 }




resource "aws_db_instance" "blog_DB" {
  identifier             = "wordpressinstance-1"
  instance_class         = "db.t3.micro"
  db_name                = ""
  username               = "admin"
  password               = "stackinc"
  snapshot_identifier    = data.aws_db_snapshot.BLOGSNAP.id
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${aws_security_group.stack-sg.id}"]
  db_subnet_group_name  = aws_db_subnet_group.db-subnet-group.name

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}









