data "azuread_client_config" "current" {}

resource "azuread_application" "status_page" {
  display_name     = "app-status-page-${var.environment}"
  sign_in_audience = "AzureADMyOrg"

  group_membership_claims = ["SecurityGroup"]

  optional_claims {
    id_token {
      name                  = "groups"
      additional_properties = []
    }
    access_token {
      name                  = "groups"
      additional_properties = []
    }
  }

  web {
    redirect_uris = [
      "https://${local.status_page_name}.azurewebsites.net/.auth/login/aad/callback"
    ]
    implicit_grant {
      id_token_issuance_enabled = true
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read (delegated)
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "status_page" {
  client_id = azuread_application.status_page.client_id
}

resource "azuread_application_password" "status_page" {
  application_id = azuread_application.status_page.id
  display_name   = "status-page-secret"
  end_date       = "2027-12-31T00:00:00Z"
}

# ── App registrations for target apps ──────────────────────────────────────

resource "azuread_application" "hr_portal" {
  display_name     = "app-hr-portal-${var.environment}"
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = [
      "https://${local.hr_app_name}.azurewebsites.net/.auth/login/aad/callback"
    ]
    implicit_grant {
      id_token_issuance_enabled = true
    }
  }
}

resource "azuread_service_principal" "hr_portal" {
  client_id = azuread_application.hr_portal.client_id
}

resource "azuread_application_password" "hr_portal" {
  application_id = azuread_application.hr_portal.id
  display_name   = "hr-portal-secret"
  end_date       = "2027-12-31T00:00:00Z"
}

resource "azuread_application" "finance_dashboard" {
  display_name     = "app-finance-dashboard-${var.environment}"
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = [
      "https://${local.finance_app_name}.azurewebsites.net/.auth/login/aad/callback"
    ]
    implicit_grant {
      id_token_issuance_enabled = true
    }
  }
}

resource "azuread_service_principal" "finance_dashboard" {
  client_id = azuread_application.finance_dashboard.client_id
}

resource "azuread_application_password" "finance_dashboard" {
  application_id = azuread_application.finance_dashboard.id
  display_name   = "finance-dashboard-secret"
  end_date       = "2027-12-31T00:00:00Z"
}

resource "azuread_application" "admin_portal" {
  display_name     = "app-admin-portal-${var.environment}"
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = [
      "https://${local.admin_app_name}.azurewebsites.net/.auth/login/aad/callback"
    ]
    implicit_grant {
      id_token_issuance_enabled = true
    }
  }
}

resource "azuread_service_principal" "admin_portal" {
  client_id = azuread_application.admin_portal.client_id
}

resource "azuread_application_password" "admin_portal" {
  application_id = azuread_application.admin_portal.id
  display_name   = "admin-portal-secret"
  end_date       = "2027-12-31T00:00:00Z"
}

# ── Entra ID groups ─────────────────────────────────────────────────────────

resource "azuread_group" "hr_users" {
  display_name     = "grp-hr-users"
  security_enabled = true
  mail_enabled     = false
}

resource "azuread_group" "finance_users" {
  display_name     = "grp-finance-users"
  security_enabled = true
  mail_enabled     = false
}

resource "azuread_group" "platform_admins" {
  display_name     = "grp-platform-admins"
  security_enabled = true
  mail_enabled     = false
}
