# yugandhar9786 - 30 Days Terraform & AWS Challenge

**Participant:** @yugandhar9786  
**Start Date:** 2025-11-26  
**Challenge Repository:** [terraform-aws-30days](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws)  
**Personal Practice Repo:** https://github.com/yugandhar9786/terraform/tree/main/day-3

## Progress Overview
- **Days Completed:** 2/30
- **Current Streak:** 2 days
- **Last Submission:** 2025-11-27

---

## Day 3: S3 bucket challange
**Date:** 2025-11-26  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 3 - S3 bucket challange](https://medium.com/@yugandharkanaparthi9/day-3-of-my-cloud-learning-journey-creating-an-s3-bucket-with-terraform-96debbe87175)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/yugandhar-kanaparthi2003_30daysofawsterraform-30daysofawsterraform-activity-7399436573894713347-BnFB?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD6KIywBckgZ8CEHrBGdDD9fLpbByEOPrn8)
- **Code Repository:** [GitHub](https://github.com/yugandhar9786/terraform/tree/main/day-3)
- **Issue:** [#107](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/107)

### 🎯 Key Learnings

Terraform needs proper AWS authentication (via aws configure, environment variables, IAM roles, etc.) before creating any resources.

S3 is a cloud storage service used for storing files, backups, datasets, and more in a secure and scalable way.

S3 bucket names must be globally unique, so no two people in the world can use the same name.

The Terraform workflow to create infrastructure is init → plan → apply → verify → destroy.

Always clean up unused resources (terraform destroy) to avoid unnecessary AWS costs.

---

## Day 4: State File Management - Remote Backend
**Date:** 2025-11-27  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 4 - State File Management - Remote Backend](https://medium.com/@yugandharkanaparthi9/day-4-terraform-state-management-remote-backend-with-s3-native-locking-no-dynamodb-needed-6f81c11e6961)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/yugandhar-kanaparthi2003_30daysofawsterraform-30daysofawsterraform-activity-7399764505162883072-c3od?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD6KIywBckgZ8CEHrBGdDD9fLpbByEOPrn8)
- **Code Repository:** [GitHub](https://github.com/yugandhar9786/terraform/tree/main/day-4)
- **Issue:** [#149](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/149)

### 🎯 Key Learnings

Terraform state is the single source of truth for infrastructure
Remote backend is mandatory for team environments
S3 Native Locking removes the need for DynamoDB in Terraform 1.10+
Easier, cheaper, and more secure than before

---

