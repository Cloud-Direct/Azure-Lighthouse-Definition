# Azure-Lighthouse-Definition

Azure Lighthouse definitions with Privileged Identity Management for Cloud Direct managed services. See internal documentation for more detail.

## Parameter files

The JSON parameter files may be used by either ARM or Terraform and follow the naming convention `lighthouse.<service>.parameters.json`.

See [PARAMETERS.md](./PARAMETERS.md) if updating or creating parameter files.

## Creating Azure Lighthouse definitions

The commands below create the definition at the Management subscription scope in the Cloud Direct Demo environment. Set to the correct subscription for your deployment.
