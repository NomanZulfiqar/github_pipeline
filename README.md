
# GitHub Pipeline for Terraform EC2 Deployment

This repository automates the deployment of an EC2 instance on AWS using Terraform and GitHub Actions. It follows an Infrastructure as Code (IaC) approach, enabling repeatable and version-controlled provisioning of cloud infrastructure.

## 🚀 Features

- **Terraform-based EC2 Deployment**
- **GitHub Actions CI/CD Pipelines** for:
  - Terraform Plan (`terraform-pr.yml`)
  - Terraform Apply (`terraform-apply.yml`)
- **Secure Credential Handling** using GitHub Secrets
- **Branch-based Workflow**:
  - `ec2` or feature branches for development
  - `main` branch for production-ready deployments

---

## 📁 Project Structure

```
github_pipeline/
│
├── backend.tf           # Remote backend configuration for Terraform state
├── ec2.tf               # EC2 instance definition and variables
├── local.tf             # Local variables and configurations
├── .gitignore           # Ignored files and folders
├── .terraform.lock.hcl  # Terraform dependency lock file
├── .github/
│   └── workflows/
│       ├── terraform-pr.yml     # Runs terraform plan on PRs
│       └── terraform-apply.yml  # Runs terraform apply on merge to main
```

---

## 🔐 GitHub Secrets Required

Make sure to set the following GitHub secrets in your repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

These secrets ensure secure access to your AWS account for provisioning resources.

---

## ✅ Usage Instructions

### 1. Clone the repository

```bash
git clone https://github.com/NomanZulfiqar/github_pipeline.git
cd github_pipeline
```

### 2. Initialize Terraform (Locally)

```bash
terraform init
```

### 3. Create a Feature Branch

```bash
git checkout -b ec2
# Make changes and push
git push origin ec2
```

### 4. Open Pull Request

GitHub will run the **Terraform Plan** pipeline (`terraform-pr.yml`) to preview changes.

### 5. Merge to `main` Branch

After review and approval, merge the PR to `main`. The **Terraform Apply** pipeline (`terraform-apply.yml`) will be triggered automatically.

---

## 🧠 Notes

- Force-push is restricted on `main` due to branch protection.
- Always pull the latest `main` changes before creating a new branch.
- Pipelines rely on OIDC or credentials configured in GitHub Secrets for AWS access.

---

## 📬 Contact

Created with 💻 by **Noman Zulfiqar**

