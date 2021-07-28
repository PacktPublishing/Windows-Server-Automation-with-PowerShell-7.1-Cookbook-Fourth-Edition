# Recipe 13.1 Getting started using Azure with PowerShell
#
# Run on SRV1

#  1. Finding core Azure module on the PS Gallery
Find-Module -Name Az |
  Format-Table -Wrap -Autosize

# 2. Installing AZ module
Install-Module -Name Az -Force

# 3. Discovering Azure modules and how many cmdlets each containss
$HT = @{ Label ='Cmdlets'
         Expression = {(Get-Command -module $_.name).count}}
Get-Module Az* -ListAvailable | 
    Sort-Object {(Get-command -Module $_.Name).Count} -Descending |
       Format-Table -Property Name, Version, Author,$HT -AutoSize

# 4. Finding Azure AD cmdlets
Find-Module AzureAD |
  Format-Table -Property Name,Version,Author -AutoSize -Wrap

# 5. Installing the Azure AD module
Install-Module -Name AzureAD -Force

# 6. Discovering Azure AD Module
$FTHT = @{
    Property = 'Name', 'Version', 'Author', 'Description'
    AutoSize = $true
    Wrap     = $true
}
Get-Module -Name AzureAD -ListAvailable |
  Format-Table @FTHT

# 7. Logging into Azure 
$CredAZ  = Get-Credential     # Enter your Azure Credential details
$Account = Connect-AzAccount -Credential $CredAZ
$Account

# 8. Getting Azure account name
$AccountN = $Account.Context.account.id
"Azure Account   : $AccountN"

# 9. Viewing Azure subscription
$SubID = $Account.Context.Subscription.Id
Get-AzSubscription -SubscriptionId $SubId |
  Format-List -Property *

# 10. Counting Azure locations
$AZL = Get-AzLocation
$LOC = $AZL | Sort-Object Location
"Azure locations:  [{0}]" -f $LOC.Count

# 11. Viewing Azure locations
$LOC | 
  Format-Table Location, DisplayName

# 12. Getting Azure environments
Get-AzEnvironment |
    Format-Table -Property name, ManagementPortalURL
