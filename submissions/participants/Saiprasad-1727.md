# Saiprasad-1727 - 30 Days Terraform & AWS Challenge

**Participant:** @Saiprasad-1727  
**Start Date:** 2025-11-25  
**Challenge Repository:** [terraform-aws-30days](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws)  
**Personal Practice Repo:** https://github.com/Saiprasad-1727/30-DAYS-OF-Terraform/blob/main/DAY-02/DAY-02-Providerd.md

## Progress Overview
- **Days Completed:** 2/30
- **Current Streak:** 1 day
- **Last Submission:** 2025-11-27

---

## Day 2: Understanding terraform providers and versioning
**Date:** 2025-11-25  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 2 - Understanding terraform providers and versioning]()

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/posts/saiprasad-annam_30daysofawsterraform-activity-7399048169923325952-rntI?utm_source=social_share_send&utm_medium=android_app&rcm=ACoAAChoEAoBkIo2wehBR8kDv3DVqnQ29h7OqvI&utm_campaign=copy_link)
- **Code Repository:** [GitHub](https://github.com/Saiprasad-1727/30-DAYS-OF-Terraform/blob/main/DAY-02/DAY-02-Providerd.md)
- **Issue:** [#54](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/54)

### 🎯 Key Learnings

Today I have learned

Terraform providers help Terraform connect to AWS, Azure, GCP, and other platforms.

Terraform Core and provider versions are separate and updated independently.

Versioning is important to avoid errors, use new features, and keep deployments consistent.

Version constraints help control which provider version Terraform should use.

Common version constraints include exact version, greater/less than, patch-only updates, and version ranges.

Best practices:

⏭️ Always specify provider versions

⏭️ Use safe constraints (~>)

⏭️ Test upgrades before production

⏭️ Use and commit the lock file

⏭️ Document version requirements

---

## Day 4: Terraform State Files and Remote Backends
**Date:** 2025-11-27  
**Status:** ✅ Completed

### 📝 Blog Post
[Day 4 - Terraform State Files and Remote Backends](https://saiprasadannam.substack.com/p/infrastructure-as-code-iac-day-04)

### 🔗 Links
- **Social Media:** [Post](https://www.linkedin.com/feed/update/urn:li:activity:7399888055622393857/?originTrackingId=SkplmjVKA%2FHY%2BSf9SC19UQ%3D%3D)
- **Code Repository:** [GitHub](https://github.com/Saiprasad-1727/30-DAYS-OF-Terraform/tree/main/DAY-04)
- **Issue:** [#185](https://github.com/piyushsachdeva/Terraform-Full-Course-Aws/issues/185)

### 🎯 Key Learnings

Today i have learned that how 

• Terraform uses a state file to remember the resources it creates.
• It compares desired vs actual state to decide what to add or change.
• The state file contains sensitive data and must be stored safely.
• Using a remote backend (AWS S3) keeps it secure and enables team collaboration.
• State locking prevents conflicts and keeps Terraform operations reliable.

---

