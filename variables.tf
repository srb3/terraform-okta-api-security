########### Auth Server ##########################

variable "auth_server_audiences" {
  description = "The recipients that the tokens are intended for. This becomes the aud claim in an access token"
  type        = list(string)
}

variable "auth_server_description" {
  description = "The description of the authorization server"
  type        = string
  default     = "Terraform provisioned auth server"
}

variable "auth_server_name" {
  description = "The name of the authorization server"
  type        = string
}

variable "auth_server_issuer_mode" {
  description = "Allows you to use a custom issuer URL"
  type        = string
  default     = "ORG_URL"
}

variable "auth_server_status" {
  description = "The status of the auth server"
  type        = string
  default     = "ACTIVE"
}

########### Auth Server Policy ###################

variable "auth_server_policy" {
  description = "A map of objects to create auth server policies"
  type = map(object({
    status           = string
    priority         = number
    description      = string
    client_whitelist = list(string)
  }))
  default = {}
}

########### Auth Server Policy Rule ##############

variable "auth_server_policy_rule" {
  description = "A map of objects to create auth server policy rules"
  type = map(object({
    policy_name                    = string
    status                         = string
    priority                       = number
    grant_type_whitelist           = list(string)
    scope_whitelist                = list(string)
    group_whitelist                = list(string)
    access_token_lifetime_minutes  = number
    refresh_token_lifetime_minutes = number
  }))
  default = {}
}

########### Auth Server Scope ####################

variable "auth_server_scopes" {
  description = "A map of objects to create auth server scopes"
  type = map(object({
    metadata_publish = string
    consent          = string
    description      = string
  }))
  default = {}
}

########### Auth Server Claim Expression #########

variable "auth_server_claim_expression" {
  description = "A map of object to configure an auth server claim"
  type = map(object({
    value      = string
    claim_type = string
  }))
  default = {}
}


########### Auth Server Claim Groups #############

variable "auth_server_claim_group" {
  description = "A map of object to configure an auth server claim based on groups"
  type = map(object({
    value             = string
    claim_type        = string
    group_filter_type = string
    scopes            = list(string)
  }))
  default = {}
}

########### App Oauth ############################

variable "app_oauth" {
  description = "A map of objects to configure an OIDC Application"
  type = map(object({
    type                      = string
    grant_types               = list(string)
    redirect_uris             = list(string)
    login_uri                 = string
    post_logout_redirect_uris = list(string)
    consent_method            = string
    response_types            = list(string)
  }))
  default = {}
}

########### Users ################################

variable "users" {
  description = "A map of objects to create users"
  type = map(object({
    first_name = string
    last_name  = string
    email      = string
    password   = string
    groups     = list(string)
    apps       = list(string)
  }))
  default = {}
}
