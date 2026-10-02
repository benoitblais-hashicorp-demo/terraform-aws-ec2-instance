<!-- BEGIN_TF_DOCS -->
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

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 5.62)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

## Modules

No modules.

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_ami"></a> [ami](#input\_ami)

Description: ID of AMI to use for the instance

Type: `string`

Default: `null`

### <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address)

Description: Whether to associate a public IP address with an instance in a VPC

Type: `bool`

Default: `null`

### <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone)

Description: AZ to start the instance in

Type: `string`

Default: `null`

### <a name="input_cpu_credits"></a> [cpu\_credits](#input\_cpu\_credits)

Description: The credit option for CPU usage (unlimited or standard)

Type: `string`

Default: `null`

### <a name="input_create"></a> [create](#input\_create)

Description: Whether to create an instance

Type: `bool`

Default: `true`

### <a name="input_create_os_credentials_secret"></a> [create\_os\_credentials\_secret](#input\_create\_os\_credentials\_secret)

Description: Controls whether to generate random passwords for OS user accounts and store them in AWS Secrets Manager.

Type: `bool`

Default: `false`

### <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination)

Description: If true, enables EC2 Instance Termination Protection

Type: `bool`

Default: `null`

### <a name="input_ebs_block_device"></a> [ebs\_block\_device](#input\_ebs\_block\_device)

Description: Additional EBS block devices to attach to the instance

Type: `list(any)`

Default: `[]`

### <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized)

Description: If true, the launched EC2 instance will be EBS-optimized

Type: `bool`

Default: `null`

### <a name="input_enable_volume_tags"></a> [enable\_volume\_tags](#input\_enable\_volume\_tags)

Description: Whether to enable volume tags (if enabled it conflicts with root\_block\_device tags)

Type: `bool`

Default: `true`

### <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile)

Description: IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile

Type: `string`

Default: `null`

### <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior)

Description: Shutdown behavior for the instance. Available values: stop, terminate

Type: `string`

Default: `null`

### <a name="input_instance_tags"></a> [instance\_tags](#input\_instance\_tags)

Description: Additional tags for the instance

Type: `map(string)`

Default: `{}`

### <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)

Description: The type of instance to start

Type: `string`

Default: `"t3.micro"`

### <a name="input_key_name"></a> [key\_name](#input\_key\_name)

Description: Key name of the Key Pair to use for the instance

Type: `string`

Default: `null`

### <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options)

Description: Customize the metadata options of the instance

Type: `map(string)`

Default:

```json
{
  "http_endpoint": "enabled",
  "http_put_response_hop_limit": 1,
  "http_tokens": "optional"
}
```

### <a name="input_monitoring"></a> [monitoring](#input\_monitoring)

Description: If true, the launched EC2 instance will have detailed monitoring enabled

Type: `bool`

Default: `null`

### <a name="input_name"></a> [name](#input\_name)

Description: Name to be used on EC2 instance created

Type: `string`

Default: `""`

### <a name="input_os_credentials"></a> [os\_credentials](#input\_os\_credentials)

Description: Map of user names to explicit passwords. If a username is mapped to null, a random password will be auto-generated.

Type: `map(string)`

Default: `{}`

### <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip)

Description: Private IP address to associate with the instance in a VPC

Type: `string`

Default: `null`

### <a name="input_putin_khuylo"></a> [putin\_khuylo](#input\_putin\_khuylo)

Description: Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!

Type: `bool`

Default: `true`

### <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device)

Description: Customize details about the root block device of the instance

Type: `list(any)`

Default: `[]`

### <a name="input_secret_description"></a> [secret\_description](#input\_secret\_description)

Description: Description for the Secrets Manager secret storing OS credentials.

Type: `string`

Default: `"Linux VM credentials managed by Terraform"`

### <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name)

Description: Name for the Secrets Manager secret storing OS credentials. Defaults to `demo/linux/<name>`.

Type: `string`

Default: `null`

### <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days)

Description: Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion).

Type: `number`

Default: `0`

### <a name="input_secret_tags"></a> [secret\_tags](#input\_secret\_tags)

Description: A map of tags to assign to the Secrets Manager secret.

Type: `map(string)`

Default: `{}`

### <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check)

Description: Controls if traffic is routed to the instance when the destination address does not match the instance

Type: `bool`

Default: `null`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The VPC Subnet ID to launch in

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource

Type: `map(string)`

Default: `{}`

### <a name="input_tenancy"></a> [tenancy](#input\_tenancy)

Description: The tenancy of the instance. Available values: default, dedicated, host

Type: `string`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: Define maximum timeout for creating, updating, and deleting EC2 instance resources

Type: `map(string)`

Default: `{}`

### <a name="input_user_data"></a> [user\_data](#input\_user\_data)

Description: The user data to provide when launching the instance

Type: `string`

Default: `null`

### <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64)

Description: Base64-encoded binary data to pass as user data

Type: `string`

Default: `null`

### <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change)

Description: Triggers a destroy and recreate when user\_data changes

Type: `bool`

Default: `null`

### <a name="input_volume_tags"></a> [volume\_tags](#input\_volume\_tags)

Description: A mapping of tags to assign to the devices created by the instance at launch time

Type: `map(string)`

Default: `{}`

### <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids)

Description: A list of security group IDs to associate with

Type: `list(string)`

Default: `null`

## Resources

The following resources are used by this module:

- [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) (resource)
- [aws_secretsmanager_secret.os_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) (resource)
- [aws_secretsmanager_secret_version.os_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) (resource)
- [random_password.os_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)

## Outputs

The following outputs are exported:

### <a name="output_ami"></a> [ami](#output\_ami)

Description: AMI ID that was used to create the instance

### <a name="output_arn"></a> [arn](#output\_arn)

Description: The ARN of the instance

### <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone)

Description: The availability zone of the created instance

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the instance

### <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state)

Description: The state of the instance

### <a name="output_os_credentials"></a> [os\_credentials](#output\_os\_credentials)

Description: Map of user names and passwords generated or configured for the instance

### <a name="output_os_credentials_secret_arn"></a> [os\_credentials\_secret\_arn](#output\_os\_credentials\_secret\_arn)

Description: The ARN of the Secrets Manager secret storing the OS user credentials

### <a name="output_os_credentials_secret_id"></a> [os\_credentials\_secret\_id](#output\_os\_credentials\_secret\_id)

Description: The ID of the Secrets Manager secret storing the OS user credentials

### <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id)

Description: The ID of the instance's primary network interface

### <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns)

Description: The private DNS name assigned to the instance

### <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip)

Description: The private IP address assigned to the instance

### <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns)

Description: The public DNS name assigned to the instance

### <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip)

Description: The public IP address assigned to the instance

### <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all)

Description: A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block

<!-- markdownlint-enable -->
## External Documentation

The following external documentation was used to develop this configuration:

* [AWS Provider — Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [AWS EC2 Instance — Terraform Resource: aws\_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
* [AWS Secrets Manager — Terraform Resource: aws\_secretsmanager\_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)
* [AWS EC2 IMDSv2 — Instance Metadata](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)
<!-- END_TF_DOCS -->