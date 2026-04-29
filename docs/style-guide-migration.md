# Style Guide Migration — carlzxc71 / lindbergtech

This document explains every structural and stylistic change made when rewriting the Terraform code to follow the carlzxc71 / lindbergtech style guide (derived from six production repositories: `azure-terraform-environments`, `azure-terraform-vwan`, `azure-terraform-pim`, `azure-terraform-policyascode`, `azure-terraform-private-endpoint`, `azure-terraform-ipam`).

---

## 1. Repository Layout

**Before**
```
environments/dev/
  main.tf, providers.tf, backend.tf, variables.tf, outputs.tf, terraform.tfvars
modules/
  hub_network/, spoke_network/, firewall/, bastion/, peering/, private_dns/, monitoring/
bootstrap/
  main.tf, variables.tf, outputs.tf
```

**After**
```
main.tf          — terraform{}, provider{}, locals, all networking resources
firewall.tf      — firewall resources (a single logical complex unit)
bastion.tf       — bastion resources
monitoring.tf    — monitoring resources (LAW, storage, flow logs, alerts)
dns.tf           — private DNS zones and VNet links
variables.tf     — all variable declarations
outputs.tf       — root outputs
variables/
  dev.tfvars
  prd.tfvars
scripts/
  prepare-dev.sh — az CLI backend bootstrap (replaces bootstrap/ Terraform module)
  init-dev.sh    — terraform init with -backend-config flags
```

**Why:** The style guide mandates a single flat root module. No `modules/` directory — everything lives at the repo root. Complex logical units (firewall, bastion, monitoring, DNS) each get their own `.tf` file; simple networking resources live in `main.tf`.

---

## 2. No providers.tf / backend.tf

**Before:** `providers.tf` held the `terraform {}` and `provider "azurerm" {}` blocks. `backend.tf` held the backend configuration with a commented-out remote backend.

**After:** Both blocks merged into `main.tf` in the correct order: `terraform {}` first, then `provider {}`. The backend is an empty `backend "azurerm" {}` block; all config is supplied at init time via `-backend-config` flags in `scripts/init-dev.sh`.

---

## 3. Provider Version Pin

**Before:** `version = "~> 4.0"` (range operator)

**After:** `version = "4.20.0"` (exact pin)

**Why:** The style guide requires exact version pins. Range operators allow silent upgrades that can break infrastructure.

---

## 4. Naming Convention

**Before:** `rg-${var.prefix}-hub-${var.environment}-${var.location_short}`

**After:** `rg-${var.environment}-${var.location_short}-hub`

Pattern: `<abbreviation>-<environment>-<location_short>-<descriptor>`

Full rename table:

| Resource | Before | After |
|---|---|---|
| Hub RG | `rg-hubspoke-hub-dev-weu` | `rg-dev-sc-hub` |
| Hub VNet | `vnet-hubspoke-hub-dev-weu` | `vnet-dev-sc-hub` |
| App RG | `rg-hubspoke-app-dev-weu` | `rg-dev-sc-app` |
| Firewall | `afw-hubspoke-dev-weu` | `afw-dev-sc` |
| Firewall PIP | `pip-afw-hubspoke-dev-weu` | `pip-dev-sc-afw` |
| Bastion | `bas-hubspoke-dev-weu` | `bas-dev-sc` |
| Bastion PIP | `pip-bas-hubspoke-dev-weu` | `pip-dev-sc-bas` |
| App NSG | `nsg-hubspoke-app-dev-weu` | `nsg-dev-sc-app` |
| App RT | `rt-hubspoke-app-dev-weu` | `rt-dev-sc-app` |
| DNS link | `link-hub` | `link-dev-sc-hub` |

---

## 5. Removed prefix Variable

**Before:** A `prefix` variable (`"hubspoke"`) was threaded through every module and embedded in every resource name.

**After:** Removed entirely. Resource names are built from `environment` + `location_short` + descriptor, which already provides sufficient uniqueness and matches the style guide pattern.

---

## 6. location_short as Explicit Variable

**Before:** `location_short` was computed inside `environments/dev/main.tf` via a map lookup: `{ "westeurope" = "weu", ... }[var.location]`.

**After:** `location_short` is a first-class input variable declared in `variables.tf` and set in `variables/dev.tfvars`. This matches the style guide and avoids a computed local that breaks if a new region is added.

---

## 7. Default Region Changed

**Before:** `location = "westeurope"`, `location_short = "weu"`

**After:** `location = "swedencentral"`, `location_short = "sc"`

