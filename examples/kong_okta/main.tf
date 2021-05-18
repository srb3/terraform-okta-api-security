provider "okta" {
  org_name  = "dev-48174301"
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
  }

  auth_server_claim_group = {
    "groups" = {
      value             = ".*"
      claim_type        = "RESOURCE"
      group_filter_type = "REGEX"
      scopes            = ["groups"]
    }
  }

  app_oauth = {
    "tf-app" = {
      type = "web"
      grant_types = [
        "client_credentials",
        "authorization_code",
        "refresh_token",
        "implicit"
      ]
      redirect_uris             = ["https://gui.kongcx.ninja/"]
      login_uri                 = "https://gui.kongcx.ninja/"
      post_logout_redirect_uris = ["https://gui.kongcx.ninja/"]
      consent_method            = "REQUIRED"
      response_types            = ["token", "id_token", "code"]
    }
  }
  users = {
    "rs@mail.com" = {
      first_name = "Ringo"
      last_name  = "Star"
      email      = "rs@mail.com"
      password   = "zaq12wsx!"
      groups     = ["tf-admin-group"]
      apps       = ["tf-app"]
    }
    "zs@mail.com" = {
      first_name = "Ziggy"
      last_name  = "Stardust"
      email      = "zs@mail.com"
      password   = "zaq12wsx!"
      groups     = ["tf-read-only-group"]
      apps       = ["tf-app"]
    }
  }
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
  app_oauth                    = local.app_oauth
  users                        = local.users
}

output "okta-test" {
  value = module.okta-test
}
