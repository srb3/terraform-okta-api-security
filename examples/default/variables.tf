variable "api_token" {
  type = string
}

variable "org_name" {
  type = string
}

variable "users" {
  description = "A map of objects to create users"
  type = map(object({
    first_name = string
    last_name  = string
    email      = string
    password   = string
    workspaces = list(string)
    groups     = list(string)
    apps       = list(string)
  }))
  default = {}
}
