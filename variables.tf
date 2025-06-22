
variable "existing_organization_id" {
  type        = string
  default     = null
  description = "If set, uses an existing AWS Organization (root ID). Otherwise, a new one will be created."
}

variable "organizational_units" {
  type        = map(string)
  description = "Map of Organizational Units (OUs) to create. Example: { 'workloads' = 'Workloads', 'infrastructure' = 'Infrastructure' }"
}

variable "accounts" {
  type = map(object({
    email      = string
    name       = string
    parent_key = string
  }))
  description = "Map of AWS accounts to create. Each must reference a parent OU or 'root'."
}

variable "aws_service_access_principals" {
  type = list(string)
  default = [
    "sso.amazonaws.com",
    "health.amazonaws.com",
    "tagpolicies.tag.amazonaws.com"
  ]
  description = "List of AWS service principals that can access the organization"
}

variable "enabled_policy_types" {
  type = list(string)
  default = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
  description = "List of policy types to enable in the organization"
}

variable "feature_set" {
  type        = string
  default     = "ALL"
  description = "Feature set for the organization. Valid values: 'ALL', 'CONSOLIDATED_BILLING'"
}


variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to each account."
}
