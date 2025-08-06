# Day 1: Introduction to Terraform

## Topics Covered
- Understanding Infrastructure as Code (IaC)
- Why we need IaC
- What is Terraform and its benefits
- Challenges with the traditional approach
- Terraform Workflow
- Installing Terraform

## Key Learning Points

### What is Infrastructure as Code?
Provisioning your infrastructure through code instead of manual processes.

### Why Infrastructure as Code?
- **Consistency**: Identical environments across dev, staging, and production
- **Time Efficiency**: Automated provisioning saves hours of manual work
- **Cost Management**: Easy to track costs and automate cleanup
- **Scalability**: Deploy to hundreds of servers with same effort as one
- **Version Control**: Track changes in Git
- **Reduced Human Error**: Eliminate manual configuration mistakes
- **Collaboration**: Team can work together on infrastructure

### Benefits of IaC
- Consistent environment deployment
- Easy to track and manage costs
- Write once, deploy many (single codebase)
- Time-saving automation
- Reduced human error
- Cost optimization through automation
- Version control for infrastructure changes
- Automated cleanup and scheduled destruction
- Developer focus on application development
- Easy creation of identical production environments for troubleshooting

### What is Terraform?
Infrastructure as Code tool that helps automate infrastructure provisioning and management across multiple cloud providers.

### How Terraform Works
Write Terraform files → Run Terraform commands → Call AWS APIs through Terraform Provider

**Terraform Workflow Phases:**
1. `terraform init` - Initialize the working directory
2. `terraform validate` - Validate the configuration files
3. `terraform plan` - Create an execution plan
4. `terraform apply` - Apply the changes to reach desired state
5. `terraform destroy` - Destroy the infrastructure when needed

## Tasks for Practice

### Install Terraform
Follow the installation guide: https://developer.hashicorp.com/terraform/install

or 

### Common Installation Commands
```bash
# For macOS
brew install hashicorp/tap/terraform

# For Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Setup Commands
```bash
terraform -install-autocomplete
alias tf=terraform
terraform -version
```

### Common Installation Error (macOS)
If you encounter:
```
Error: No developer tools installed.
```
Install Command Line Tools:
```bash
xcode-select --install
```

## Next Steps
Proceed to Day 2 to learn about Terraform Providers and their importance in AWS infrastructure management.
