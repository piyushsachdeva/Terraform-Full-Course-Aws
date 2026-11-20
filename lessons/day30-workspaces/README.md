# Day 30: Terraform Workspaces and Modules

This is a separate, workspace-based version of the Day 30 application infrastructure. The existing `lessons/day30` project is unchanged.

## The environment model

There is no `environment` Terraform variable to remember:

- Select the Terraform workspace `dev` to deploy development.
- Select the Terraform workspace `prod` to deploy production.
- The root configuration reads `terraform.workspace` and uses it for resource names and the `Environment` tag.
- The S3 backend stores each workspace's state separately.
- Terraform blocks plans from the default workspace; only `dev` and `prod` are accepted.

Workspaces separate Terraform state; they do not create separate AWS accounts. This project prefixes named resources with `day30-dev` or `day30-prod` so both environments can coexist in one account and region. Keep production behind GitHub Environment approval rules.

Do not apply from the default workspace. Use only `dev` or `prod`.

## What it creates

- A VPC with public and private subnets, an Internet Gateway, and one NAT Gateway.
- An internet-facing Application Load Balancer.
- A private Auto Scaling Group running the Django Docker image.
- A private, encrypted, versioned S3 bucket for application data.
- A launch template that installs Docker and starts the container at EC2 boot.

Each environment creates a NAT Gateway and an ALB, which incur AWS charges while running. The dev workspace uses one small EC2 instance; prod uses two. Destroy environments when no longer needed.

## Local setup (PowerShell)

Prerequisites: Terraform 1.10+, AWS CLI credentials with permissions for the resources above, and an S3 bucket in `us-east-1` for Terraform state. Create the bucket before initializing Terraform; enable versioning and block public access. The bucket name must be globally unique.

From the repository root, set the bucket name and choose the workspace:

```powershell
$env:TF_STATE_BUCKET = "your-unique-terraform-state-bucket"
Set-Location lessons/day30-workspaces/terraform
terraform init -backend-config="bucket=$env:TF_STATE_BUCKET"
terraform workspace new dev
terraform workspace show
```

`workspace show` should print `dev`. The `workspace new` command is only for first-time setup. On later runs, switch with:

```powershell
terraform workspace select dev
terraform workspace show
```

Review and deploy:

```powershell
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

For production, create its workspace once with `terraform workspace new prod`; on later runs use `terraform workspace select prod`. Confirm the selection with `terraform workspace show` before planning. The workspace name is the environment; no `-var environment=...` flag is needed.

To remove dev, select it first, inspect the plan, and destroy only that workspace. Destroying also permanently empties and removes that workspace's S3 data bucket:

```powershell
terraform workspace select dev
terraform plan -destroy
terraform destroy
```

## GitHub Actions setup

Add these repository settings:

- Variable `TF_STATE_BUCKET`: the pre-created S3 state bucket name.
- Secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for an AWS identity with the needed permissions.
- GitHub Environments named `dev` and `prod`. Configure required reviewers on `prod` to gate production applies and destroys.

Workflows in `.github/workflows/`:

- `.github/workflows/day30-workspaces-infra.yml`: PRs run a plan; pushes to `dev` or `main` plan and apply to the matching workspace.
- `.github/workflows/day30-workspaces-drift.yml`: checks prod every 6 hours; manual runs allow choosing dev or prod. If drift is detected, it applies the Terraform plan to restore the declared configuration.
- `.github/workflows/day30-workspaces-destroy.yml`: manual only. Requires typing `DESTROY-dev` or `DESTROY-prod`, then destroys only the selected workspace. Production approval should also be enabled in the GitHub `prod` Environment.

The scheduled drift workflow runs from the repository's default branch, so it explicitly selects `prod`. A manual run can select either workspace.

The original Day 30 workflows remain available for `lessons/day30/code`. Their push/PR triggers are path-filtered so changes to this project do not deploy the legacy stack. The original `drift_detection.yml` schedule remains enabled for that legacy stack; disable its schedule in GitHub Actions if you no longer want it checking or applying changes to the old project.

## Module layout

```text
terraform/
  main.tf                 # Workspace-derived naming, tags, and module wiring
  backend.tf              # S3 backend with workspace-specific state keys
  modules/
    network/              # VPC, subnets, routes, Internet Gateway, NAT
    app/                  # Security groups, ALB, launch template, Auto Scaling
    storage/              # Private, encrypted, versioned S3 bucket
```
