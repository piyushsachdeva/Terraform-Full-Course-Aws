#!/bin/bash
set -e

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/user-data.log
}

log "Starting backend setup..."

# Update system
log "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install Docker and dependencies
log "Installing Docker and utilities..."
apt-get install -y docker.io jq netcat-openbsd dnsutils unzip curl
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
log "✅ Docker installed and started successfully"

# Install AWS CLI v2
log "Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Get region from instance metadata
REGION="${region}"
log "Region: $REGION"

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

# Get database credentials from Secrets Manager
log "Retrieving database credentials from Secrets Manager..."
SECRET=$(aws secretsmanager get-secret-value --secret-id ${db_secret_arn} --region $REGION --query SecretString --output text)

if [ -z "$SECRET" ]; then
    log "❌ ERROR: Failed to retrieve database credentials"
    exit 1
fi

DB_USERNAME=$(echo $SECRET | jq -r '.username')
DB_PASSWORD=$(echo $SECRET | jq -r '.password')
DB_HOST=$(echo $SECRET | jq -r '.host')
DB_PORT=$(echo $SECRET | jq -r '.port')
DB_NAME=$(echo $SECRET | jq -r '.dbname')

# Verify all required secrets were retrieved
if [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_PORT" ]; then
    log "❌ ERROR: Failed to retrieve all required database secrets from Secrets Manager"
    log "Missing secrets:"
    [ -z "$DB_USERNAME" ] && log "  - username"
    [ -z "$DB_PASSWORD" ] && log "  - password"
    [ -z "$DB_HOST" ] && log "  - host"
    [ -z "$DB_NAME" ] && log "  - dbname"
    [ -z "$DB_PORT" ] && log "  - port"
    exit 1
fi

log "✅ Database configuration retrieved successfully"
log "DB Host: $DB_HOST"
log "DB Port: $DB_PORT"
log "DB Name: $DB_NAME"
log "DB Username: $DB_USERNAME"

# Ensure DNS resolution is working before trying to connect to the database
log "Checking DNS resolution for database host: $DB_HOST"
max_dns_attempts=20
attempt=1
while [ $attempt -le $max_dns_attempts ]; do
    log "DNS resolution attempt $attempt of $max_dns_attempts..."
    if nslookup "$DB_HOST" > /dev/null 2>&1; then
        log "✅ Successfully resolved database host: $DB_HOST"
        break
    else
        if [ $attempt -eq $max_dns_attempts ]; then
            log "⚠️  WARNING: Failed to resolve database host after $max_dns_attempts attempts. Proceeding anyway..."
        else
            log "Failed to resolve database host. Waiting 10 seconds before retry..."
            sleep 10
        fi
        attempt=$((attempt+1))
    fi
done

# Check database connectivity
log "Checking database connectivity at $DB_HOST:$DB_PORT"
max_db_attempts=10
attempt=1
while [ $attempt -le $max_db_attempts ]; do
    log "Database connectivity attempt $attempt of $max_db_attempts..."
    if nc -z -w 3 "$DB_HOST" "$DB_PORT" 2>/dev/null; then
        log "✅ Successfully connected to database at $DB_HOST:$DB_PORT"
        break
    else
        if [ $attempt -eq $max_db_attempts ]; then
            log "⚠️  WARNING: Could not verify database connectivity after $max_db_attempts attempts. Proceeding anyway..."
        else
            log "Database not yet reachable. Waiting 10 seconds before retry..."
            sleep 10
        fi
        attempt=$((attempt+1))
    fi
done

# Pull and run backend container
log "Pulling backend image from Docker Hub..."
docker pull ${docker_image}

log "Starting backend container..."
docker run -d \
  --name goal-tracker-backend \
  --restart unless-stopped \
  -p 8080:8080 \
  -e DB_USERNAME="$DB_USERNAME" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e DB_HOST="$DB_HOST" \
  -e DB_PORT="$DB_PORT" \
  -e DB_NAME="$DB_NAME" \
  -e SSL=require \
  -e PORT=8080 \
  ${docker_image}

# Wait for container to be healthy
log "Waiting for backend to be healthy..."
sleep 15

# Check container status
if docker ps | grep -q goal-tracker-backend; then
    log "✅ Backend container is running"
else
    log "❌ ERROR: Backend container failed to start"
    docker logs goal-tracker-backend
    exit 1
fi

# Test backend health
log "Testing backend health endpoint..."
for i in {1..30}; do
    if curl -s http://localhost:8080/goals > /dev/null 2>&1; then
        log "✅ Backend is responding to requests"
        break
    fi
    if [ $i -eq 30 ]; then
        log "⚠️  WARNING: Backend health check timeout"
        docker logs goal-tracker-backend
    fi
    sleep 2
done

# Install CloudWatch Agent
log "Installing CloudWatch Agent..."
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm -f ./amazon-cloudwatch-agent.deb

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
            "log_group_name": "/aws/ec2/${environment}-${project}/backend",
            "log_stream_name": "{instance_id}/user-data"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "${environment}/${project}/Backend",
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
response=$(curl -s -o /dev/null -w "%%{http_code}" http://localhost:8080/goals)
if [ "$response" = "200" ]; then
    exit 0
else
    echo "Health check failed with status: $response"
    exit 1
fi
EOF

chmod +x /usr/local/bin/healthcheck.sh

# Add healthcheck to cron (every 5 minutes)
echo "*/5 * * * * /usr/local/bin/healthcheck.sh || systemctl restart docker && docker start goal-tracker-backend" | crontab -

log "✅ Backend setup completed successfully!"
log "Container logs: docker logs -f goal-tracker-backend"
