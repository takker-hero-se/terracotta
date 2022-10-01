#!/bin/bash

terraform providers schema --json | jq -r -c '.provider_schemas."registry.terraform.io/hashicorp/azurerm".resource_schemas | keys[]' > terraform_provider.txt
az provider list | jq -r -c '.[] |  .namespace + "/" + .resourceTypes[].resourceType' > azure_provider.txt

