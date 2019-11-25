
# Retrieve all customers that your Billing Account has access to

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

# Get Customers that your billing accoutn has access to
$restUriCustomers = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/$billingAccountName/customers?api-version=2019-10-01-preview"
$restUriCustomersResponse = Invoke-RestMethod -Uri $restUriCustomers -Method Get -Headers $authHeader

$restUriCustomersResponse.value.properties.displayName
