# This local variable determines the root ID of the AWS Organization.
# If an existing organization ID is provided, it uses that; otherwise, it retrieves the root
locals {
  root_id = var.existing_organization_id != null ? var.existing_organization_id : try(aws_organizations_organization.org[0].roots[0].id, null)
}


# This local variable processes the organizational units and accounts to create a mapping of organizational unit IDs.
# It also processes the accounts to include their email, name, and parent organizational unit ID.
locals {
  organizational_units_map = merge(
    { root = local.root_id },
    { for key, ou in aws_organizations_organizational_unit.this : key => ou.id }
  )

  processed_accounts = {
    for key, account in var.accounts :
    key => {
      email     = account.email
      name      = account.name
      parent_id = local.organizational_units_map[account.parent_key]
    }
    if !(key == "root" && var.existing_organization_id != null)
  }
}


# This local variable defines common tags to be applied to each account created in the AWS Organization.
# It merges the provided tags with additional tags for tracking the creator and module.
locals {
  tags = merge(
    var.tags,
    {
      "CreatedBy" = "Terraform"
      "Module"    = "aws-foundation-organizations"
    }
  )
}


# This module creates AWS Organizations accounts based on a provided list of accounts. 
resource "aws_organizations_account" "this" {
  for_each = local.processed_accounts 

  email     = each.value.email
  name      = each.value.name
  parent_id = each.value.parent_id
  tags      = local.tags
  tags_all  = {}

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [role_name, name, email]
  }

  depends_on = [
    aws_organizations_organizational_unit.this
  ]
}

# This data source retrieves the existing AWS Organization if an organization ID is provided.
# If no organization ID is provided, it will not create a new organization.
data "aws_organizations_organization" "org" {
  count = var.existing_organization_id == null ? 0 : 1
}


# This resource creates a new AWS Organization if one does not already exist.
resource "aws_organizations_organization" "org" {
  count = var.existing_organization_id == null ? 1 : 0

  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = var.enabled_policy_types
  feature_set                   = var.feature_set
}

# This resource creates Organizational Units (OUs) in the AWS Organization based on the provided organizational units.
# It uses the root ID from the existing organization or the newly created organization.
resource "aws_organizations_organizational_unit" "this" {
  for_each = var.organizational_units

  name      = each.value
  parent_id = local.root_id != null ? local.root_id : "INVALID_ID_SHOULD_FAIL"
}




# This output provides a summary of the accounts created in the AWS Organization.
output "accounts_summary" {
  description = "Summary of the accounts and their corresponding Organizational Units"

  value = {
    for key, account in var.accounts :
    key => {
      name         = account.name
      email        = account.email
      parent_key   = account.parent_key
      parent_ou_id = local.organizational_units_map[account.parent_key]
    }
    if !(key == "root" && var.existing_organization_id != null)
  }
}

# This output provides the IDs of the Organizational Units created in the AWS Organization.
output "organizational_units" {
  description = "Organizational Units created in the AWS Organization"

  value = {
    for key, ou in aws_organizations_organizational_unit.this :
    key => ou.id
  }
}

# This output provides the ID of the AWS Organization, either from an existing organization or a newly created one
output "organization_id" {
  description = "ID of the AWS Organization"

  value = var.existing_organization_id != null ? var.existing_organization_id : aws_organizations_organization.org[0].id
}

# This output provides the root ID of the AWS Organization, which is either from an existing organization or a newly created one.
output "root_id" {
  description = "Root ID of the AWS Organization"

  value = local.root_id
}