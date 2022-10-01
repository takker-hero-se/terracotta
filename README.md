# terracotta
Output the resources in the Azure subscription as files as Terraform resource definitions for each resource group.
※　See resource.csv for corresponding resources

# Operation System Tested
- 5.10.102.1-microsoft-standard-WSL2(ubuntu)
- macOS Big Sur version 11.7

# Requirement Software
- jq 
- Terraform v1.3.1
- Azure CLI 2.32.0

# Terraform Provider 
- hashicorp/azurerm 3.25.0

# Execution method

Check resource.csv for corresponding resources

``` bash
git clone https://github.com/takker0708/terracotta.git
cd terracotta
az login
terraform init
bash ./generate_terraform.sh
```