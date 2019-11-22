
# Retrieve all customers, subscriptions and details on resources where Partner Earned Credit is set to '0'. 
# This indicates you don't receive Partner Earned Credit for that specific Resource

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
$customersWithoutPec = @()
foreach ($customer in $restUriCostManagementResponse.value)
{
    if ($customer.properties.partnerEarnedCreditApplied -eq "0")
    {
        $customersWithoutPec+=$customer
       
    }
}


$HtmlHeadFirstTable = '
<br />
<b>Customers Without Partner Earned Credit on one or more resources</b>
<style>
    body {
        background-color: white;
        font-family:      "Calibri";
    }

    table {
        border-width:     1px;
        border-style:     solid;
        border-color:     black;
        border-collapse:  collapse;
        width:            100%;
    }

    th {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: #51b848;
    }

    td {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: White;
    }

    tr {
        text-align:       left;
    }
</style>'

$HtmlHeadSecondTable = '
<br />
<b>Resource Details where Partner Earned Credit is not set to "true"</b>
<style>
    body {
        background-color: white;
        font-family:      "Calibri";
    }

    table {
        border-width:     1px;
        border-style:     solid;
        border-color:     black;
        border-collapse:  collapse;
        width:            100%;
    }

    th {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: #51b848;
    }

    td {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: White;
    }

    tr {
        text-align:       left;
    }
</style>
<br />'

$customersWithoutPec.properties `
|Sort-Object -Property @{Expression = {$_.customerName}; Ascending = $false}, subscriptionName -Unique `
|Select-Object @{N='Customer'; E={$_.customerName}}, @{N='Subscription'; E={$_.subscriptionName}}, @{N='Subscription ID'; E={$_.subscriptionGuid}} `
|ConvertTo-Html -Head $HtmlHeadFirstTable  `
|Out-File test3.htm 

$customersWithoutPec.properties `
|Sort-Object -Property @{Expression = {$_.customerName}; Ascending = $false}, subscriptionName `
|Select-Object @{N='Customer'; E={$_.customerName}}, @{N='Subscription'; E={$_.subscriptionName}}, @{N='Subscription ID'; E={$_.subscriptionGuid}}, @{N='Service'; E={$_.ConsumedService}}, @{N='Product'; E={$_.ProductOrderName}}, @{N='Resource ID'; E={$_.InstanceName}} `
|ConvertTo-Html -Head $HtmlHeadSecondTable `
|Out-File -append test3.htm 