**Why:** The style guide states `swedencentral` is the default Azure region in every carlzxc71 repo.

---

## 8. Environment Name Convention

**Before:** Used `"dev"` and `"prod"` (four letters).

**After:** Uses `"dev"` and `"prd"` (three letters).

**Why:** The style guide shows a shift from `prod` → `prd` in newer repos. New work should use `prd`.

---

## 9. tfvars Location

**Before:** `environments/dev/terraform.tfvars` (at the environment root, no subdirectory)

**After:** `variables/dev.tfvars` and `variables/prd.tfvars` (under `variables/` subdirectory)

**Why:** The style guide mandates a `variables/` subdirectory. Values are aligned with spaces to the longest key within the file.

---

## 10. Subnet Prefix

**Before:** `snet-web`, `snet-app`, `snet-pep`, `snet-tools`, `snet-jump`

**After:** `sn-web`, `sn-app`, `sn-pep`, `sn-tools`, `sn-jump`

**Why:** The style guide uses `sn-` as the subnet abbreviation consistently across all repos.

---

## 11. Subnet Configuration via locals

**Before:** Subnet maps were declared as module input variables in `environments/dev/main.tf` and passed to `modules/spoke_network`.

**After:** Subnet configs are `locals` in `main.tf` (`app_subnet_config`, `mgmt_subnet_config`) consumed directly by `for_each` on `azurerm_subnet` resources. Static config maps driving `for_each` are a first-class locals pattern in the style guide.

---

## 12. Terraform Resource Logical Names

**Before:** Module-scoped names (`hub`, `spoke`, `this`) that only made sense inside their module.

**After:** Flat-scope descriptive names that are unambiguous at the root level:
- Multiple of same type → descriptive: `azurerm_resource_group.hub`, `.app`, `.mgmt`
- Singletons → `this`: `azurerm_firewall.this`, `azurerm_bastion_host.this`, `azurerm_log_analytics_workspace.this`
- for_each resources → descriptive plural context: `azurerm_subnet.app`, `azurerm_subnet.mgmt`

---

## 13. Variables Style

**Before:** `type` first, then `description`. Some variables had `validation {}` blocks.

**After:** `description` first, then `type`. No `validation {}` blocks anywhere.

**Why:** The style guide explicitly orders `description`, `type` and states no validation blocks are used in any carlzxc71 repo.

---

## 14. Comments

**Before:** Section divider comments `# ── Section ──────────────` in every file, inline `#` comments.

**After:** Two `//` inline comments remain — one explaining why `AzureFirewallSubnet`/`AzureBastionSubnet` have fixed names (non-obvious constraint), one with the `terraform import` command needed for the pre-existing NetworkWatcher resource (non-obvious operational requirement).

**Why:** The style guide uses `//` style only, strictly for non-obvious values. No section headers or commented-out code.

---

## 15. Backend Bootstrap: Terraform → az CLI Script

**Before:** A separate `bootstrap/` Terraform module that created an Azure Storage Account for state, then required running `terraform apply` in a second root before the main environment.

**After:** `scripts/prepare-dev.sh` — a plain `az` CLI script that creates the resource group, storage account, container, and role assignment. `scripts/init-dev.sh` runs `terraform init` with all `-backend-config` flags.

**Why:** The style guide replaces Terraform-bootstrapped backends with `scripts/prepare-<env>.sh` + `scripts/init-<env>.sh`. The az CLI approach avoids the chicken-and-egg problem of needing Terraform state to bootstrap Terraform state.

---

## 16. Backend Naming

Follows the style guide's exact naming scheme:

| Component | Value |
|---|---|
| Resource group | `rg-dev-terraform-tfstate` |
| Storage account | `stdevterraformtfstate` |
| Container | `tfstate-hub-spoke` |
| State key | `dev.terraform.tfstate` |

Storage accounts have no hyphens and are all lowercase per Azure naming rules.

---

## 17. DNS Zone Links

**Before:** A `private_dns` module used `flatten()` over zones × vnets to compute a cross-product map for a single `azurerm_private_dns_zone_virtual_network_link` for_each.

**After:** Two separate link resources (`azurerm_private_dns_zone_virtual_network_link.hub` and `.app`), each iterating over `azurerm_private_dns_zone.this`. Cleaner, no flatten, easier to read and extend.

---

## 18. .gitignore

Added standard Terraform entries:
- `**/.terraform/*`
- `*.tfstate`, `*.tfstate.*`
- `crash.log`, `.terraform.lock.hcl`
- `override.tf`, `.terraformrc`
