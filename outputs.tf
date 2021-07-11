output "app_auth" {
  value = local.app_auth
}

data "http" "metadata" {
  url = "${okta_auth_server.this-auth-server.issuer}/.well-known/oauth-authorization-server"
  request_headers = {
    Accept = "application/json"
  }
}

output "metadata-url" {
  value = "${okta_auth_server.this-auth-server.issuer}/.well-known/oauth-authorization-server"
}

output "token_endpoint" {
  value = jsondecode(data.http.metadata.body).token_endpoint
}

output "revocation_endpoint" {
  value = jsondecode(data.http.metadata.body).revocation_endpoint
}

output "registration_endpoint" {
  value = jsondecode(data.http.metadata.body).registration_endpoint
}

output "jwks_uri" {
  value = jsondecode(data.http.metadata.body).jwks_uri
}

output "issuer" {
  value = jsondecode(data.http.metadata.body).issuer
}

output "introspection_endpoint" {
  value = jsondecode(data.http.metadata.body).introspection_endpoint
}

output "end_session_endpoint" {
  value = jsondecode(data.http.metadata.body).end_session_endpoint
}

output "authorization_endpoint" {
  value = jsondecode(data.http.metadata.body).authorization_endpoint
}

output "client_id" {
  value = [for k, v in okta_app_oauth.this-oauth-app : v.client_id]
}

output "client_secret" {
  value = [for k, v in okta_app_oauth.this-oauth-app : v.client_secret]
}

output "first_client_id" {
  value = [for k, v in okta_app_oauth.this-oauth-app : v.client_id].0
}

output "first_client_secret" {
  value = [for k, v in okta_app_oauth.this-oauth-app : v.client_secret].0
}
