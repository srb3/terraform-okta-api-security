
resource "okta_auth_server" "this-auth-server" {
  audiences   = var.auth_server_audiences
  description = var.auth_server_description
  name        = var.auth_server_name
  issuer_mode = var.auth_server_issuer_mode
  status      = var.auth_server_status
}

########### Auth Server Policy ###################

resource "okta_auth_server_policy" "this-auth-server-policy" {
  for_each         = var.auth_server_policy
  auth_server_id   = okta_auth_server.this-auth-server.id
  status           = each.value.status
  name             = each.key
  description      = each.value.description
  priority         = each.value.priority
  client_whitelist = each.value.client_whitelist
  depends_on       = [okta_auth_server.this-auth-server]
}

########### Auth Server Policy Rule ##############

resource "okta_auth_server_policy_rule" "this-auth-server-policy-rule" {
  for_each                       = var.auth_server_policy_rule
  auth_server_id                 = okta_auth_server.this-auth-server.id
  policy_id                      = okta_auth_server_policy.this-auth-server-policy[each.value.policy_name].id
  status                         = each.value.status
  name                           = each.key
  priority                       = each.value.priority
  grant_type_whitelist           = each.value.grant_type_whitelist
  scope_whitelist                = each.value.scope_whitelist
  access_token_lifetime_minutes  = each.value.access_token_lifetime_minutes
  refresh_token_lifetime_minutes = each.value.refresh_token_lifetime_minutes
  group_whitelist                = each.value.group_whitelist
  depends_on                     = [okta_auth_server_policy.this-auth-server-policy]
}

########### Auth Server Scope ####################

resource "okta_auth_server_scope" "this-scope" {
  for_each         = var.auth_server_scopes
  auth_server_id   = okta_auth_server.this-auth-server.id
  metadata_publish = each.value.metadata_publish
  name             = each.key
  consent          = each.value.consent
  description      = each.value.description
  depends_on       = [okta_auth_server_policy_rule.this-auth-server-policy-rule]
}

########### Auth Server Claim Expression #########

resource "okta_auth_server_claim" "this-claim-expression" {
  for_each       = var.auth_server_claim_expression
  auth_server_id = okta_auth_server.this-auth-server.id
  name           = each.key
  value          = each.value.value
  claim_type     = each.value.claim_type
  #depends_on     = [okta_auth_server_scope.this-scope]
}

########### Auth Server Claim Group ##############

locals {
  scopes = { for k, v in var.auth_server_claim_group :
    k => [
      for x in var.auth_server_claim_group[k].scopes :
      x
    ]
  }
}

resource "okta_auth_server_claim" "groups" {
  for_each          = var.auth_server_claim_group
  auth_server_id    = okta_auth_server.this-auth-server.id
  name              = each.key
  value             = each.value.value
  value_type        = "GROUPS"
  group_filter_type = each.value.group_filter_type
  scopes            = local.scopes[each.key]
  claim_type        = "RESOURCE"
  depends_on        = [okta_auth_server_scope.this-scope]
}

########### App Oauth ############################

resource "okta_app_oauth" "this-oauth-app" {
  for_each                  = var.app_oauth
  label                     = each.key
  type                      = each.value.type
  grant_types               = each.value.grant_types
  redirect_uris             = each.value.redirect_uris
  login_uri                 = each.value.login_uri
  post_logout_redirect_uris = each.value.post_logout_redirect_uris
  consent_method            = each.value.consent_method
  response_types            = each.value.response_types
  #depends_on                = [okta_auth_server_claim.groups]
  lifecycle {
    ignore_changes = [groups]
  }
}

########### Users ################################

resource "okta_user" "this-user" {
  for_each   = var.users
  first_name = each.value.first_name
  last_name  = each.value.last_name
  login      = each.key
  email      = each.value.email
  password   = each.value.password
  #depends_on = [okta_app_oauth.this-oauth-app]
}

########### Groups ###############################

locals {
  groups = distinct(flatten([for k, v in var.users :
    [for x in v.groups :
      x
    ]
  ]))

  user_ids = flatten([for k, v in okta_user.this-user :
    [for x in var.users[k].groups :
      [for y in var.users[k].apps :
        "${v.id}~${okta_group.this-group[x].id}~${okta_app_oauth.this-oauth-app[y].id}"
      ]
    ]
  ])

}

resource "okta_group" "this-group" {
  for_each = { for x in local.groups : x => { "name" = x } }
  name     = each.key
  #  depends_on = [okta_user.this-user]
}

############ User + group assignment #############

resource "okta_group_membership" "test-group-membership" {
  count    = length(local.user_ids)
  user_id  = split("~", local.user_ids[count.index])[0]
  group_id = split("~", local.user_ids[count.index])[1]
  #  depends_on = [okta_user.this-user, okta_group.this-group]
}

############ Group + App assignment ##############

resource "okta_app_group_assignment" "kauto-app-test-admin" {
  count    = length(local.user_ids)
  group_id = split("~", local.user_ids[count.index])[1]
  app_id   = split("~", local.user_ids[count.index])[2]
  #depends_on = [okta_app_oauth.this-oauth-app, okta_group.this-group]
}

########### Output Helpers #######################

locals {
  app_auth = { for k, v in okta_app_oauth.this-oauth-app :
    k => { client_id = v.client_id, client_secret = v.client_secret }
  }
}
