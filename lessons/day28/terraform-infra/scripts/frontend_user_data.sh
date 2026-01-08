#!/bin/bash
set -e

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/user-data.log
}

log "Starting frontend setup..."

# Update system
log "Updating system packages..."
yum update -y

# Install Docker and necessary utilities
log "Installing Docker and utilities..."
yum install -y docker nc bind-utils jq
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install AWS CLI v2
log "Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Docker Hub login (if credentials provided)
if [ -n "${dockerhub_username}" ] && [ -n "${dockerhub_password}" ]; then
    log "Logging into Docker Hub..."
    if ! echo "${dockerhub_password}" | docker login -u "${dockerhub_username}" --password-stdin; then
        log "❌ ERROR: Failed to login to Docker Hub"
        exit 1
    fi
    log "✅ Successfully logged into Docker Hub"
else
    log "No Docker Hub credentials provided, assuming public image"
fi

# Backend URL
BACKEND_URL="${backend_internal_url}"
log "Backend URL: $BACKEND_URL"

# Verify backend connectivity before starting frontend
log "Verifying backend connectivity..."
BACKEND_HOST=$(echo $BACKEND_URL | sed -e 's|http://||' -e 's|:.*||')
BACKEND_PORT=$(echo $BACKEND_URL | sed -e 's|.*:||' -e 's|/.*||')
log "Checking connectivity to backend at $BACKEND_HOST:$BACKEND_PORT"

max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    log "Backend connectivity attempt $attempt of $max_attempts..."
    if nc -z -w 3 $BACKEND_HOST $BACKEND_PORT 2>/dev/null; then
        log "✅ Successfully connected to backend at $BACKEND_HOST:$BACKEND_PORT"
        break
    else
        if [ $attempt -eq $max_attempts ]; then
            log "⚠️  WARNING: Could not verify backend connectivity after $max_attempts attempts. Proceeding anyway..."
        else
            log "Backend not yet reachable. Waiting 10 seconds before retry..."
            sleep 10
        fi
        attempt=$((attempt+1))
    fi
done

# Pull and run frontend container
log "Pulling frontend image from Docker Hub..."
docker pull ${docker_image}

log "Starting frontend container..."
docker run -d \
  --name goal-tracker-frontend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e PORT=3000 \
  -e BACKEND_URL="$BACKEND_URL" \
  -e NODE_ENV=production \
  ${docker_image}

# Wait for container to be healthy
log "Waiting for frontend to be healthy..."
sleep 10

# Check container status
if docker ps | grep -q goal-tracker-frontend; then
    log "✅ Frontend container is running"
else
    log "❌ ERROR: Frontend container failed to start"
    docker logs goal-tracker-frontend
    exit 1
fi

# Install CloudWatch Agent
log "Installing CloudWatch Agent..."
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch Logs
log "Configuring CloudWatch Logs..."
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/aws/ec2/${environment}-${project}/frontend",
            "log_stream_name": "{instance_id}/user-data"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "${environment}/${project}/Frontend",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_IDLE",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Setup Docker log rotation
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

systemctl restart docker

# Create a healthcheck script
cat > /usr/local/bin/healthcheck.sh << 'EOF'
#!/bin/bash
response=$(curl -s -o /dev/null -w "%%{http_code}" http://localhost:3000/)
if [ "$response" = "200" ]; then
    exit 0
else
    echo "Health check failed with status: $response"
    exit 1
fi
EOF

chmod +x /usr/local/bin/healthcheck.sh

# Add healthcheck to cron (every 5 minutes)
echo "*/5 * * * * /usr/local/bin/healthcheck.sh || systemctl restart docker && docker start goal-tracker-frontend" | crontab -

log "✅ Frontend setup completed successfully!"
log "Container logs: docker logs -f goal-tracker-frontend"
