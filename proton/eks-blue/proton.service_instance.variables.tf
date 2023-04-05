/*
This file is no longer managed by AWS Proton. The associated resource has been deleted in Proton.
*/

variable "environment" {
  type = object({
    account_id = string
    name       = string
    outputs    = map(string)
  })
  default = null
}

variable "service" {
  type = object({
    name                      = string
    branch_name               = string
    repository_connection_arn = string
    repository_id             = string
  })
}

variable "service_instance" {
  type = object({
    name       = string
    inputs     = any
    components = map(any)
  })
  default = null
}

variable "proton_tags" {
  type    = map(string)
  default = null
}
