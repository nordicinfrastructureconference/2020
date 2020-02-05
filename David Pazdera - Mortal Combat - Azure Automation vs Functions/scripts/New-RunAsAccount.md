# How to create a RunAs account in Azure Automation with PowerShell

This is an extract of instructions available in [Microsoft Azure Docs](https://docs.microsoft.com/en-us/azure/automation/manage-runas-account#create-run-as-account-using-powershell)

## Prerequisites

- Windows 10 or Windows Server 2016 with Azure Resource Manager modules 3.4.1 and later. The PowerShell script does not support earlier versions of Windows.
- Azure PowerShell 1.0 and later. For information about the PowerShell 1.0 release, see How to install and configure Azure PowerShell.
- An Automation account, which is referenced as the value for the –AutomationAccountName and -ApplicationDisplayName parameters.
- Permissions equivalent to what is listed in [Required permissions to configure Run As accounts](https://docs.microsoft.com/en-us/azure/automation/manage-runas-account#permissions)

## Create a Run As account by using a self-signed certificate

````[powershell]
.\New-RunAsAccount.ps1 -ResourceGroup <ResourceGroupName> -AutomationAccountName <NameofAutomationAccount> -SubscriptionId <SubscriptionId> -ApplicationDisplayName <DisplayNameofAADApplication> -SelfSignedCertPlainPassword <StrongPassword> -CreateClassicRunAsAccount $false
````

After the script has executed, you will be prompted to authenticate with Azure. Sign in with an account that is a member of the subscription administrators role and co-administrator of the subscription.
