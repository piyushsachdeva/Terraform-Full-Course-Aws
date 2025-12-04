# varshith-mohan - 30 Days Terraform & AWS Challenge

**Participant:** @varshith-mohan  
**Start Date:** 2025-11-29  
**Challenge Repository:** [terraform-aws-30days](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws)  
**Personal Practice Repo:** https://github.com/varshith-mohan/Terraform-AWS/tree/main

## Progress Overview
- **Days Completed:** 6/30
- **Current Streak:** 2 days
- **Last Submission:** 2025-11-28

---

## Day 4: day - 04 State File Management - Remote Backend
**Date:** 2025-11-29  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 4 - day - 04 State File Management - Remote Backend](https://medium.com/@varshithmohan/day-4-state-file-management-remote-backend-a6a98d548260)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/varshithmohan_terraform-aws-devops-activity-7400509417030508544-Jclk?utm_source=share&utm_medium=member_desktop&rcm=ACoAADOUsG0BKiRvXjdtA3TgVX7vet_QBEoly48)
- **Code Repository:** [GitHub](https://github.com/varshith-mohan/Terraform-AWS/tree/main)
- **Issue:** [#238](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/238)

### 🎯 Key Learnings

Terraform’s state file is the core part of everything.
Local state is fine for practice but dangerous for real production work.
Centralized & secure state file management in multi user environment
S3 remote backend makes Terraform professional and safe.
State locking prevents broken deployments.
Understanding state and how Terraform really works.
Authentication and Authorization to AWS resources and follow IaC best practices.

---

## Day 5: Terraform Variables in AWS
**Date:** 2025-11-29  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 5 - Terraform Variables in AWS](https://medium.com/@iamvarshith45/day-5-terraform-variables-in-aws-329c3e94f25d)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/varshithmohan_terraform-aws-cloudautomation-activity-7400602325641252864-7wb9?utm_source=share&utm_medium=member_desktop&rcm=ACoAADOUsG0BKiRvXjdtA3TgVX7vet_QBEoly48)
- **Code Repository:** [GitHub](https://github.com/varshith-mohan/Terraform-AWS)
- **Issue:** [#257](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/257)

### 🎯 Key Learnings

understood Terraform variable types which are essential for writing clean, modular, and production-ready IaC. With the right use of variables, you can significantly improve Code quality, Reusability and Collaboration across teams, Improve readability and make configurations easier to understand and Store sensitive information more securely, additionally Make code more flexible, scalable, and maintainable

Input Variables – To pass values into Terraform configurations
Output Variables – To display values from a Terraform configuration.
Local Values – To create internal variables for organizing and simplifying infrastructure code.

---

## Day 6: Terraform File Structure
**Date:** 2025-11-30  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 6 - Terraform File Structure](https://medium.com/@iamvarshith45/day-6-terraform-file-structure-b0e280c2cf6f)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/varshithmohan_aws-terraform-cloudcomputing-activity-7400773821256982528-_don?utm_source=share&utm_medium=member_desktop&rcm=ACoAADOUsG0BKiRvXjdtA3TgVX7vet_QBEoly48)
- **Code Repository:** [GitHub](https://github.com/varshith-mohan/Terraform-AWS)
- **Issue:** [#265](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/265)

### 🎯 Key Learnings

I have earned about the Terraform File Structure and their best Practices.
and understood basic overview about the terraform modules and file structure for different environments.
Consistent naming across all files with clear, descriptive file names,
README + comments for better documentation,
Size Management Using modules for reusable components
This steps made the project look clean and 100% easier to scale efficiently.

---

## Day 3: AWS S3 Bucket with Terraform
**Date:** 2025-11-29  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 3 - AWS S3 Bucket with Terraform](https://medium.com/@varshithmohan/aws-s3-bucket-with-terraform-a5eff19909a0)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/varshithmohan_aws-s3-bucket-with-terraform-activity-7400436511508398080-Mnc3?utm_source=share&utm_medium=member_desktop&rcm=ACoAADOUsG0BKiRvXjdtA3TgVX7vet_QBEoly48)
- **Code Repository:** [GitHub](https://github.com/varshith-mohan/Terraform-AWS)
- **Issue:** [#232](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/232)

### 🎯 Key Learnings

explored
 - How Terraform providers work
 - IAM user creation and Policy
 - Configuring AWS as the provider
 - Writing a resource block to create an S3 bucket
 - Understanding Terraform init, plan, and apply and - - auto-aproove workflow

My S3 bucket now includes proper tagging and follows IaC best practices. 
Authentication and Authorization to AWS resources
Created a terraform file to provision aws S3 bucket 

---

## Day 2: Terraform Versioning and AWS Provider
**Date:** 2025-11-28  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 2 - Terraform Versioning and AWS Provider](https://medium.com/@bubbyplaycricket/day-2-versioning-in-terraform-setting-up-aws-cli-120db13986d9)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/varshithmohan_devops-terraform-iac-activity-7400263009539121152-x_Tb?utm_source=share&utm_medium=member_desktop&rcm=ACoAADOUsG0BKiRvXjdtA3TgVX7vet_QBEoly48)
- **Code Repository:** [GitHub](https://github.com/varshith-mohan/Terraform-AWS)
- **Issue:** [#228](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/228)

### 🎯 Key Learnings

Manual cloud provisioning does not scale — it slows teams, causes drift, and invites misconfigurations so 
IaC solves this with code-driven, repeatable, version-controlled infrastructure.
Terraform remains the top choice because of its cloud-agnostic nature (AWS, Azure, GCP, Kubernetes & more).
and The Terraform workflow is clean and predictable:
 init → validate → plan → apply → destroy
and additionally 
Git + Terraform gives complete auditability, consistency, and automation across multiple dev, staging and production environments.

---

## Day 1: Introduction to Terraform
**Date:** 2025-11-28  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 1 - Introduction to Terraform](https://medium.com/@bubbyplaycricket/day-1-terraform-and-infrastructure-as-code-iac-af09cb41b76f)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/varshithmohan_devops-terraform-iac-activity-7400245306786951168-YRRX?utm_source=share&utm_medium=member_desktop&rcm=ACoAADOUsG0BKiRvXjdtA3TgVX7vet_QBEoly48)
- **Code Repository:** [GitHub](https://github.com/varshith-mohan/Terraform-AWS/tree/main)
- **Issue:** [#225](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/225)

### 🎯 Key Learnings

I clearly understood that IaC tools are basically talking to cloud APIs for us. And with that, you can create repeatable, scalable infrastructure without the stress of manual setup, and 
Why Terraform is one of the most powerful IaC tools, understood the 
Terraform’s core workflow: Write → Init → Plan → Apply 
and Setting up Terraform locally.

---

