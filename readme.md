# Microsoft Customer Agreement scripts for CSPs
If you are a CSP and providing your customers an Azure Plan, you're actually an MPA providing an MCA (https://www.wesleyhaakman.org/microsoft-partner-agreement-vs-microsoft-customer-agreement-whats-the-difference/).

Creating subscriptions for your customers through the REST API can be done with the following scripts:

## getMCACustomersFromBillingAccount.ps1
Gets all customers in your billing account

Usage: _.\getMCACustomersFromBillingAccount.ps1_

## createCustomerSubscriptionMPA.ps1
Usage: _.\getMCACustomersFromBillingAccount.ps1 -customerName "customername" -subscriptionName "subscriptionname"_

Note that the customername must match the customer name as retrieved by getMCACustomersFromBillingAccount.ps1

