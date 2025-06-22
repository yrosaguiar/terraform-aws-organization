provider "aws" {
  region = "us-east-1"
}

module "organization" {
  source = "../../"

  # Uncomment and set this if you already have an AWS Organization
  # existing_organization_id = "r-xxxx"

  # You can add more OUs here, such as "security", "networking", "platform", etc.
  organizational_units = {
    workloads      = "Workloads"
    infrastructure = "Infrastructure"
    # security     = "Security"
    # networking   = "Networking"
    # platform     = "Platform"
  }

  accounts = {
    development = {
      email      = "youremailgroup+awsdev@example.com"
      name       = "Development"
      parent_key = "workloads"
    }

    staging = {
      email      = "youremailgroup+awsstaging@example.com"
      name       = "Staging"
      parent_key = "workloads"
    }

    production = {
      email      = "youremailgroup+awsproduction@example.com"
      name       = "Production"
      parent_key = "workloads"
    }

    shared = {
      email      = "youremailgroup+awsshared@example.com"
      name       = "Shared"
      parent_key = "infrastructure"
    }
  }

  tags = {
    ManagedBy   = "Terraform"
    Environment = "OrgSetup"
  }

  aws_service_access_principals = [
    "sso.amazonaws.com",
    "health.amazonaws.com"
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]

  feature_set = "ALL"
}
