# Recipe 13.3 - Exploring the Azure Storage Account

# Run from SRV1

# 1. Define key variables
$Locname    = 'uksouth'         # location name
$RgName     = 'packt_rg'        # resource group we are using
$SAName     = 'packt42sa'       # storage account name
$CName      = 'packtcontainer'  # a blob container name
$CName2     = 'packtcontainer2' # a second blob container name

# 2. Connecting to your Azure account and ensure the RG and SA is created.
$Account = Connect-AzAccount 

# 3. Getting and displaying the storage account key
$SAKHT = @{
    Name              = $SAName
    ResourceGroupName = $RgName
}
$Sak = Get-AzStorageAccountKey  @SAKHT
$Sak

# 4. Extracting the first key's 'password'
$Key = ($Sak | Select-Object -First 1).Value

# 5. Getting the Storage Account context which encapsulates credentials
#   for the storage account)
$SCHT = @{
    StorageAccountName = $SAName
    StorageAccountKey = $Key
}
$SACon = New-AzStorageContext @SCHT
$SACon

# 6. Creating 2 blob containers
$CHT = @{
  Context    = $SACon
  Permission = 'Blob'
}
New-AzStorageContainer -Name $CName @CHT
New-AzStorageContainer -Name $CName2 @CHT

# 7. View blob containers
Get-AzStorageContainer -Context $SACon |
    Select-Object -ExpandProperty CloudBlobContainer

# 8. Creating a blob
'This is a small Azure blob!!' | Out-File .\azurefile.txt
$BHT = @{
    Context = $SACon
    File = '.\azurefile.txt'
    Container = $CName
}
$Blob = Set-AzStorageBlobContent  @BHT
$Blob

# 9. Constructing and displaying the blob name
$BlobUrl = "$($Blob.Context.BlobEndPoint)$CName/$($Blob.name)"
$BlobUrl

# 10. Downloading and viewing the blob
$OutFile = 'C:\Foo\Test.Txt'
Start-BitsTransfer -Source $BlobUrl -Destination $OutFile
Get-Content -Path $OutFile