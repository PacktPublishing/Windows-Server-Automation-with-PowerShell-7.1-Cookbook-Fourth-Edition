# Recipe 4.4 - Creating an internal PowerShell repository

# Run on SRV1

# 1. Creating repository folder
$LPATH = 'C:\RKRepo'
New-Item -Path $LPATH -ItemType Directory | Out-Null

# 2. Sharing the folder
$SMBHT = @{
  Name        = 'RKRepo' 
  Path        = $LPATH 
  Description = 'Reskit Repository'
  FullAccess  = 'Everyone'
}
New-SmbShare @SMBHT

# 3. Registering the repository as trusted (on SRV1)
$Path = '\\SRV1\RKRepo'
$REPOHT = @{
  Name               = 'RKRepo'
  SourceLocation     = $Path
  PublishLocation    = $Path
  InstallationPolicy = 'Trusted'
}
Register-PSRepository @REPOHT

# 4. Viewing configured repositories
Get-PSRepository

# 5. Creating a Hello World module folder
$HWDIR = 'C:\HW'
New-Item -Path $HWDIR -ItemType Directory | Out-Null

# 6. Creating a very simple module
$HS = @"
Function Get-HelloWorld {'Hello World'}
Set-Alias GHW Get-HelloWorld
"@
$HS | Out-File $HWDIR\HW.psm1

# 7. Testing the module locally
Import-Module -Name $HWDIR\HW.PSM1 -Verbose
GHW

# 8. Creating a PowerShell module manifest for the new module
$NMHT = @{
  Path              = "$HWDIR\HW.psd1" 
  RootModule        = 'HW.psm1' 
  Description       = 'Hello World module' 
  Author            = 'DoctorDNS@Gmail.com' 
  FunctionsToExport = 'Get-HelloWorld'
  ModuleVersion     = '1.0.1'
}
New-ModuleManifest @NMHT

# 9. Publishing the module
Publish-Module -Path $HWDIR -Repository RKRepo -Force

# 10. Viewing the results of publishing
Find-Module -Repository RKRepo

# 11. Checking the repository's home folder
Get-ChildItem -Path $LPATH

