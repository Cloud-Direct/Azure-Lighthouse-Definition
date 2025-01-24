variable "subscription_id" {
  description = "The subscription GUID."
  type        = string
  default     = null
}

variable "parms" {
  description = "The filepath to the Azure Resource Manager JSON parameters file. See examples for format."
  type        = string
}

variable "approvers" {
  description = "Groups for PIM elevation approvals."
  type = object({
    standard = object({
      name     = string
      objectId = string
    })
    contributor = object({
      name     = string
      objectId = string
    })
  })
  default = null
}

variable "lighthouse_admins" {
  description = "Group for Lighthouse administrators."
  type = object({
    name     = string
    objectId = string
  })
  default = null
}
