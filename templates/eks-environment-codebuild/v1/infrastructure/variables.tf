
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

# required by proton
variable "environment" {
  description = "The Proton Environment"
  type = object({
    name   = string
    inputs = map(string)
  })
  default = null
}