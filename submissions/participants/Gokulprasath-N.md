# Gokulprasath-N - 30 Days Terraform & AWS Challenge

**Participant:** @Gokulprasath-N  
**Start Date:** 2025-11-24  
**Challenge Repository:** [terraform-aws-30days](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws)  
**Personal Practice Repo:** https://github.com/Gokulprasath-N/Terraform-Full-Course-Aws/tree/main/lessons/day01

## Progress Overview
- **Days Completed:** 6/30
- **Current Streak:** 1 day
- **Last Submission:** 2025-11-27

---

## Day 1: The Foundation – Why Terraform?
**Date:** 2025-11-24  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 1 - The Foundation – Why Terraform?](https://dev.to/gokulprasath_n_42438fd633/day-130-the-foundation-why-terraform-3d4i)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/gokulprasath-n_day-130-the-foundation-why-terraform-activity-7398747258168483840-tLH_?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADpuYVMBDniXo9yNNR3dTMoe7XPh7tZCvYI)
- **Code Repository:** [GitHub](https://github.com/Gokulprasath-N/Terraform-Full-Course-Aws/tree/main/lessons/day01)
- **Issue:** [#22](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/22)

### 🎯 Key Learnings

Terraform: Infrastructure as Code (IaC)

⦁	What it is: Terraform is a popular, cloud-agnostic Infrastructure as Code (IaC) tool created by HashiCorp.

⦁	Core Purpose: It allows you to define and provision cloud infrastructure (like AWS EC2, VPC, S3) using human-readable code (.tf files) instead of manual console clicks.

⦁	Language: It uses HCL (HashiCorp Configuration Language), which is simple, declarative, and similar to JSON.

⦁	Key Workflow: The standard workflow involves terraform init (initialize), terraform plan (preview changes), and terraform apply (create/update resources).

⦁	Benefits: It enables consistency, automation, version control for your infrastructure, and the ability to easily create/destroy environments to save costs.

---

## Day 3: Create an AWS S3 Bucket Using Terraform
**Date:** 2025-11-26  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 3 - Create an AWS S3 Bucket Using Terraform](https://medium.com/@gokulkumargn/day-3-30-my-first-resource-s3-bucket-️-717d830e39da)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/gokulprasath-n_30daysofawsterraform-aws-terraform-activity-7399473371580854272-sQK5?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADpuYVMBDniXo9yNNR3dTMoe7XPh7tZCvYI)
- **Code Repository:** [GitHub](https://github.com/Gokulprasath-N/Terraform-Full-Course-Aws/tree/main/lessons/day03)
- **Issue:** [#113](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/113)

### 🎯 Key Learnings

Terraform Workflow in Action
terraform init: Initializes the directory, downloading the AWS provider plugin.

terraform plan: Checks your code against the current state. It will show that it plans to add 1 resource (the S3 bucket).

terraform apply: Executes the plan.

It will prompt you to type yes to confirm.

Tip: You can use -auto-approve to skip the manual confirmation prompt (terraform apply -auto-approve).

Verification: You can go to the AWS Console (S3 section) to verify that the bucket has been created with the correct name and tags.

Modifying and Destroying Resources
Making Changes: If you change the code (e.g., update a tag value from Dev to Prod) and run terraform apply again, Terraform detects the difference.

It will show 1 to change in the plan, meaning it will update the existing resource in place without deleting it (unless the change forces a replacement).

Destroying: To remove the resource, run terraform destroy.

This will delete the bucket from AWS.

Like apply, it requires a confirmation prompt (or -auto-approve).

---

## Day 2: AWS Provider 
**Date:** 2025-11-25  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 2 - AWS Provider ](https://medium.com/@gokulkumargn/day-2-30-mastering-terraform-providers-version-constraints-%EF%B8%8F-06c2794ebc62?postPublishedType=initial)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/gokulprasath-n_30daysofawsterraform-aws-terraform-activity-7399094170549682177-5wJw?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADpuYVMBDniXo9yNNR3dTMoe7XPh7tZCvYI)
- **Code Repository:** [GitHub](https://github.com/Gokulprasath-N/Terraform-Full-Course-Aws/tree/main/lessons/day02)
- **Issue:** [#65](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/65)

### 🎯 Key Learnings


---

## Day 7: Type Constraints
**Date:** 2025-11-30  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 7 - Type Constraints](https://medium.com/@gokulkumargn/day-7-30-mastering-terraform-variable-types-constraints-%EF%B8%8F-641338b97718?postPublishedType=initial)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/gokulprasath-n_day-730-mastering-terraform-variable-types-activity-7400960272246636544-YEoj?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADpuYVMBDniXo9yNNR3dTMoe7XPh7tZCvYI)
- **Code Repository:** [GitHub](https://github.com/Gokulprasath-N/Terraform-Full-Course-Aws/tree/main/lessons/day07/my%20task)
- **Issue:** [#290](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/290)

### 🎯 Key Learnings


---

## Day 5: Terraform Variables
**Date:** 2025-11-29  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 5 - Terraform Variables](https://dev.to/gokulprasath_n_42438fd633/day-530-the-power-of-variables-dry-principles-precedence-50ph)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/gokulprasath-n_day-530-the-power-of-variables-dry-principles-activity-7400209259155611648-bz51?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADpuYVMBDniXo9yNNR3dTMoe7XPh7tZCvYI)
- **Code Repository:** [GitHub](_Noresponse_)
- **Issue:** [#229](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/229)

### 🎯 Key Learnings


---

## Day 4: Terraform State file management
**Date:** 2025-11-27  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 4 - Terraform State file management](https://medium.com/@gokulkumargn/day-4-30-the-heart-of-terraform-state-files-remote-backends-%EF%B8%8F-2842360d7085)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/gokulprasath-n_30daysofawsterraform-aws-terraform-activity-7399879505785503745-Jabh?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADpuYVMBDniXo9yNNR3dTMoe7XPh7tZCvYI)
- **Code Repository:** [GitHub](https://github.com/Gokulprasath-N/Terraform-Full-Course-Aws/tree/main/lessons/day04)
- **Issue:** [#184](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/184)

### 🎯 Key Learnings


---

