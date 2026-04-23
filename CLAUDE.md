# Azure Hub-and-Spoke Enterprise Network

This project implements an advanced, enterprise-grade Hub-and-Spoke networking architecture in Azure using Terraform. 
It demonstrates centralized egress, secure remote access, and private PaaS connectivity suitable for a Cloud/DevOps Engineer CV.

## Architecture Guidelines
- **Hub VNet (`10.0.0.0/16`)**: Contains Azure Firewall (`10.0.1.0/26`), Azure Bastion (`10.0.2.0/26`), Shared Services (`10.0.3.0/24`), and DNS (`10.0.4.0/24`).
- **App Spoke VNet (`10.1.0.0/16`)**: Contains Web (`10.1.1.0/24`), App (`10.1.2.0/24`), and Private Endpoint (`10.1.10.0/24`) subnets.
- **Management Spoke VNet (`10.2.0.0/16`)**: Contains Tools/Jump VM subnets.
- **Routing**: App/Mgmt spoke subnets must have UDRs (Route Tables) forwarding `0.0.0.0/0` to the Azure Firewall private IP.
- **Peering**: Hub and spokes must be connected via bidirectional VNet Peering with `allow_forwarded_traffic = true`.
- **Private DNS**: Configure Private DNS zones for Storage (`privatelink.blob.core.windows.net`) and Key Vault (`privatelink.vaultcore.azure.net`) linked to the Hub and App VNets.
- **Security**: No public IPs on spoke VMs. Access is exclusively via Azure Bastion in the Hub.

## Terraform & Code Style Rules
- **Provider**: Use the `azurerm` provider (latest 3.x or 4.x compatible).
- **Structure**: Strongly separate infrastructure into modules (`modules/hub_network`, `modules/spoke_network`, `modules/firewall`, etc.) and environments (`environments/dev`).
- **State Management**: Assume remote state in Azure Blob Storage with Azure Key Vault for secrets (configure generic backend blocks).
- **Naming Convention**: Use consistent prefixes (e.g., `rg-<project>-<env>-<region>`) and standard Azure abbreviations (vnet, snet, afw, bas, pep).
- **Variables**: Expose necessary variables in modules (location, prefix, CIDRs) and define locals for tags.
- **Outputs**: Ensure modules output IDs and IPs needed by other modules (e.g., Firewall Private IP for UDRs, VNet IDs for Peering).

## Common Commands
Run these commands from the `environments/dev` directory:
```bash
# Initialize Terraform with backend
terraform init

# Validate module syntax and structure
terraform validate

# Plan the infrastructure deployment
terraform plan -out=tfplan

# Apply the deployment
terraform apply tfplan

# Format all Terraform files
terraform fmt -recursive ../../
```

## AI Agent Instructions (Claude Code)
1. Always implement infrastructure using modular Terraform, never a single monolithic `main.tf`.
2. When creating modules, include `variables.tf`, `main.tf`, and `outputs.tf`.
3. Do not invent custom default CIDRs; use the ones specified in the Architecture Guidelines above.
4. When adding Private Endpoints, ensure the correct sub-resource name (e.g., `blob` for storage, `vault` for Key Vault) is used in the `private_service_connection`.
5. After creating or modifying Terraform files, always run `terraform fmt -recursive`.
