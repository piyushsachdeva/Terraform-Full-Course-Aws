#!/bin/bash
# Frontend deployment script - Simplified version
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "=== Frontend Deployment Started at $(date) ==="

# Update and install dependencies
echo "Installing system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io curl unzip netcat-openbsd

# Start Docker
echo "Starting Docker service..."
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Install AWS CLI v2
echo "Installing AWS CLI..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Docker Hub login
if [ -n "${dockerhub_username}" ] && [ -n "${dockerhub_password}" ]; then
    echo "Logging into Docker Hub..."
    echo "${dockerhub_password}" | docker login -u "${dockerhub_username}" --password-stdin
else
    echo "Using public Docker image (no credentials provided)"
fi

# Backend URL
BACKEND_URL="${backend_internal_url}"
echo "Backend URL: $BACKEND_URL"

# Verify backend connectivity before starting frontend
echo "Verifying backend connectivity..."

# Pull Docker image
echo "Pulling frontend image: ${docker_image}"
docker pull ${docker_image}

# Get backend URL and test connectivity
BACKEND_URL="${backend_internal_url}"
echo "Backend URL: $BACKEND_URL"

# Extract hostname and port for connectivity test
BACKEND_HOST=$(echo $BACKEND_URL | sed -e 's|^[^/]*//||' -e 's|:.*$||' -e 's|/.*$||')
BACKEND_PORT=$(echo $BACKEND_URL | grep -o ":[0-9]*" | tr -d ':')
BACKEND_PORT=$${BACKEND_PORT:-80}

echo "Testing backend connectivity at $BACKEND_HOST:$BACKEND_PORT..."
for i in {1..30}; do
    if nc -z -w 3 $BACKEND_HOST $BACKEND_PORT 2>/dev/null; then
        echo "✓ Backend is reachable"
        break
    fi
    echo "Waiting for backend... ($i/30)"
    sleep 10
done

# Run frontend container
echo "Starting frontend container on port 3000..."
docker run -d \
  --name goal-tracker-frontend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e PORT=3000 \
  -e BACKEND_URL="$BACKEND_URL" \
  -e NODE_ENV=production \
  ${docker_image}

# Verify container is running
sleep 5
if docker ps | grep -q goal-tracker-frontend; then
    echo "✓ Frontend container is running"
    docker logs goal-tracker-frontend
else
    echo "✗ Frontend container failed to start"
    docker logs goal-tracker-frontend
    exit 1
fi

echo "=== Frontend Deployment Completed at $(date) ==="
