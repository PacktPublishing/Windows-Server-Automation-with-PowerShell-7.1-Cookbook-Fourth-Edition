# Recipe 13.4 -  Creating an Azure file Share

# Run from SRV1

# 1.  Defining variables
$Locname   = 'uksouth'      # location name
$RgName    = 'packt_rg'     # resource group we are using
$SAName    = 'packt42sa'    # storage account name
$ShareName = 'packtshare'   # must be lower case!

# 2. Logging in to your Azure account
$Account = Connect-AzAccount 

# 3. Getting storage account, account key and context
$SA = Get-AzStorageAccount -ResourceGroupName $Rgname 
$SAKHT = @{
    Name              = $SAName
    ResourceGroupName = $RgName
}
$Sak = Get-AzStorageAccountKey @SAKHT
$Key = ($Sak | Select-Object -First 1).Value
$SCHT = @{
    StorageAccountName = $SAName
    StorageAccountKey  = $Key
}
$SACon = New-AzStorageContext @SCHT

# 4. Adding credentials to the local credentials store
$T = "$SAName.file.core.windows.net"
cmdkey /add:$T /user:"AZURE\$SAName" /pass:$Key

# 5. Creating an Azure share
New-AzStorageShare -Name $ShareName -Context $SACon

# 6. Checking that the share is reachable
$TNCHT = @{
  ComputerName = "$SAName.file.core.windows.net"
  Port         = 445
}
Test-NetConnection @TNCHT

# 7. Mounting the share as M:
$Mount = 'M:'
$Rshare = "\\$SAName.file.core.windows.net\$ShareName"
$SMHT = @{
    LocalPath  = $Mount 
    RemotePath = $Rshare 
    UserName   = $SAName 
    Password   = $Key
}
New-SmbMapping @SMHT

# 8. Viewing the share in Azure
Get-AzStorageShare -Context $SACon  |
    Format-List -Property *

# 9. Viewing local SMB mappings
Get-SmbMapping -LocalPath M:

# 10. Creating a file in the share
New-Item -Path M:\Foo -ItemType Directory | Out-Null
'Azure and PowerShell 7 Rock!!!' |
   Out-File -FilePath M:\Foo\Recipe.Txt

# 11. Retrieving details about the share contents
Get-ChildItem -Path M:\ -Recurse |
    Format-Table -Property FullName, Mode, Length

# 12. Getting the content from the file
Get-Content -Path M:\Foo\Recipe.txt

# 13. Cleaning up - removing data from the share
Remove-Item -Path M: -Force -Recurse -ErrorAction SilentlyContinue

# 14. Cleaning up - removing SMB mapping
Get-SmbMapping -LocalPath M: | 
  Remove-SmbMapping -Force

# 15. Removing the Azure share 
Get-AzStorageShare -Name $ShareName -Context $SACon | 
  Remove-AzStorageShare 