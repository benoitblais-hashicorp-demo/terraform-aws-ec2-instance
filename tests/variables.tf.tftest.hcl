mock_provider "aws" {}
mock_provider "random" {}

variables {
  name      = "test-instance"
  ami       = "ami-12345678"
  subnet_id = "subnet-12345678"
}

run "validate_default_creation" {
  command = plan

  assert {
    condition     = length(aws_instance.this) == 1
    error_message = "EC2 instance was not planned for creation"
  }

  assert {
    condition     = length(aws_secretsmanager_secret.os_credentials) == 0
    error_message = "Secrets Manager secret should not be created by default"
  }
}

run "validate_os_credentials_secret_creation" {
  command = plan

  variables {
    create_os_credentials_secret = true
  }

  assert {
    condition     = length(aws_secretsmanager_secret.os_credentials) == 1
    error_message = "Secrets Manager secret should be planned for creation"
  }

  assert {
    condition     = aws_secretsmanager_secret.os_credentials[0].name == "demo/linux/test-instance"
    error_message = "Secret name does not match expected default format"
  }
}
