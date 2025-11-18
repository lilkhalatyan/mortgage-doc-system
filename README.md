# 🏠 Mortgage Document Management System

A production-ready AWS infrastructure for secure mortgage document processing, built with Terraform.

## 📋 Project Overview

This project demonstrates a complete AWS infrastructure migration, similar to enterprise mortgage platforms. It showcases Infrastructure as Code (IaC) best practices, multi-AZ high availability, and security compliance for financial services.

### 🎯 Key Features

- **Multi-AZ High Availability**: Resources deployed across 2 availability zones
- **Auto Scaling**: Automatically adjusts capacity based on demand (2-4 instances)
- **Secure Storage**: Encrypted RDS database and versioned S3 bucket
- **Load Balancing**: Application Load Balancer with health checks
- **IAM Best Practices**: Least privilege access with instance roles
- **Network Security**: VPC with public/private subnets, security groups

                        ## 🛠️ Tech Stack

- **Infrastructure**: AWS (VPC, EC2, RDS, S3, ALB, Auto Scaling)
- **IaC Tool**: Terraform
- **Application**: PHP, MySQL
- **Monitoring**: CloudWatch
- **Security**: IAM, KMS, Security Groups

## 📊 Resources Created

- **Networking**: VPC, 6 Subnets, 2 NAT Gateways, Internet Gateway
- **Compute**: Auto Scaling Group, Launch Template, 2-4 EC2 instances
- **Database**: RDS MySQL (encrypted, automated backups)
- **Storage**: S3 Bucket (versioned, encrypted)
- **Load Balancing**: Application Load Balancer, Target Group
- **Security**: 3 Security Groups, IAM Role, Instance Profile

## 🏗️ Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Internet                                        │
└──────────────────────────────────┬──────────────────────────────────────────┘
                                   │
                        ┌──────────▼──────────┐
                        │  Internet Gateway   │
                        └──────────┬──────────┘
                                   │
┌──────────────────────────────────▼──────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                                    │
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                      Application Load Balancer                          │ │
│  │                     (Public Subnet - Multi-AZ)                          │ │
│  └─────────────────┬────────────────────────┬─────────────────────────────┘ │
│                    │                        │                                │
│  ┌─────────────────▼────────────┐  ┌───────▼──────────────────┐            │
│  │   Availability Zone 1        │  │   Availability Zone 2    │            │
│  │                              │  │                          │            │
│  │  ┌────────────────────────┐  │  │  ┌────────────────────┐ │            │
│  │  │   Public Subnet        │  │  │  │   Public Subnet    │ │            │
│  │  │   10.0.1.0/24          │  │  │  │   10.0.2.0/24      │ │            │
│  │  │  ┌──────────────────┐  │  │  │  │ ┌──────────────┐  │ │            │
│  │  │  │  NAT Gateway 1   │  │  │  │  │ │ NAT Gateway 2│  │ │            │
│  │  │  └────────┬─────────┘  │  │  │  │ └──────┬───────┘  │ │            │
│  │  └───────────┼────────────┘  │  │  └────────┼──────────┘ │            │
│  │              │                │  │           │            │            │
│  │  ┌───────────▼────────────┐  │  │  ┌────────▼─────────┐ │            │
│  │  │   Private Subnet       │  │  │  │  Private Subnet  │ │            │
│  │  │   10.0.10.0/24         │  │  │  │  10.0.11.0/24    │ │            │
│  │  │  ┌──────────────────┐  │  │  │  │ ┌──────────────┐ │ │            │
│  │  │  │   EC2 Instance   │  │  │  │  │ │ EC2 Instance │ │ │            │
│  │  │  │  (Auto Scaling)  │  │  │  │  │ │(Auto Scaling)│ │ │            │
│  │  │  └────────┬─────────┘  │  │  │  │ └──────┬───────┘ │ │            │
│  │  └───────────┼────────────┘  │  │  └────────┼──────────┘ │            │
│  │              │                │  │           │            │            │
│  │  ┌───────────▼────────────┐  │  │  ┌────────▼─────────┐ │            │
│  │  │   Database Subnet      │  │  │  │  Database Subnet │ │            │
│  │  │   10.0.20.0/24         │  │  │  │  10.0.21.0/24    │ │            │
│  │  │         ┌──────────────┴──┴──┴──┴──┴──────────┐     │ │            │
│  │  │         │       RDS MySQL (Multi-AZ)          │     │ │            │
│  │  │         │         (Encrypted)                 │     │ │            │
│  │  │         └─────────────────────────────────────┘     │ │            │
│  │  └─────────────────────────────────────────────────────┘ │            │
│  └───────────────────────────────────────────────────────────┘            │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                         S3 Bucket (Encrypted)                         │  │
│  │                    mortgage-docs-documents                            │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  Security Components:                                                 │  │
│  │  • 3 Security Groups (ALB, EC2, RDS)                                 │  │
│  │  • IAM Roles & Instance Profiles                                     │  │
│  │  • VPC Flow Logs → CloudWatch                                        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘

