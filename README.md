# Azure-Lighthouse-Definition

Azure Lighthouse definitions with Privileged Identity Management for Cloud Direct managed services. See internal documentation for more detail.

## Parameter files

The JSON parameter files may be used by either ARM or Terraform and follow the naming convention `lighthouse.<service>.parameters.json`.

See [PARAMETERS.md](./PARAMETERS.md) if updating or creating parameter files.

## Creating Azure Lighthouse definitions

The examples below create the standard definition at the current subscription scope. (Use `--subscription` to specify explicitly.)

### Azure CLI

```shell
az deployment sub create --location uksouth \
  --template-uri "https://raw.githubusercontent.com/Cloud-Direct/Azure-Lighthouse-Definition/refs/tags/v1.2/lighthouse.json" \
  --parameters "https://raw.githubusercontent.com/Cloud-Direct/Azure-Lighthouse-Definition/refs/tags/v1.2/lighthouse.standard.parameters.json"
```

### PowerShell

```powershell
New-AzSubscriptionDeployment -Location uksouth -TemplateUri "https://raw.githubusercontent.com/Cloud-Direct/Azure-Lighthouse-Definition/refs/tags/v1.2/lighthouse.json" -TemplateParameterUri "https://raw.githubusercontent.com/Cloud-Direct/Azure-Lighthouse-Definition/refs/tags/v1.2/lighthouse.standard.parameters.json"
```



### Terraform

```ruby
module "standard_lighthouse_definition" {
  source          = "github.com/Cloud-Direct/Azure-Lighthouse-Definition?ref=v1.2"
  parms           = "lighthouse.standard.parameters.json"
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

resource "azurerm_lighthouse_assignment" "standard" {
  for_each = toset([
    "11111111-1111-1111-1111-111111111111",
    "22222222-2222-2222-2222-222222222222",
    "33333333-3333-3333-3333-333333333333"
  ])

  scope                    = "/subscriptions/${each.value}"
  lighthouse_definition_id = module.standard_lighthouse_definition.id
}
```

The assignments are optional. Also see the <https://github.com/Cloud-Direct/Azure-Lighthouse-Policy-Definition> repo for a Terraform example that takes a policy based approach to Azure Lighthouse assignments.
