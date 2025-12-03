# arnab-logs - 30 Days Terraform & AWS Challenge

**Participant:** @arnab-logs  
**Start Date:** 2025-11-24  
**Challenge Repository:** [terraform-aws-30days](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws)  
**Personal Practice Repo:** https://github.com/arnab-logs/30-Days-of-Terraform/tree/main/day-01

## Progress Overview
- **Days Completed:** 4/30
- **Current Streak:** 1 day
- **Last Submission:** 2025-11-29

---

## Day 1: Intro to IaC
**Date:** 2025-11-24  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 1 - Intro to IaC](https://learning-out-loud-my-devops-journey.hashnode.dev/day-26-day-01-terraform-introduction-to-terraform)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/iamarnabnandi_30daysofawsterraform-activity-7398789541941317635-8OG9?utm_source=share&utm_medium=member_desktop&rcm=ACoAADrH7I4Bqi8Arg0Je9JPIHTlEKr6G9C9JwM)
- **Code Repository:** [GitHub](https://github.com/arnab-logs/30-Days-of-Terraform/tree/main/day-01)
- **Issue:** [#39](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/39)

### 🎯 Key Learnings

-What Infrastructure as Code (IaC) is and why it matters.
-How manual cloud setup can be messy, inconsistent, and error-prone.
-Basics of Terraform workflow
-Installing Terraform on macOS and Ubuntu/Debian, plus helpful setup commands.

---

## Day 2: Terraform AWS Providers
**Date:** 2025-11-25  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 2 - Terraform AWS Providers](https://learning-out-loud-my-devops-journey.hashnode.dev/day-27-day-02-from-terraform-code-to-aws-actions-the-role-of-providers)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/iamarnabnandi_30daysofawsterraform-activity-7399145832807268352-XEe-?utm_source=share&utm_medium=member_desktop&rcm=ACoAADrH7I4Bqi8Arg0Je9JPIHTlEKr6G9C9JwM)
- **Code Repository:** [GitHub](https://github.com/arnab-logs/30-Days-of-Terraform/tree/main/day-02)
- **Issue:** [#82](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/82)

### 🎯 Key Learnings

I learned that:
-Terraform doesn’t directly speak to AWS, providers act as the translators.
-We use terraform init to download and prepare the provider plugin.
-Providers come in official, partner, and community forms.
-Terraform lets us lock provider versions to avoid breaking changes.
-Version constraints like ~> 6.0 help ensure safe, predictable upgrades.
-Wrote a simple Terraform script using the AWS provider and saw how plan it.

---

## Day 4: Terraform State file management with AWS S3
**Date:** 2025-11-27  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 4 - Terraform State file management with AWS S3](https://learning-out-loud-my-devops-journey.hashnode.dev/day-29-day-04-terraform-state-file-management-with-aws-s3)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/iamarnabnandi_30daysofawsterraform-activity-7399838147573899264-0HWD?utm_source=share&utm_medium=member_desktop&rcm=ACoAADrH7I4Bqi8Arg0Je9JPIHTlEKr6G9C9JwM)
- **Code Repository:** [GitHub](https://github.com/arnab-logs/30-Days-of-Terraform/tree/main/day-04)
- **Issue:** [#175](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/175)

### 🎯 Key Learnings

*Terraform state file and its importance
* Difference between desired state and actual state
* Risks of storing state locally
* Introduction to remote backends
* Using S3 for remote state storage
* Setting up and initialising S3 backend
* State locking and best practices

---

## Day 6: AWS Terraform Project Structure
**Date:** 2025-11-29  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 6 - AWS Terraform Project Structure](https://learning-out-loud-my-devops-journey.hashnode.dev/day-31-day-06-aws-terraform-project-structure-and-best-practices)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/iamarnabnandi_30daysofawsterraform-activity-7400513391762575360-Juiv?utm_source=share&utm_medium=member_desktop&rcm=ACoAADrH7I4Bqi8Arg0Je9JPIHTlEKr6G9C9JwM)
- **Code Repository:** [GitHub](https://github.com/arnab-logs/30-Days-of-Terraform/tree/main/day-06)
- **Issue:** [#239](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/239)

### 🎯 Key Learnings

- Terraform projects start simple with a single main.tf file.
- Organizing files improves readability and maintenance.
- Separate variables.tf, outputs.tf, providers.tf, backend.tf.
- Protect sensitive values with .gitignore.
- Use terraform.tfvars.example for sharing.
- Handle growth via environments or .tfvars separation.
- Root module is the main project folder.

---

