# AWS EC2 Instance Terraform Module

Terraform module to provision an Amazon Web Services (AWS) EC2 instance with associated EBS block devices, IAM instance profile attachments, IMDSv2 metadata options, and optional automated OS credentials generation integrated with AWS Secrets Manager.

## Permissions

To provision the AWS resources managed by this module, the IAM role or user running Terraform needs permissions such as:

- `AmazonEC2FullAccess` (or fine-grained privileges to manage EC2 instances, key pairs, network interfaces, and EBS volumes).
- Additional permissions to describe subnets, VPCs, and Security Groups (e.g., `ec2:DescribeSubnets`, `ec2:DescribeVpcs`, `ec2:DescribeSecurityGroups`).
- Permissions to manage AWS Secrets Manager secrets if enabling automated OS credentials generation (`secretsmanager:CreateSecret`, `secretsmanager:PutSecretValue`, `secretsmanager:DeleteSecret`, `secretsmanager:DescribeSecret`, `secretsmanager:TagResource`).

## Authentications

Authentication to AWS can be configured using one of the following methods, with preference given to OIDC and dynamic provider credentials in CI/CD environments.

### HCP Terraform / Terraform Enterprise Dynamic Credentials (OIDC)

Use dynamic provider credentials via OpenID Connect (OIDC) for secure, short-lived credentials when running in HCP Terraform or Terraform Enterprise.

- **Using environment variables (HCP Terraform Workspace)**

  - `TFC_AWS_PROVIDER_AUTH=true`
  - `TFC_AWS_RUN_ROLE_ARN=<aws-iam-role-arn>`

### OIDC with GitHub Actions

When using GitHub Actions, configure OIDC via the `aws-actions/configure-aws-credentials` action.

- **Using GitHub Actions**

  ```yaml
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::111122223333:role/github-actions-role
      aws-region: us-east-1
  ```

### Static Access Keys

For local development or environments not supporting OIDC, use static IAM programmatic access keys.

- **Inside the provider block**

  ```hcl
  provider "aws" {
    region     = "us-east-1"
    access_key = "<aws-access-key-id>"
    secret_key = "<aws-secret-access-key>"
  }
  ```

- **Using environment variables**

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_DEFAULT_REGION` (optional)

Documentation:

- [AWS Provider Authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)
- [Dynamic Provider Credentials in HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration)

## Features

- Complete foundational AWS EC2 instance deployment.
- Support for root and EBS block devices with encryption and custom volume types.
- IMDSv2 support (enforce tokens and hop limit).
- Integration with AWS Secrets Manager for auto-generating and storing random local OS user passwords (e.g. `linuxadmin`).
- Support for detailed monitoring, CPU credits, termination protection, and custom user data.

## Usage example

### Example 1: Basic EC2 Instance

```hcl
module "ec2_instance" {
  source  = "app.terraform.io/benoitblais-hashicorp/ec2-instance/aws"
  version = "~> 0.0"

  name          = "my-instance"
  ami           = "ami-12345678"
  instance_type = "t3.small"
  subnet_id     = "subnet-12345678"

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
```

### Example 2: EC2 Instance with Automated OS Credentials in Secrets Manager

```hcl
module "ec2_instance" {
  source  = "app.terraform.io/benoitblais-hashicorp/ec2-instance/aws"
  version = "~> 0.0"

  name          = "web-static"
  ami           = "ami-12345678"
  instance_type = "t3.small"
  subnet_id     = "subnet-12345678"

  create_os_credentials_secret = true

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
```
