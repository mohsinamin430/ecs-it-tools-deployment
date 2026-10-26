# ECS IT-Tools App Deployment

## Overview

This project deploys the IT-Tools application on Amazon ECS Fargate using Terraform. The infrastructure is provisioned using Infrastructure as Code and the deployment process is automated through GitHub Actions. The project demonstrates cloud networking, container deployment, CI/CD, and AWS security best practices.

---

## Architecture Diagram

![Architecture](images/architecture.png)

---

## Repository Structure

```text
IT-Tools/
├── .dockerignore
├── .gitignore
├── Dockerfile
├── README.md
├── .github/
│   └── workflows/
│       ├── docker-build.yml
│       ├── healthcheck.yml
│       ├── terraform-deploy.yml
│       └── terraform-destroy.yml
├── app/
├── bootstrap/
│   ├── main.tf
│   ├── provider.tf
│   └── variables.tf
├── images/
└── infra/
    ├── environments/
    │   ├── dev/
    │   │   ├── main.tf
    │   │   ├── provider.tf
    │   │   └── variables.tf
    │   ├── prod/
    │   │   ├── main.tf
    │   │   ├── provider.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   └── staging/
    │       ├── main.tf
    │       ├── provider.tf
    │       └── variables.tf
    └── modules/
        ├── acm/
        ├── alb/
        ├── auto-scaling/
        ├── ecs/
        └── vpc/
```
---

## Prerequisites

Before deploying the project, ensure you have:

- An AWS account
- Terraform installed
- Docker installed
- AWS CLI configured
- A registered domain managed by Route 53
- Git installed


---
## Local Application Setup

Use Node.js 20 and pnpm:

```bash
npm install --global pnpm@9.11.0
cd app
pnpm install --frozen-lockfile
pnpm dev --host 0.0.0.0
```

Open http://localhost:5173. For a production build, run `pnpm build` inside `app/`; Vite writes the site to `app/dist/`.

## Dockerfile

From the repository root:

```bash
docker build -t it-tools .
docker run --rm -p 8080:8080 it-tools
```

Open http://localhost:8080; http://localhost:8080/health returns `{"status":"ok"}`.

The multi-stage build installs the pinned pnpm version, builds IT-Tools, and serves `dist/` with non-root Nginx on port 8080. The local Nginx configuration preserves the existing ECS and ALB health checks and supports client-side routing. AWS resource names retain their existing `threatapp` names so the application swap does not recreate infrastructure.

Pushing these changes to `main` triggers the existing build, ECR push, and ECS deployment workflow. You can also trigger that workflow manually.

## Infrastructure Components

### Networking

- VPC spanning two Availability Zones
- Public and private subnets
- Internet Gateway for public internet access
- Regional NAT Gateway for outbound internet access from private subnets

### Compute

- ECS Cluster running on Fargate
- ECS Service to maintain the desired task count
- Task Definition containing the application container

### Traffic Management

- Application Load Balancer
- Target Group for ECS tasks
- HTTP to HTTPS redirection
- ACM certificate for TLS encryption

### DNS

- Route 53 hosted zone
- Custom domain pointing to the Application Load Balancer

---

## Technologies Used

### Application

- IT-Tools (Vue, Vite, and pnpm)

### Infrastructure

- AWS
- Terraform
- Amazon ECS Fargate
- Amazon VPC
- Application Load Balancer
- Amazon ECR
- Route 53
- AWS Certificate Manager

### CI/CD

- GitHub Actions
- GitHub OIDC
- Terraform CLI

### Security

- Checkov
- Trivy
- TFLint

---

## Infrastructure Setup

### Bootstrap

The bootstrap configuration creates the shared infrastructure required for Terraform.

- S3 bucket for remote state & locking
- Amazon ECR repository for container images

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

### Deploy Infrastructure

Deploy the application infrastructure using Terraform. (Ensure bootstrap infra has been deployed first)

```bash
cd infra
terraform init
terraform plan 
terraform apply
```

---

## CI/CD Pipeline

### Build Workflow

The build workflow runs when application code is pushed.

It performs the following steps:

- Build the Docker image
- Scan the image with Trivy
- Push the image to Amazon ECR

### Deployment Workflow

The deployment workflow authenticates using GitHub OIDC and deploys the latest infrastructure changes.

The workflow:

- Assumes an AWS IAM role
- Runs Terraform plan
- Applies infrastructure changes
- Updates the ECS service
- Performs a health check after deployment

---

## AWS Infrastructure Details

### Networking

The application is deployed inside a VPC spanning two Availability Zones.

Public subnets host the Application Load Balancer while ECS tasks run inside private subnets. A regional NAT Gateway provides outbound internet access for the containers.

### Container Platform

The application runs as an ECS Fargate service.

Container images are stored in Amazon ECR and are updated automatically during deployment.

### Load Balancing

An internet facing Application Load Balancer distributes incoming traffic across ECS tasks.

HTTP requests are redirected to HTTPS using an ACM certificate.

### Domain

Route 53 manages DNS records for the application.

The custom domain resolves directly to the Application Load Balancer.

---

## Security

### Identity and Access Management

- GitHub OIDC for passwordless authentication
- Least privilege IAM roles
- ECS task execution role

### Container Security

- Trivy image scanning
- Private Amazon ECR repository

### Infrastructure Security

- Checkov Terraform scanning
- TFLint validation
- Security Groups controlling network access

---

## Challenges

Some challenges encountered during development included:
- Building Docker images with non root users in runner stage. Required nginxinc/nginx-unprivileged image
- ECS image pull failures from ECR. This was due to the default tag was set to "latest" in terraform variables. Resolved by passing github ref through workflow
- ACM certificate DNS validation

---

## Design Decisions

Key design choices include:

- ECS Fargate to avoid managing EC2 instances
- Terraform for repeatable infrastructure deployments
- GitHub Actions for automated CI/CD
- ALB for HTTPS termination and traffic routing
- Private subnets to improve application security

---

## Lessons Learned

This project improved my understanding of:

- Terraform modules
- AWS networking
- ECS Fargate deployments
- CI/CD with GitHub Actions
- IAM roles and GitHub OIDC
  
---

## Screenshots

### App Working
![App](images/app-running.png)

### Sucessful Workflows
![DockerBuild](images/build+push.png)
![terraform-deploy](images/terraform-deploy.png)
![healtcheck](images/healthcheck.png)

