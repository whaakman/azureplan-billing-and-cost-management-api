Param (
    [string]$customerName,
    [string]$subscriptionName
)

# Authenticate to Azure
$azContext = Get-AzContext
if (!$azContext) {
Write-host "You're not logged in. Azure login-azaccount to login with credentials that have access to the Billing Account"

}
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}


# Uri Billing Accounts
$restUriBillingAccounts = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2019-10-01-preview"


# Retreive the Billing Accounts you have access to
$restUriBillingAccountsResponse = Invoke-RestMethod -Uri $restUriBillingAccounts -Method Get -Headers $authHeader

# Filter Billing Account Name for the Microsoft Customer Agreement / Partner
$billingAccountName = ($restUriBillingAccountsResponse.value| Where-Object {$_.properties.agreementType -like "MicrosoftCustomerAgreement"}).name

# Retreive the customers your billing account has access to
$restUriCustomers = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/$billingAccountName/customers?api-version=2019-10-01-preview"
$restUriCustomersResponse = Invoke-RestMethod -Uri $restUriCustomers -Method Get -Headers $authHeader

# Filter the customerid
$customerId = ($restUriCustomersResponse.value | Where-Object {$_.properties.displayName -like "$customerName"}).id

# Create the subscription under the Customer Azure Plan
$restUriCreateSubscription = "https://management.azure.com"+ $customerId +"/providers/Microsoft.Subscription/createSubscription?api-version=2018-11-01-preview"


$bodyCreateSubscription = @"
{
    "displayName" : "$subscriptionName",
    "skuId" : "0001"
} 
"@

$createSubscriptionResponse = Invoke-RestMethod -Uri $restUriCreateSubscription -Method Post -Body $bodyCreateSubscription -Headers $authHeader
$createSubscriptionResponse



