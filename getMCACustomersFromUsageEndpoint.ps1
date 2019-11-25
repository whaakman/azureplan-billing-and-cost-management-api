
# Retrieve all customers, subscriptions and details

# Authenticate to Azure
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}


$restUriBillingAccounts = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2019-10-01-preview"

# Retreive the Billing Accounts you have access to
$restUriBillingAccountsResponse = Invoke-RestMethod -Uri $restUriBillingAccounts -Method Get -Headers $authHeader

# Filter Billing Account Name for the Microsoft Customer Agreement / Partner
$billingAccountName = ($restUriBillingAccountsResponse.value| Where-Object {$_.properties.agreementType -like "MicrosoftCustomerAgreement"}).name

# Uri Usage Details
$restUriCostManagement = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/$billingAccountName/providers/Microsoft.Consumption/usageDetails?api-version=2019-10-01"

# Retreive the Billing Accounts you have access to
$restUriCostManagementResponse = Invoke-RestMethod -Uri $restUriCostManagement -Method Get -Headers $authHeader -TimeoutSec 300

$customers = @()
foreach ($customer in $restUriCostManagementResponse.value)
    {
        $customers+=$customer      
    }
$customers.properties |Sort-Object -Property @{Expression = {$_.customerName}; Ascending = $false}, subscriptionName -Unique |Format-Table customerName, subscriptionName, ProductOrderName, subscriptionGuid, customerTenantId
