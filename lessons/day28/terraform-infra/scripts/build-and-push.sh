#!/bin/bash
set -e

# =================================================================
# Docker Hub Build and Push Script for Goal Tracker Application
# =================================================================
# This script builds Docker images for frontend and backend,
# then pushes them to Docker Hub
# 
# Usage: Can run from anywhere in the project
#   ./terraform-infra/scripts/build-and-push.sh [dockerhub_username]
#   
# Or with custom image names:
#   ./terraform-infra/scripts/build-and-push.sh username/frontend:tag username/backend:tag
# =================================================================

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

# Find project root (where frontend/ and backend/ directories exist)
print_status "Detecting project root..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ ! -d "$PROJECT_ROOT/frontend" ] || [ ! -d "$PROJECT_ROOT/backend" ]; then
    print_error "Could not find frontend and backend directories"
    print_error "Expected structure: project_root/{frontend,backend}"
    exit 1
fi

print_success "Project root: $PROJECT_ROOT"

# Parse command line arguments or try to get from Terraform
if [ $# -eq 2 ]; then
    # Two arguments: frontend and backend image names
    FRONTEND_IMAGE="$1"
    BACKEND_IMAGE="$2"
    print_success "Using provided image names"
elif [ $# -eq 1 ]; then
    # One argument: Docker Hub username
    DOCKERHUB_USERNAME="$1"
    FRONTEND_IMAGE="$DOCKERHUB_USERNAME/goal-tracker-frontend:latest"
    BACKEND_IMAGE="$DOCKERHUB_USERNAME/goal-tracker-backend:latest"
    print_success "Using Docker Hub username: $DOCKERHUB_USERNAME"
else
    # Try to get from Terraform outputs first
    print_status "Trying to get image names from Terraform outputs..."
    TERRAFORM_DIR="$PROJECT_ROOT/terraform-infra/environments/dev"
    
    if [ -d "$TERRAFORM_DIR" ]; then
        cd "$TERRAFORM_DIR"
        FRONTEND_IMAGE=$(terraform output -raw frontend_docker_image 2>/dev/null || echo "")
        BACKEND_IMAGE=$(terraform output -raw backend_docker_image 2>/dev/null || echo "")
    fi
    
    # If Terraform outputs are empty, try to extract from terraform.tfvars
    if [ -z "$FRONTEND_IMAGE" ] || [ -z "$BACKEND_IMAGE" ]; then
        print_warning "Terraform outputs not available, reading from terraform.tfvars..."
        
        if [ -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
            FRONTEND_IMAGE=$(grep '^frontend_docker_image' "$TERRAFORM_DIR/terraform.tfvars" | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ')
            BACKEND_IMAGE=$(grep '^backend_docker_image' "$TERRAFORM_DIR/terraform.tfvars" | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ')
        fi
    fi
    
    # If still empty, prompt user
    if [ -z "$FRONTEND_IMAGE" ] || [ -z "$BACKEND_IMAGE" ]; then
        print_error "Could not determine Docker image names"
        echo ""
        echo "Please provide your Docker Hub username or image names:"
        echo ""
        echo "Option 1: Run with username"
        echo "  $0 your-dockerhub-username"
        echo ""
        echo "Option 2: Run with full image names"
        echo "  $0 username/frontend:latest username/backend:latest"
        echo ""
        echo "Option 3: Set in terraform.tfvars:"
        echo "  frontend_docker_image = \"username/goal-tracker-frontend:latest\""
        echo "  backend_docker_image  = \"username/goal-tracker-backend:latest\""
        exit 1
    fi
fi

print_success "Frontend image: $FRONTEND_IMAGE"
print_success "Backend image: $BACKEND_IMAGE"

# Get AWS region (optional, for ASG refresh)
REGION="us-east-1"
if [ -d "$PROJECT_ROOT/terraform-infra/environments/dev" ]; then
    cd "$PROJECT_ROOT/terraform-infra/environments/dev"
    REGION=$(terraform output -raw region 2>/dev/null || echo "us-east-1")
fi

# Login to Docker Hub
print_status "Checking Docker Hub authentication..."
DOCKER_USERNAME=$(echo "$FRONTEND_IMAGE" | cut -d'/' -f1)
print_status "Docker Hub username: $DOCKER_USERNAME"

if docker info 2>/dev/null | grep -q "Username: $DOCKER_USERNAME"; then
    print_success "Already logged into Docker Hub as $DOCKER_USERNAME"
else
    print_warning "Not logged into Docker Hub as $DOCKER_USERNAME"
    print_status "Attempting to login to Docker Hub..."
    
    if ! docker login; then
        print_error "Docker Hub login failed"
        print_warning "Please run 'docker login' manually before running this script"
        exit 1
    fi
    
    print_success "Successfully logged into Docker Hub"
fi

echo ""
print_status "========================================"
print_status "Building and Pushing FRONTEND Image"
print_status "========================================"

# Build frontend
print_status "Building frontend image..."
cd "$PROJECT_ROOT/frontend"

if ! docker build -t goal-tracker-frontend:latest .; then
    print_error "Failed to build frontend image"
    exit 1
fi
print_success "Frontend image built successfully"

# Tag frontend with multiple tags
print_status "Tagging frontend image for Docker Hub..."
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
docker tag goal-tracker-frontend:latest $FRONTEND_IMAGE
docker tag goal-tracker-frontend:latest ${FRONTEND_IMAGE%:*}:$TIMESTAMP

print_success "Tagged as: $FRONTEND_IMAGE"
print_success "Tagged as: ${FRONTEND_IMAGE%:*}:$TIMESTAMP"

# Push frontend to Docker Hub
print_status "Pushing frontend images to Docker Hub..."
if ! docker push $FRONTEND_IMAGE; then
    print_error "Failed to push frontend image to Docker Hub"
    exit 1
fi

if ! docker push ${FRONTEND_IMAGE%:*}:$TIMESTAMP; then
    print_warning "Failed to push timestamped frontend image (non-critical)"
fi

print_success "Frontend image pushed to Docker Hub successfully"

echo ""
print_status "========================================"
print_status "Building and Pushing BACKEND Image"
print_status "========================================"

# Build backend
print_status "Building backend image..."
cd "$PROJECT_ROOT/backend"

if ! docker build -t goal-tracker-backend:latest .; then
    print_error "Failed to build backend image"
    exit 1
fi
print_success "Backend image built successfully"

# Tag backend with multiple tags
print_status "Tagging backend image for Docker Hub..."
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
docker tag goal-tracker-backend:latest $BACKEND_IMAGE
docker tag goal-tracker-backend:latest ${BACKEND_IMAGE%:*}:$TIMESTAMP

print_success "Tagged as: $BACKEND_IMAGE"
print_success "Tagged as: ${BACKEND_IMAGE%:*}:$TIMESTAMP"

# Push backend to Docker Hub
print_status "Pushing backend images to Docker Hub..."
if ! docker push $BACKEND_IMAGE; then
    print_error "Failed to push backend image to Docker Hub"
    exit 1
fi

if ! docker push ${BACKEND_IMAGE%:*}:$TIMESTAMP; then
    print_warning "Failed to push timestamped backend image (non-critical)"
fi

print_success "Backend image pushed to Docker Hub successfully"

# Return to original directory
cd "$PROJECT_ROOT"

echo ""
print_status "========================================"
print_status "Docker Hub Push Summary"
print_status "========================================"
print_success "Frontend image: $FRONTEND_IMAGE"
print_success "Backend image: $BACKEND_IMAGE"
print_success "Images are now available on Docker Hub!"

# Extract username from image name
DOCKER_USERNAME=$(echo "$FRONTEND_IMAGE" | cut -d'/' -f1)

# Ask if user wants to trigger instance refresh (only if Terraform is deployed)
TERRAFORM_DIR="$PROJECT_ROOT/terraform-infra/environments/dev"
if [ -d "$TERRAFORM_DIR" ]; then
    cd "$TERRAFORM_DIR"
    
    # Check if Terraform state exists
    if terraform state list &>/dev/null; then
        echo ""
        print_status "Optional: Update running infrastructure with new images"
        read -p "Do you want to trigger ASG instance refresh to deploy new images? (y/n) " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Triggering instance refresh for frontend ASG..."
            FRONTEND_ASG=$(terraform output -raw frontend_asg_name 2>/dev/null)
            if [ -n "$FRONTEND_ASG" ]; then
                aws autoscaling start-instance-refresh \
                    --auto-scaling-group-name $FRONTEND_ASG \
                    --region $REGION 2>/dev/null && \
                print_success "Frontend ASG refresh triggered: $FRONTEND_ASG" || \
                print_warning "Failed to trigger frontend ASG refresh (AWS CLI may not be configured)"
            else
                print_warning "Frontend ASG name not found in Terraform outputs"
            fi

            print_status "Triggering instance refresh for backend ASG..."
            BACKEND_ASG=$(terraform output -raw backend_asg_name 2>/dev/null)
            if [ -n "$BACKEND_ASG" ]; then
                aws autoscaling start-instance-refresh \
                    --auto-scaling-group-name $BACKEND_ASG \
                    --region $REGION 2>/dev/null && \
                print_success "Backend ASG refresh triggered: $BACKEND_ASG" || \
                print_warning "Failed to trigger backend ASG refresh (AWS CLI may not be configured)"
            else
                print_warning "Backend ASG name not found in Terraform outputs"
            fi

            echo ""
            print_success "Instance refresh initiated. New instances will be launched with updated images."
            print_warning "This process may take 5-10 minutes to complete."
            echo ""
            print_status "Monitor progress:"
            echo "  AWS Console: EC2 > Auto Scaling Groups > Instance Refresh tab"
            if [ -n "$FRONTEND_ASG" ]; then
                echo "  CLI: aws autoscaling describe-instance-refreshes --auto-scaling-group-name $FRONTEND_ASG --region $REGION"
            fi
        else
            print_warning "Skipped instance refresh. New images will be used on next scale-out or instance replacement."
        fi
    else
        print_warning "Terraform infrastructure not deployed yet. Skipping ASG refresh."
    fi
fi

echo ""
print_success "==================================="
print_success "Build and Push Complete!"
print_success "==================================="
echo ""
print_status "Next steps:"
echo "  1. View images on Docker Hub: https://hub.docker.com/u/$DOCKER_USERNAME"
if [ -d "$TERRAFORM_DIR" ] && terraform state list &>/dev/null 2>&1; then
    echo "  2. Access application: http://\$(cd $TERRAFORM_DIR && terraform output -raw alb_dns_name 2>/dev/null)"
    echo "  3. Check frontend logs: aws logs tail /aws/ec2/\$(cd $TERRAFORM_DIR && terraform output -raw environment 2>/dev/null)-\$(cd $TERRAFORM_DIR && terraform output -raw project 2>/dev/null)/frontend --follow --region $REGION"
    echo "  4. Check backend logs: aws logs tail /aws/ec2/\$(cd $TERRAFORM_DIR && terraform output -raw environment 2>/dev/null)-\$(cd $TERRAFORM_DIR && terraform output -raw project 2>/dev/null)/backend --follow --region $REGION"
else
    echo "  2. Deploy infrastructure: cd $PROJECT_ROOT/terraform-infra/environments/dev && terraform apply"
    echo "  3. Or test locally: cd $PROJECT_ROOT/docker-local-deployment && docker-compose up"
fi
echo ""
