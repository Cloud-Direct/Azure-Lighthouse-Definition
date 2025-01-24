locals {
  parameters   = jsondecode(file("${path.module}/${var.parms}"))["parameters"]
  name         = local.parameters.name.value
  display_name = local.parameters.display_name.value
  description  = local.parameters.description.value
  permanent    = try(local.parameters.permanent.value, [])
  eligible     = try(local.parameters.eligible.value, [])

  role_definition_id = {
    "Backup Contributor" : "5e467623-bb1f-42f4-a55d-6e525e11384b"
    "Backup Operator" : "00c29273-979b-4161-815c-10b084fb9324"
    "Billing Reader" : "fa23ad8b-c56e-40d8-ac0c-ce449e1d2c64"
    "Contributor" : "b24988ac-6180-42a0-ab88-20f7382dd24c"
    "Cost Management Contributor" : "434105ed-43f6-45c7-a02f-909b2ba83430"
    "Cost Management Reader" : "72fafb9e-0641-4937-9268-a91bfd8191a3"
    "Key Vault Contributor" : "f25e0fa2-a7c8-4377-a976-54943a77a395"
    "Managed Services Registration Assignment Delete Role" : "91c1777a-f3dc-4fae-b103-61d183457e46"
    "Microsoft Sentinel Contributor" : "ab8e14d6-4a74-4a29-9ba8-549422addade"
    "Microsoft Sentinel Responder" : "3e150937-b8fe-4cfb-8069-0eaf05ecd056"
    "Monitoring Contributor" : "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    "Quota Request Operator" : "0e5f05e5-9ab9-446b-b98d-1e2157c94125"
    "Reader" : "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    "Security Reader" : "39bc4728-0917-49c7-9d2c-d95423bc2eb4"
    "Support Request Contributor" : "cfd33db0-3dd1-45e3-aa9d-cdbdf3b6f24e"
    "User Access Administrator" : "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
    "Virtual Machine Contributor" : "9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
    "Virtual Machine Local User Login" : "602da2ba-a5c2-41da-b01d-5360126ab525"
  }

  approvers = coalesce(var.approvers, try(local.parameters.approvers.value, {
    standard = {
      name     = "PIM approvals - Standard Roles",
      objectId = "0b0b76e2-808a-404a-9c50-51bb28b5a85d"
    },
    contributor = {
      name     = "PIM approvals - Contributor Role",
      objectId = "af7551ad-9496-4d40-bc66-970ed3d42c1a"
    }
  }))

  lighthouse_admins = coalesce(var.lighthouse_admins, try(local.parameters.lighthouse_admins.value, {
    name     = "Lighthouse Administrator group"
    objectId = "68cdc804-aca6-498a-86b5-71f1f4d7093d"
  }))

  just_in_time_access_policy = {
    "Self Elevate" = {
      multi_factor_auth_provider  = "Azure"
      maximum_activation_duration = "PT8H"
      approver                    = {}
    },
    "Standard Role Approval" = {
      multi_factor_auth_provider  = "Azure"
      maximum_activation_duration = "PT8H"
      approver = {
        principal_display_name = local.approvers.standard.name
        principal_id           = local.approvers.standard.objectId
      }
    },
    "Contributor Role Approval" = {
      multi_factor_auth_provider  = "Azure"
      maximum_activation_duration = "PT8H"
      approver = {
        principal_display_name = local.approvers.contributor.name
        principal_id           = local.approvers.contributor.objectId
      }
    }
  }

  managed_services_registration_assignment_delete = {
    principal_display_name = local.lighthouse_admins.name
    principal_id           = local.lighthouse_admins.objectId
    role_definition_id     = local.role_definition_id["Managed Services Registration Assignment Delete Role"]
  }

  authorizations = [for auth in local.permanent : {
    principal_display_name = auth.name
    principal_id           = auth.objectId
    role_definition_id     = local.role_definition_id[auth.roleName]
  }]

  eligible_authorizations = [for auth in local.eligible : {
    principal_display_name     = auth.name
    principal_id               = auth.objectId
    role_definition_id         = local.role_definition_id[auth.roleName]
    just_in_time_access_policy = local.just_in_time_access_policy[auth.approval]
  }]
}

resource "azurerm_lighthouse_definition" "lighthouse" {
  lighthouse_definition_id = local.name
  name                     = local.display_name
  description              = local.description
  managing_tenant_id       = "2d2006bf-2fde-473c-8ce4-ea5307e8eb99"
  scope                    = "/subscriptions/${var.subscription_id}"

  dynamic "authorization" {
    for_each = concat(local.authorizations, [local.managed_services_registration_assignment_delete])
    content {
      principal_id           = authorization.value.principal_id
      role_definition_id     = authorization.value.role_definition_id
      principal_display_name = authorization.value.principal_display_name
    }
  }

  dynamic "eligible_authorization" {
    for_each = local.eligible_authorizations
    content {
      principal_display_name = eligible_authorization.value.principal_display_name
      principal_id           = eligible_authorization.value.principal_id
      role_definition_id     = eligible_authorization.value.role_definition_id

      dynamic "just_in_time_access_policy" {
        for_each = [eligible_authorization.value.just_in_time_access_policy]
        content {
          multi_factor_auth_provider  = just_in_time_access_policy.value.multi_factor_auth_provider
          maximum_activation_duration = just_in_time_access_policy.value.maximum_activation_duration

          dynamic "approver" {
            for_each = length(just_in_time_access_policy.value.approver) > 0 ? [just_in_time_access_policy.value.approver] : []
            content {
              principal_display_name = approver.value.principal_display_name
              principal_id           = approver.value.principal_id
            }
          }
        }
      }
    }
  }
}
