# Security Groups Module

This module creates all security groups for the 3-tier Goal Tracker application with proper network isolation.

## Security Architecture

### Traffic Flow
```
Internet → ALB SG (80/443) → Frontend SG (3000) → Backend SG (8080) → RDS SG (5432)
                    ↓
                Bastion SG (22) → Frontend/Backend (SSH)
```

### Security Groups

1. **ALB Security Group**
   - Ingress: HTTP (80) and HTTPS (443) from internet
   - Egress: All traffic
   - Purpose: Public-facing load balancer

2. **Bastion Security Group**
   - Ingress: SSH (22) from specified IPs only
   - Egress: All traffic
   - Purpose: Secure SSH access point

3. **Frontend Security Group**
   - Ingress: Port 3000 from ALB SG, SSH from Bastion SG
   - Egress: All traffic
   - Purpose: Node.js frontend application servers

4. **Backend Security Group**
   - Ingress: Port 8080 from Frontend SG, SSH from Bastion SG
   - Egress: All traffic
   - Purpose: Go backend API servers

5. **RDS Security Group**
   - Ingress: PostgreSQL (5432) from Backend SG only
   - Egress: None (completely isolated)
   - Purpose: Database isolation

## Usage

```hcl
module "security_groups" {
  source = "../../modules/security-groups"

  environment        = "dev"
  project            = "goal-tracker"
  vpc_id             = module.vpc.vpc_id
  allowed_ssh_cidrs  = ["203.0.113.0/32"]  # Your IP

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | string | - | yes |
| project | Project name | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| allowed_ssh_cidrs | CIDR blocks for SSH access | list(string) | ["0.0.0.0/0"] | no |
| tags | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_sg_id | ALB security group ID |
| bastion_sg_id | Bastion security group ID |
| frontend_sg_id | Frontend security group ID |
| backend_sg_id | Backend security group ID |
| rds_sg_id | RDS security group ID |

## Security Best Practices

⚠️ **Important**: Always restrict `allowed_ssh_cidrs` to your specific IP address or corporate VPN range, never use `0.0.0.0/0` in production.

✅ **Implemented**:
- Principle of least privilege
- Security group chaining (not CIDR blocks)
- Complete database isolation
- No SSH keys needed with Session Manager
