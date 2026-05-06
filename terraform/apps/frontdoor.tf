# ── Azure Front Door Standard + WAF ────────────────────────────────────────

resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-${var.environment}-${var.location_short}"
  resource_group_name = azurerm_resource_group.apps.name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = local.tags
}

resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                = "waf${var.environment}${replace(var.location_short, "-", "")}"
  resource_group_name = azurerm_resource_group.apps.name
  sku_name            = azurerm_cdn_frontdoor_profile.main.sku_name
  enabled             = true
  mode                = "Prevention"

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }

  tags = local.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "afd-ep-${var.environment}-${local.name_suffix}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  tags                     = local.tags
}

# ── Origin Groups ──────────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_origin_group" "status" {
  name                     = "og-status"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin_group" "hr" {
  name                     = "og-hr"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin_group" "finance" {
  name                     = "og-finance"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin_group" "admin" {
  name                     = "og-admin"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  load_balancing {}
}

# ── Origins ────────────────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_origin" "status" {
  name                           = "origin-status"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.status.id
  enabled                        = true
  certificate_name_check_enabled = true
  host_name                      = azurerm_linux_web_app.status_page.default_hostname
  origin_host_header             = azurerm_linux_web_app.status_page.default_hostname
  http_port                      = 80
  https_port                     = 443
}

resource "azurerm_cdn_frontdoor_origin" "hr" {
  name                           = "origin-hr"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.hr.id
  enabled                        = true
  certificate_name_check_enabled = true
  host_name                      = azurerm_linux_web_app.hr.default_hostname
  origin_host_header             = azurerm_linux_web_app.hr.default_hostname
  http_port                      = 80
  https_port                     = 443
}

resource "azurerm_cdn_frontdoor_origin" "finance" {
  name                           = "origin-finance"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.finance.id
  enabled                        = true
  certificate_name_check_enabled = true
  host_name                      = azurerm_linux_web_app.finance.default_hostname
  origin_host_header             = azurerm_linux_web_app.finance.default_hostname
  http_port                      = 80
  https_port                     = 443
}

resource "azurerm_cdn_frontdoor_origin" "admin" {
  name                           = "origin-admin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.admin.id
  enabled                        = true
  certificate_name_check_enabled = true
  host_name                      = azurerm_linux_web_app.admin_portal.default_hostname
  origin_host_header             = azurerm_linux_web_app.admin_portal.default_hostname
  http_port                      = 80
  https_port                     = 443
}

# ── Routes ─────────────────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_route" "status" {
  name                          = "route-status"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.status.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.status.id]

  patterns_to_match      = ["/*"]
  supported_protocols    = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
}

resource "azurerm_cdn_frontdoor_route" "hr" {
  name                          = "route-hr"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.hr.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.hr.id]

  patterns_to_match      = ["/hr/*"]
  supported_protocols    = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
}

resource "azurerm_cdn_frontdoor_route" "finance" {
  name                          = "route-finance"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.finance.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.finance.id]

  patterns_to_match      = ["/finance/*"]
  supported_protocols    = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
}

resource "azurerm_cdn_frontdoor_route" "admin" {
  name                          = "route-admin"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.admin.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.admin.id]

  patterns_to_match      = ["/admin/*"]
  supported_protocols    = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
}

# ── WAF Security Policy ────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_security_policy" "main" {
  name                     = "secpolicy-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.main.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
