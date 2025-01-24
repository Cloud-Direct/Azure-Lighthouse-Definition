# Assigning the definition

You will need Owner permissions to delegate a subscription. The Microsoft.ManagedServices provider must be registered.

## Azure Portal

It is recommended that delegations are done in the portal with the customer.  Review the authorizations in the [Service Provider offers](https://portal.azure.com/#view/Microsoft_Azure_CustomerHub/ServiceProvidersBladeV2/~/providers). Use [Delegations](https://portal.azure.com/#view/Microsoft_Azure_CustomerHub/ServiceProvidersBladeV2/~/scopeManagement) to project subscriptions or individual resource groups.

The customer can view activity in the [Activity Log](https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/activityLog). They may revoke access at any point by deleting delegations or whole offers.

## Azure Policy

Another recommended approach is to use Azure Policy at a management group scope to automatically assign the Azure Lighthouse definition.

See <https://github.com/Cloud-Direct/Azure-Lighthouse-Policy-Definition>.

## PowerShell

Example below. Replace the subscription IDs and definition name as applicable.

1. Login to the right tenant

    ```powershell
    Connect-AzAccount -Tenant clouddirectdemo.net
    ```

1. Get the definition as an object

    ```powershell
    $lighthouseDefinition = Get-AzManagedServicesDefinition -Scope "/subscriptions/0504ca0c-defa-456d-8d51-c2f19c022c3a" \
      | Where-Object { $_RegistrationDefinitionName -eq "Standard Managed Service" }
    ```

1. Assign the definition

    Delegate access to the subscription 4e1d145e-c48d-4e82-a182-8d9820a62fee.

    ```powershell
    $scope = "/subscriptions/4e1d145e-c48d-4e82-a182-8d9820a62fee"
    $guid = [guid]::NewGuid()
    New-AzManagedServicesAssignment -Scope $scope -RegistrationDefinitionId $definition.Id -Name $guid
    ```

1. View the assignment

   ```powershell
   Get-AzManagedServicesAssignment -Scope /subscriptions/4e1d145e-c48d-4e82-a182-8d9820a62fee | ConvertTo-JSON
   ```

## Azure CLI

The Azure CLI is _not recommended_ as it does not use a recent API version and therefore does not support eligible authorizations.
