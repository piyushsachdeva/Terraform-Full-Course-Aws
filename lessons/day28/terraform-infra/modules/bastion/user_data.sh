#!/bin/bash
set -e

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install useful tools
apt-get install -y \
    vim \
    git \
    htop \
    wget \
    curl \
    jq \
    dnsutils

# Install Docker (for troubleshooting)
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Session Manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
dpkg -i session-manager-plugin.deb
rm -f session-manager-plugin.deb

# Configure AWS CLI region
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
mkdir -p /home/ubuntu/.aws
cat > /home/ubuntu/.aws/config << EOF
[default]
region = $REGION
output = json
EOF
chown -R ubuntu:ubuntu /home/ubuntu/.aws

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
cat >> /home/ubuntu/.bashrc << 'EOF'

# Helpful aliases
alias ll='ls -lah'
alias docker-ps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'
alias docker-logs='docker logs -f'

# AWS helpers
alias ec2-list='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]" --output table'
alias rds-list='aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]" --output table'

echo "💡 Tip: Use 'ec2-list' to see all EC2 instances or 'rds-list' for RDS instances"
EOF

chown ubuntu:ubuntu /home/ubuntu/.bashrc

echo "Bastion host setup complete - $(date)" > /var/log/user-data.log
