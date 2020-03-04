# Microsoft Customer Agreement scripts for CSPs
If you are a CSP and providing your customers an Azure Plan, you're actually an MPA providing an MCA (https://www.wesleyhaakman.org/microsoft-partner-agreement-vs-microsoft-customer-agreement-whats-the-difference/).

>Note: Currently (March 4th, 2020) adding Azure Subscriptions under an Azure Plan for your customers through the Azure Portal can be an issue if you have more than 50 customers containing Azure Plans. The selection only pulls the first 50 customers from the API. If the customer you're looking for is not within that first group you can't add a subscription. The scripts in this repository leverage paging (nextlink) to retrieve the next 50 customers and so forth. 

Creating subscriptions for your customers through the REST API can be done with the following scripts:

## getMCACustomersFromBillingAccount.ps1
Gets all customers in your billing account

Usage: _.\getMCACustomersFromBillingAccount.ps1_

## createCustomerSubscriptionMPA.ps1
Usage: _.\getMCACustomersFromBillingAccount.ps1 -customerName "customername" -subscriptionName "subscriptionname"_

Note that the customername must match the customer name as retrieved by getMCACustomersFromBillingAccount.ps1

