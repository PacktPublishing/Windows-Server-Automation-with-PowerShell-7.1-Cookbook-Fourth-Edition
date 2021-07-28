# Recipe 13.2 - Creating Azure Resources
#
# Run on SRV1

# 1. Setting key variables
$Locname    = 'uksouth'     # Location name
$RgName     = 'packt_rg'    # Resource group we are using
$SAName     = 'packt42sa'   # A unique storage account name

# 2. Logging into your Azure Account with the GUI
$Account = Connect-AzAccount

# 3. Creating a resource group and tagging it
$RGTag  = [Ordered] @{Publisher='Packt'
                      Author='Thomas Lee'}
$RGHT = @{
    Name     = $RgName
    Location = $Locname
    Tag      = $RGTag
}
$RG = New-AzResourceGroup @RGHT

# 4. Viewing the resource group with tags
Get-AzResourceGroup -Name $RGName |
    Format-List -Property *

# 5. Testing to see if the storage account name is taken
Get-AzStorageAccountNameAvailability $SAName

# 6. Creating a new storage account
$SAHT = @{
  Name              = $SAName
  SkuName           = 'Standard_LRS'
  ResourceGroupName = $RgName
  Tag               = $RGTag
  Location          = $Locname

}
New-AzStorageAccount @SAHT | Format-List

# 7. Getting an overview of the storage account in this resource group
$SA = Get-AzStorageAccount -ResourceGroupName $RgName
$SA |
  Format-List -Property *


# 8. Getting primary endpoints for the storage account
$SA.PrimaryEndpoints

# 9. Reviewing the SKU
$SA.Sku

# 10. Viewing the storage account's context property
$SA.Context

