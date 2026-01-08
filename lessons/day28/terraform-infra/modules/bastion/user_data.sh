#!/bin/bash
set -e

# Update system
yum update -y

# Install useful tools
yum install -y \
    vim \
    git \
    htop \
    wget \
    curl \
    jq \
    bind-utils

# Install Docker (for troubleshooting)
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Session Manager plugin
yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

# Configure AWS CLI region
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
mkdir -p /home/ec2-user/.aws
cat > /home/ec2-user/.aws/config << EOF
[default]
region = $REGION
output = json
EOF
chown -R ec2-user:ec2-user /home/ec2-user/.aws

# Set up message of the day
cat > /etc/motd << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║           Goal Tracker Application - Bastion Host             ║
║                                                                ║
║  Environment: ${environment}                                  
║  Project: ${project}                                          
║                                                                ║
║  Use this host to access private instances via SSH            ║
║  Or use AWS Systems Manager Session Manager (no keys needed)  ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF

# Create helpful aliases
cat >> /home/ec2-user/.bashrc << 'EOF'

# Helpful aliases
alias ll='ls -lah'
alias docker-ps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'
alias docker-logs='docker logs -f'

# AWS helpers
alias ec2-list='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]" --output table'
alias rds-list='aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]" --output table'

echo "💡 Tip: Use 'ec2-list' to see all EC2 instances or 'rds-list' for RDS instances"
EOF

chown ec2-user:ec2-user /home/ec2-user/.bashrc

echo "Bastion host setup complete - $(date)" > /var/log/user-data.log
