# Testing Strategy

## Validation Tests
```bash
# Syntax validation
terraform validate

# Format check
terraform fmt -check

# Security scanning (optional)
tfsec .
```

## Manual Testing Checklist
- [ ] VPC created with correct CIDR
- [ ] 6 subnets across 2 AZs
- [ ] NAT Gateways operational
- [ ] ALB health checks passing
- [ ] Auto Scaling triggers working
- [ ] RDS accessible from EC2 only
- [ ] S3 bucket encrypted
- [ ] IAM roles have least privilege

## Load Testing
- Tested auto-scaling by simulating traffic
- Verified instances scale from 2 to 4 under load
- Confirmed scale-down after load decreases