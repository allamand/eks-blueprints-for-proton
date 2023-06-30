variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "environment" {
  description = "proton environment"
  type = object({
    name       = string
    account_id = string
    outputs    = map(string)
  })
}

#We don't uses the service name for now, only the service_instance name
# variable "service" {
#   description = "proton service"
#   type = object({
#     name                      = string
#     repository_id             = string
#     repository_connection_arn = string
#     branch_name               = string
#   })
# }

variable "service_instance" {
  description = "proton service instance"
  type = object({
    name   = string
    inputs = map(string)
  })
}

