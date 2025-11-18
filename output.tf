# outputs.tf

output "alb_dns_name" {
  description = "Load balancer URL - Open this in your browser"
  value       = "http://${aws_lb.main.dns_name}"
}

output "s3_bucket_name" {
  description = "S3 bucket for documents"
  value       = aws_s3_bucket.documents.id
}

output "rds_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "project_summary" {
  description = "Quick reference"
  value       = <<-EOT
  
  ========================================
  🎉 DEPLOYMENT COMPLETE!
  ========================================
  
  🌐 Application URL: http://${aws_lb.main.dns_name}
  
  📊 Resources Created:
  ✓ VPC with 6 subnets across 2 AZs
  ✓ Application Load Balancer
  ✓ Auto Scaling Group (2-4 instances)
  ✓ RDS MySQL Database
  ✓ S3 Bucket (versioned & encrypted)
  ✓ IAM Roles & Security Groups
  
  🔍 View Resources:
  - EC2 Instances: aws ec2 describe-instances --filters "Name=tag:Name,Values=*mortgage-docs*"
  - S3 Objects: aws s3 ls s3://${aws_s3_bucket.documents.id} --recursive
  - Auto Scaling: aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${aws_autoscaling_group.web.name}
  
  💰 Estimated Cost: $5-10 for 24 hours
  
  🧹 Cleanup: terraform destroy
  
  ========================================
  EOT
}