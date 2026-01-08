#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if running from correct directory
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars not found. Please run this script from environments/dev directory"
    print_warning "Run: cd terraform-infra/environments/dev"
    exit 1
fi

# Get AWS region
print_status "Getting AWS region..."
REGION=$(terraform output -raw region 2>/dev/null || echo "us-east-1")
print_success "Region: $REGION"

# Get Docker image names from Terraform
print_status "Getting Docker image names from Terraform variables..."
FRONTEND_IMAGE=$(terraform output -raw frontend_docker_image 2>/dev/null)
BACKEND_IMAGE=$(terraform output -raw backend_docker_image 2>/dev/null)

if [ -z "$FRONTEND_IMAGE" ] || [ -z "$BACKEND_IMAGE" ]; then
    print_error "Could not get Docker image names. Please check your terraform.tfvars"
    exit 1
fi

print_success "Frontend image: $FRONTEND_IMAGE"
print_success "Backend image: $BACKEND_IMAGE"

# Login to Docker Hub (optional, only if credentials provided)
print_status "Checking Docker Hub authentication..."
if docker info 2>/dev/null | grep -q "Username"; then
    print_success "Already logged into Docker Hub"
else
    print_warning "Not logged into Docker Hub. For private images, run: docker login"
    read -p "Do you want to login to Docker Hub now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    fi
fi

# Build and push frontend
print_status "Building frontend image..."
cd ../../../frontend

docker build -t goal-tracker-frontend:latest .

if [ $? -eq 0 ]; then
    print_success "Frontend image built successfully"
else
    print_error "Failed to build frontend image"
    exit 1
fi

print_status "Tagging and pushing frontend image..."
docker tag goal-tracker-frontend:latest $FRONTEND_IMAGE
docker tag goal-tracker-frontend:latest ${FRONTEND_IMAGE%:*}:$(date +%Y%m%d-%H%M%S)

docker push $FRONTEND_IMAGE
docker push ${FRONTEND_IMAGE%:*}:$(date +%Y%m%d-%H%M%S)

print_success "Frontend image pushed to Docker Hub"

# Build and push backend
print_status "Building backend image..."
cd ../backend

docker build -t goal-tracker-backend:latest .

if [ $? -eq 0 ]; then
    print_success "Backend image built successfully"
else
    print_error "Failed to build backend image"
    exit 1
fi

print_status "Tagging and pushing backend image..."
docker tag goal-tracker-backend:latest $BACKEND_IMAGE
docker tag goal-tracker-backend:latest ${BACKEND_IMAGE%:*}:$(date +%Y%m%d-%H%M%S)

docker push $BACKEND_IMAGE
docker push ${BACKEND_IMAGE%:*}:$(date +%Y%m%d-%H%M%S)

print_success "Backend image pushed to Docker Hub"

# Return to terraform directory
cd ../terraform-infra/environments/dev

# Ask if user wants to trigger instance refresh
echo ""
read -p "Do you want to trigger ASG instance refresh to deploy new images? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Triggering instance refresh for frontend ASG..."
    FRONTEND_ASG=$(terraform output -raw frontend_asg_name 2>/dev/null)
    if [ -n "$FRONTEND_ASG" ]; then
        aws autoscaling start-instance-refresh \
            --auto-scaling-group-name $FRONTEND_ASG \
            --region $REGION
        print_success "Frontend ASG refresh triggered"
    fi

    print_status "Triggering instance refresh for backend ASG..."
    BACKEND_ASG=$(terraform output -raw backend_asg_name 2>/dev/null)
    if [ -n "$BACKEND_ASG" ]; then
        aws autoscaling start-instance-refresh \
            --auto-scaling-group-name $BACKEND_ASG \
            --region $REGION
        print_success "Backend ASG refresh triggered"
    fi

    echo ""
    print_success "Instance refresh initiated. New instances will be launched with updated images."
    print_warning "This process may take several minutes to complete."
fi

echo ""
print_success "Build and push complete!"
echo ""
print_status "Next steps:"
echo "  - Monitor ASG instance refresh: AWS Console > EC2 > Auto Scaling Groups"
echo "  - View application: http://\$(terraform output -raw alb_dns_name)"
echo "  - Check logs: aws logs tail /aws/ec2/\$(terraform output -raw environment)-\$(terraform output -raw project)/[frontend|backend] --follow"
echo ""
