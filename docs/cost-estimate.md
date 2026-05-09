# Azure Cost Estimate — az-hub-spoke (dev)

> Prices are estimates for **UK South** (adjust for your region).  
> Assumes 730 hours/month, minimal traffic, and no reserved instances.  
> Verify exact figures with the [Azure Pricing Calculator](https://azure.microsoft.com/en-gb/pricing/calculator/).

---

## Summary

| Layer | Monthly est. |
|---|---|
| Network (Firewall, Bastion, Peering, DNS) | ~$250–280 |
| Monitoring (Log Analytics, Flow Logs, Storage) | ~$10–25 |
| Apps (App Service, Front Door, WAF) | ~$65–75 |
| **Total** | **~$325–380 / month** |

---

## Per-Resource Breakdown

### Network

| Resource | SKU | Billing model | $/month est. |
|---|---|---|---|
| Azure Firewall | Basic | $0.113/hr deployment + $0.016/GB processed | ~$82 + traffic |
| Azure Bastion | Standard | ~$0.19/hr/scale-unit (2 units default) | ~$275 |
| Public IP — firewall | Standard Static | $0.005/hr | ~$3.65 |
| Public IP — firewall mgmt | Standard Static | $0.005/hr | ~$3.65 |
| Public IP — bastion | Standard Static | $0.005/hr | ~$3.65 |
| VNet Peering ×4 | Intra-region | $0.01/GB transferred | ~$1–5 |
| Private DNS Zones ×2 | — | $0.40/zone/month + $0.40/million queries | ~$1 |

> **Biggest single cost: Azure Bastion Standard.** With 2 scale units it runs ~$275/month even with zero sessions. Consider stopping Bastion when not actively using it, or dropping to Basic SKU (~$138/month, 1 scale unit, fewer features).

### Monitoring

| Resource | SKU | Billing model | $/month est. |
|---|---|---|---|
| Log Analytics Workspace | PerGB2018 | First 5 GB free, then $2.30/GB; 30-day retention | ~$5–20 |
| Storage Account (flow logs) | Standard LRS | ~$0.018/GB stored | ~$1–2 |
| Network Watcher Flow Logs | — | Free for flow log ingestion | $0 |
| Traffic Analytics | — | $0.10/GB + $2.76/node (no VMs here) | ~$1–3 |
| Monitor Action Group | — | 1,000 email alerts/month free | ~$0 |
| Monitor Metric Alerts ×3 | — | First 10 metric alert rules free | $0 |

### Apps

| Resource | SKU | Billing model | $/month est. |
|---|---|---|---|
| App Service Plan | B1 Linux | $0.018/hr (shared by all 4 web apps) | ~$13 |
| Web Apps ×4 | — | Included in plan | $0 |
| Azure Front Door | Standard | $35/month base; +$5/routing rule beyond first | ~$50 |
| WAF Policy | Standard managed rules | ~$20/month per policy | ~$20 |

> Front Door Standard includes the first routing rule and custom domain in the base fee. Four routes = base $35 + 3 extra routes × ~$5 = ~$50/month, before data transfer costs ($0.008/GB from origin).

---

## Cost Drivers & Optimisation Tips

1. **Bastion Standard (~$275/month)** — biggest line item. Options:
   - Switch to **Basic SKU** to save ~$137/month (loses file transfer and session recording).
   - Deallocate Bastion when not in active use (it's not always-on infrastructure like the firewall).

2. **Azure Firewall Basic (~$82/month base)** — already on the cheapest tier. The switch from Standard saved ~$830/month. No further SKU reductions available; next step would be removing it entirely for a non-hub architecture.

3. **Log Analytics retention** — currently 30 days at $2.30/GB. Dropping to the minimum (free 31-day retention window in PerGB2018 means you're already at the free tier for retention — no action needed).

4. **Front Door WAF managed rules** — both `Microsoft_DefaultRuleSet` and `Microsoft_BotManagerRuleSet` are enabled. Each managed rule set adds per-request processing cost at high volume, but negligible at dev-scale.

5. **No VMs deployed** — the management spoke subnets (`sn-tools`, `sn-jump`) are defined but no VMs are provisioned, so there are no compute or disk costs there.

---

## Approximate Annual Cost

| Scenario | $/month | $/year |
|---|---|---|
| As-is (Standard Bastion) | ~$325–380 | ~$3,900–4,560 |
| With Basic Bastion | ~$190–245 | ~$2,280–2,940 |

---

*Last updated: 2026-05-09. Azure prices change — always cross-check before budgeting.*
