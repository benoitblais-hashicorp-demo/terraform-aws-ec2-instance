locals {
  create = var.create && var.putin_khuylo
  tags   = merge(var.tags, { terraform-aws-modules = "ec2-instance" })

  is_t_instance_type = replace(var.instance_type, "/^t(2|3|3a|4g){1}\\..*$/", "1") == "1" ? true : false

  # OS credentials handling
  default_os_users = {
    linuxadmin = null
  }
  configured_os_users = length(var.os_credentials) > 0 ? var.os_credentials : local.default_os_users

  # Determine secret name
  secret_name = coalesce(var.secret_name, "demo/linux/${var.name}")

  # Build the final map of username => password
  final_os_credentials = {
    for user, pass in local.configured_os_users : user => (
      pass != null ? pass : try(random_password.os_password[user].result, null)
    )
  }
}

################################################################################
# Secrets Manager & Random Passwords (Optional)
################################################################################

resource "random_password" "os_password" {
  for_each = {
    for user, pass in local.configured_os_users : user => pass
    if local.create && var.create_os_credentials_secret && pass == null
  }

  length           = 32
  special          = true
  override_special = "-_"
}

resource "aws_secretsmanager_secret" "os_credentials" {
  count = local.create && var.create_os_credentials_secret ? 1 : 0

  name                    = local.secret_name
  description             = var.secret_description
  recovery_window_in_days = var.secret_recovery_window_in_days

  tags = merge(local.tags, var.secret_tags)
}

resource "aws_secretsmanager_secret_version" "os_credentials" {
  count = local.create && var.create_os_credentials_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.os_credentials[0].id
  secret_string = jsonencode(local.final_os_credentials)
}

################################################################################
# EC2 Instance
################################################################################

resource "aws_instance" "this" {
  count = local.create ? 1 : 0

  ami           = var.ami
  instance_type = var.instance_type

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  key_name             = var.key_name
  monitoring           = var.monitoring
  iam_instance_profile = var.iam_instance_profile

  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip

  ebs_optimized = var.ebs_optimized

  dynamic "root_block_device" {
    for_each = var.root_block_device

    content {
      delete_on_termination = try(root_block_device.value.delete_on_termination, null)
      encrypted             = try(root_block_device.value.encrypted, null)
      iops                  = try(root_block_device.value.iops, null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = try(root_block_device.value.volume_size, null)
      volume_type           = try(root_block_device.value.volume_type, null)
      throughput            = try(root_block_device.value.throughput, null)
      tags                  = try(root_block_device.value.tags, null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device

    content {
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = try(ebs_block_device.value.encrypted, null)
      iops                  = try(ebs_block_device.value.iops, null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = try(ebs_block_device.value.volume_size, null)
      volume_type           = try(ebs_block_device.value.volume_type, null)
      throughput            = try(ebs_block_device.value.throughput, null)
      tags                  = try(ebs_block_device.value.tags, null)
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, "enabled")
      http_tokens                 = try(metadata_options.value.http_tokens, "optional")
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, 1)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }

  source_dest_check                    = var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  tenancy                              = var.tenancy

  credit_specification {
    cpu_credits = local.is_t_instance_type ? var.cpu_credits : null
  }

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  tags        = merge({ "Name" = var.name }, var.instance_tags, local.tags)
  volume_tags = var.enable_volume_tags ? merge({ "Name" = var.name }, var.volume_tags) : null
}
