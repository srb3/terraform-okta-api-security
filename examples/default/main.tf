provider "okta" {
  org_name  = var.org_name
  base_url  = "okta.com"
  api_token = var.api_token
}

locals {
  auth_server_policy = {
    "default" = {
      status           = "ACTIVE"
      description      = "The default policy"
      priority         = 1
      client_whitelist = ["ALL_CLIENTS"]
    }
  }

  auth_server_policy_rule = {
    "allow_allow" = {
      policy_name = "default"
      status      = "ACTIVE"
      priority    = 1
      grant_type_whitelist = [
        "client_credentials",
        "authorization_code",
        "implicit",
        "password"
      ]
      scope_whitelist                = ["*"]
      access_token_lifetime_minutes  = 60
      refresh_token_lifetime_minutes = 10080
      group_whitelist                = ["EVERYONE"]
    }
  }
  auth_server_scopes = {
    "groups" = {
      metadata_publish = "NO_CLIENTS"
      consent          = "IMPLICIT"
      description      = "Allows the requesting of a users groups"
    }
  }
  auth_server_claim_expression = {
    "email" = {
      value      = "user.email"
      claim_type = "RESOURCE"
    }
    "employeeNumber" = {
      value      = "user.employeeNumber"
      claim_type = "RESOURCE"
    }
    "application_id" = {
      value      = "app.clientId"
      claim_type = "RESOURCE"
    }

  }

  auth_server_claim_group = {
    "groups" = {
      value             = ".*"
      claim_type        = "RESOURCE"
      group_filter_type = "REGEX"
      scopes            = ["groups"]
    }
  }

  oauth_apps = {
    "proxy-app" = {
      type = "web"
      grant_types = [
        "client_credentials",
        "authorization_code",
        "implicit",
        "refresh_token"
      ]
      redirect_uris = [
        "http://swagger-petstore-6m6cdn.kongcx.ninja/*"
      ]
      login_uri                 = "http://swagger-petstore-6m6cdn.kongcx.ninja/"
      post_logout_redirect_uris = ["http://swagger-petstore-6m6cdn.kongcx.ninja/"]
      consent_method            = "REQUIRED"
      response_types            = ["token", "id_token", "code"]
    }
  }

  users = var.users
}

########### Kong Auto ############################

module "okta-test" {
  source                       = "../../"
  auth_server_audiences        = ["api://test"]
  auth_server_description      = "Terraform generated auth server"
  auth_server_name             = "terraform-test"
  auth_server_issuer_mode      = "ORG_URL"
  auth_server_status           = "ACTIVE"
  auth_server_policy           = local.auth_server_policy
  auth_server_policy_rule      = local.auth_server_policy_rule
  auth_server_scopes           = local.auth_server_scopes
  auth_server_claim_expression = local.auth_server_claim_expression
  auth_server_claim_group      = local.auth_server_claim_group
  oauth_apps                   = local.oauth_apps
  users                        = local.users
}

output "okta-test" {
  value = module.okta-test
}