Key Components:
├── Networking: VPC, 6 Subnets, 2 NAT Gateways, Internet Gateway
├── Compute: Auto Scaling Group (2-4 EC2 instances), Launch Template
├── Database: RDS MySQL Multi-AZ (encrypted, automated backups)
├── Storage: S3 Bucket (versioned, encrypted)
├── Load Balancing: Application Load Balancer, Target Group
└── Security: 3 Security Groups, IAM Role, Instance Profile, VPC Flow Logs
```

## 🚀 Quick Start

### Prerequisites

- AWS Account ([Create Free Tier Account](https://aws.amazon.com/free/))
- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- [AWS CLI](https://aws.amazon.com/cli/) configured

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/lilkhalatyan/mortgage-doc-system.git
   cd mortgage-doc-system/terraform
```

2. **Configure AWS credentials**
```bash
   aws configure
```

3. **Create SSH key pair**
```bash
   aws ec2 create-key-pair --key-name mortgage-key --query 'KeyMaterial' --output text > ~/.ssh/mortgage-key.pem
   chmod 400 ~/.ssh/mortgage-key.pem
```

4. **Set up variables**
```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
```

5. **Deploy infrastructure**
```bash
   terraform init
   terraform plan
   terraform apply
```

6. **Access application**
```bash
   terraform output alb_dns_name
   # Open the URL in your browser
```

## 🔒 Security Features

- ✅ VPC with public/private subnet isolation
- ✅ Security groups with least privilege access
- ✅ RDS encryption at rest (KMS)
- ✅ S3 bucket encryption (AES-256)
- ✅ IAM roles (no hardcoded credentials)
- ✅ HTTPS-only S3 bucket policy
- ✅ Database in private subnet
- ✅ VPC Flow Logs enabled

## 💰 Cost Estimate

**Daily**: ~$3-5 (with t2.micro instances)  
**Monthly**: ~$80-120 (if kept running)

**Free Tier Eligible** (first 12 months):
- EC2: 750 hours/month
- RDS: 750 hours/month
- S3: 5GB storage
- ALB: Not free tier eligible

## 🧹 Cleanup

To avoid ongoing charges:
```bash
cd terraform
terraform destroy
```

## 📚 What I Learned

- Infrastructure as Code with Terraform
- AWS VPC networking and subnet design
- Multi-AZ high availability architecture
- Auto Scaling and Load Balancing
- IAM security best practices
- RDS database management
- S3 storage policies and lifecycle rules
- CloudWatch monitoring and logging

## 🎯 Use Cases

This architecture is suitable for:
- Financial services applications (mortgage, banking)
- Healthcare applications (HIPAA compliance ready)
- E-commerce platforms
- SaaS applications
- Any production workload requiring high availability

## 📈 Potential Improvements

- [ ] Add HTTPS with ACM certificate
- [ ] Implement CloudFront CDN
- [ ] Add ElastiCache for session management
- [ ] Implement AWS WAF for application firewall
- [ ] Add Lambda for serverless document processing
- [ ] Implement CI/CD pipeline (GitHub Actions)
- [ ] Add DynamoDB for metadata storage
- [ ] Implement AWS Backup for automated backups


## 👤 Author

Lilit Khalatyan

## 🙏 Acknowledgments

- Built as part of AWS infrastructure learning
- Inspired by real-world mortgage platform migrations

---

⭐ If you found this helpful, please star the repo!
