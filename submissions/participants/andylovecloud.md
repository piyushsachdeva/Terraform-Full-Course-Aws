# andylovecloud - 30 Days Terraform & AWS Challenge

**Participant:** @andylovecloud  
**Start Date:** 2025-11-25  
**Challenge Repository:** [terraform-aws-30days](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws)  
**Personal Practice Repo:** https://github.com/andylovecloud/Terraform-Full-Course-Aws/tree/main/lessons/day02

## Progress Overview
- **Days Completed:** 5/30
- **Current Streak:** 1 day
- **Last Submission:** 2025-11-26

---

## Day 2: Terraform AWS Provider explained
**Date:** 2025-11-25  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 2 - Terraform AWS Provider explained](https://dev.to/andylovecloud/day-2-the-bridge-to-the-cloud-understanding-the-terraform-aws-provider-459p)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/anduytranhuynh_230-terraform-aws-provider-explained-activity-7399142749352038401-1qxx?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAyVz1gByMoLT7eaAGviuC1HEPufG4tspEY)
- **Code Repository:** [GitHub](https://github.com/andylovecloud/Terraform-Full-Course-Aws/tree/main/lessons/day02)
- **Issue:** [#81](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/81)

### 🎯 Key Learnings

- What are Terraform Providers
- How terraform version and provider version differ.
- What are the version operators with examples
- Created a new main.tf file a simple provider code and initialized it using terraform init.
- Used terraform plan to see how does terraform plan the resource deployment.

---

## Day 4:  Terraform State file management with AWS S3 | Remote Backend
**Date:** 2025-11-27  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 4 -  Terraform State file management with AWS S3 | Remote Backend](https://dev.to/andylovecloud/day-04-understanding-the-terraform-state-file-and-remote-backend-3h0h)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/anduytranhuynh_430-terraform-state-file-management-with-activity-7399867583274946560-aHOL?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAyVz1gByMoLT7eaAGviuC1HEPufG4tspEY)
- **Code Repository:** [GitHub](https://github.com/andylovecloud/Terraform-Full-Course-Aws/tree/main/lessons/day04)
- **Issue:** [#178](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/178)

### 🎯 Key Learnings

- Understanding Terraform State & Why Remote Backends Matter

Best practices:
- Never edit the state file manually
- Separate state per environment (dev/test/prod)
- Back it up regularly
- Enable encryption & locking

---

## Day 5: Terraform Variables in AWS 
**Date:** 2025-11-30  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 5 - Terraform Variables in AWS ](https://dev.to/andylovecloud/day-05-why-terraform-variables-are-essential-for-efficient-iac-3anj)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/anduytranhuynh_530-terraform-variables-in-aws-input-activity-7400961006606204928-LrTj?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAyVz1gByMoLT7eaAGviuC1HEPufG4tspEY)
- **Code Repository:** [GitHub](https://github.com/andylovecloud/Terraform-Full-Course-Aws/tree/main/lessons/day05)
- **Issue:** [#291](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/291)

### 🎯 Key Learnings

The 3 Variable Types You Need to Know: 🔹 Input Variables: The parameters you pass in (like arguments in a function). 🔹 Locals: Internal logic for consistent naming and math (e.g., combining dev + vpc to make dev-vpc). 🔹 Outputs: The data Terraform gives back after deployment (like your new EC2 Instance ID).

💡 The Gotcha: Variable Precedence Not all variables are created equal. If you define a variable in multiple places, Terraform follows a strict hierarchy. Remember: CLI flags (-var) always win.

Lowest Priority: default inside the block

Mid Priority: terraform.tfvars files

Highest Priority: Command Line (-var)

---

## Day 1: Terraform -install-autocomplete
**Date:** 2025-11-24  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 1 - Terraform -install-autocomplete](https://dev.to/andylovecloud/day-01-how-does-terraform-work-intro-to-iac-3d6p)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/anduytranhuynh_130-how-does-terraform-work-intro-to-activity-7398711701463883777-53eH?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAyVz1gByMoLT7eaAGviuC1HEPufG4tspEY)
- **Code Repository:** [GitHub](https://github.com/andylovecloud/Terraform-Full-Course-Aws/blob/main/lessons/day01/day-1-MySetup.md)
- **Issue:** [#16](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/16)

### 🎯 Key Learnings

🚫 The Manual Trap: Clicking through consoles feels easy at first, but for a simple 3-tier architecture across 6 environments (Dev, QA, Prod, etc.), it can take upwards of 12 hours!


✅ The Solution: Terraform allows us to define infrastructure as code—making it automated, consistent, and reusable.

---

## Day 3: Create an AWS S3 Bucket Using Terraform (it's simple)
**Date:** 2025-11-26  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 3 - Create an AWS S3 Bucket Using Terraform (it's simple)](https://dev.to/andylovecloud/day-03-provisioning-your-first-aws-s3-bucket-with-terraform-1efl)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/anduytranhuynh_330-create-an-aws-s3-bucket-using-terraform-activity-7399510237830959104-qdcz?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAyVz1gByMoLT7eaAGviuC1HEPufG4tspEY)
- **Code Repository:** [GitHub](https://github.com/andylovecloud/Terraform-Full-Course-Aws/tree/main/lessons/day03)
- **Issue:** [#127](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/127)

### 🎯 Key Learnings

The core workflow for creating an AWS S3 bucket:
 ✅ Define your configuration in [main.tf](http://main.tf/)
 ✅ Initialize with terraform init
 ✅ Plan changes using terraform plan
 ✅ Apply to provision resources with terraform apply
 ✅ Destroy when done using terraform destroy

---

