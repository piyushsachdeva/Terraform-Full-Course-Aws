# Day 26 of My 30 Days AWS Terraform Challenge: HCP Terraform Explained with Demo

**Completed on December 30, 2025** - I've just finished Day 26 of my 30 Days AWS Terraform challenge, and this was a game-changer.  

After 25 days of hands-on CLI-based Terraform, we finally moved to **HCP Terraform** (HashiCorp Cloud Platform). This isn't just another tool—it's the production-ready solution that fixes all the pain points of local Terraform workflows.   

## The Problems with CLI Terraform (What I Faced)

Before HCP, every Terraform project had these headaches:

1. **Login Credentials Everywhere** - Manual AWS/Azure logins with no secure storage unless I set environment variables locally.  
2. **Secrets Were a Nightmare** - Encoded but not encrypted. Needed third-party tools like HashiCorp Vault or AWS Secrets Manager.  
3. **No Built-in Automation** - Manual `terraform plan/apply`. No CI/CD unless I built GitHub Actions or pipelines separately.  
4. **Custom Modules Stuck Locally** - No registry to share modules.  
5. **Environment Duplication** - Copied code for dev/test/prod. Wasteful and error-prone.  

---

## What HCP Terraform Solves (The Complete Package)

HCP is **GUI-based** with a free tier. Here's what it gives you out-of-the-box:

- **Git Integration** - Connects directly to GitHub/GitLab. Pulls latest code automatically.  
- **Built-in Workspaces & Projects** - Organize everything logically.  
- **Variable Storage** - Store credentials, secrets, and tfvars. No more tfvars files.  
- **Remote State** - No backend.tf needed. State managed in cloud.  
- **Private Module Registry** - Push and reuse custom modules.  
- **Full Pipeline View** - Runs, logs, history—all visible.  

---

## HCP Hierarchy (How It Organizes Everything)

```
Organization (Root)
├── Projects (AWS, Azure, GCP or by app)
    └── Workspaces (dev/test/prod or by feature)
```

**Real Example**: For a bank, Organization = Bank → Projects = Commercial Banking, Personal Banking → Workspaces = dev/test/prod per project.   

**Workspace** = Collection of.tf files for one infrastructure piece (like Day 3 S3 bucket or Day 14 static website).   

---

## 3 Workflow Types (Pick Your Style)

1. **Version Control** - GitHub integration. Auto-triggers on commits. Best for teams.   
2. **CLI-Driven** - Run local `terraform` commands, see results in GUI. Familiar workflow.   
3. **API-Driven** - Trigger via API calls from custom pipelines.  

---

## My Hands-On Demo (Step-by-Step)

### Step 1: Account Setup
- Go to `app.terraform.io`
- Create account → Verify email → Create **Organization** (personal/business).   

### Step 2: Create Project & Workspace (Version Control)
- New Project: "test"
- New Workspace → GitHub → Select repo (my Day 3 S3 bucket) → Set working directory "lessons/day03"   
- **Key Settings**:
  | Setting | What I Did |
  |---------|------------|
  | Auto-apply | OFF (for safety)  
  | Trigger | Files in day03/*.tf   |

**First Run Failed** - No AWS credentials. Fixed by adding **Environment Variables**:
```
AWS_ACCESS_KEY_ID = (sensitive)
AWS_SECRET_ACCESS_KEY = (sensitive)
```
   

**Result**: S3 bucket created. State stored automatically.  

### Step 3: Test Auto-Trigger
- Edit GitHub main.tf → Add second bucket → Commit
- **Auto-detected** → Planned → Manual approval → Applied   

**Delete Test**: Removed bucket → Auto-triggered → Planned → Manual approval → Destroyed. Perfect safety net.  

### Step 4: CLI-Driven Workspace
- New Workspace → CLI-driven
- `terraform login` → Generate token → Add to local   
- Update main.tf:
```hcl
terraform {
  cloud {
    organization = "tech-tutorials-with-puj-2"
    workspaces {
      name = "tf-cli-project-test"
    }
  }
}
```
- **Remove backend.tf** (conflicts with cloud)  
- Upgrade Terraform to 1.4.3   
- `terraform init/plan` → Runs in GUI  

**Same credentials issue** → Added to this workspace too. **3 resources planned** (VPC, EC2, S3).   

---

## Key Takeaways (Why This Changes Everything)

1. **No More Local State Hell** - Remote state with locking built-in.  
2. **Manual Approval for Prod** - Critical safety for live environments.  
3. **Three Workflows** - Git for teams, CLI for solo, API for automation.   
4. **Real Organizational Structure** - Scales from personal projects to enterprise.   
5. **Interview Gold** - "CLI vs HCP Terraform" is a common question.  

**Day 26 Proves**: Terraform CLI = learning tool. **HCP Terraform = production reality**.


