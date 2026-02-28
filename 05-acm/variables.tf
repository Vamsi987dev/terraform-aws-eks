variable "project_name" {
  default = "expense"
  type    = string
}
variable "environment" {
  default = "dev"
  type    = string
}

variable "common_tags" {
  default = {
    Project     = "Expense"
    Environment = "Dev"
    Terraform   = "True"
  }
}

variable "zone_name" {
  default = "daws81s.icu"
  type    = string
}

variable "zone_id" {
    default = "Z07106382R8OPNWZHVRIY"
}