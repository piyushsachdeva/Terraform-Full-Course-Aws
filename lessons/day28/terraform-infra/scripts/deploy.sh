git #!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Change to dev environment directory
cd "$(dirname "$0")/../environments/dev"

print_status "Starting complete infrastructure deployment..."

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    print_error "Terraform not found. Please install Terraform >= 1.5"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found. Please install AWS CLI v2"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "Docker not found. Please install Docker"
    exit 1
fi

print_success "All prerequisites met"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    print_error "Please edit terraform.tfvars with your values and run this script again"
    print_warning "Required changes:"
    echo "  - ssh_key_name: Your AWS key pair name"
    echo "  - allowed_ssh_cidr: Your IP address"
    exit 1
fi

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

if [ $? -ne 0 ]; then
    print_error "Terraform init failed"
    exit 1
fi

print_success "Terraform initialized"

# Validate configuration
print_status "Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    print_error "Terraform validation failed"
    exit 1
fi

print_success "Configuration validated"

# Plan
print_status "Creating Terraform plan..."
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
    print_error "Terraform plan failed"
    exit 1
fi

print_success "Plan created successfully"

# Confirm before applying
echo ""
print_warning "Review the plan above. This will create AWS resources that may incur costs."
read -p "Do you want to proceed with deployment? (yes/no) " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_warning "Deployment cancelled"
    exit 0
fi

# Apply
print_status "Applying Terraform configuration..."
terraform apply tfplan

if [ $? -ne 0 ]; then
    print_error "Terraform apply failed"
    exit 1
fi

print_success "Infrastructure deployed successfully!"

# Display outputs
echo ""
print_status "Deployment Summary:"
terraform output helpful_commands

echo ""
print_success "Deployment completed!"
print_warning "Next steps:"
echo "  1. Build and push Docker images: ../../scripts/build-and-push.sh"
echo "  2. Wait for instances to launch (5-10 minutes)"
echo "  3. Access your application at: $(terraform output -raw application_url)"
