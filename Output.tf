
output "load_balancer_dns_name_for_clixx" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.test.dns_name
}

output "rds_instance_endpoint_forclixx" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.CLIXX_DB.endpoint
}

output "load_balancer_dns_name_for_myblog" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.test1.dns_name
}

output "rds_instance_endpoint_for_myblog" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.blog_DB.endpoint
}




