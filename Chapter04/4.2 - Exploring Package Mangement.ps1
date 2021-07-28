# Recipe 4.2 - Exploring Package Management
#
# Run from SRV1 

# 1. Reviewing the cmdlets in the PackageManagement module
Get-Command -Module PackageManagement

# 2. Reviewing installed providers with Get-PackageProvider
Get-PackageProvider | 
  Format-Table -Property Name, 
                         Version, 
                         SupportedFileExtensions,
                         FromTrustedSource

# 3. Examining available Package Providers
$PROVIDERS = Find-PackageProvider
$PROVIDERS |
    Select-Object -Property Name,Summary |
      Format-Table -AutoSize -Wrap

# 4. Discovering and counting available packages
$PACKAGES = Find-Package
"Discovered {0:N0} packages" -f $PACKAGES.Count

# 5. Showing first 5 packages discovered
$PACKAGES  |
    Select-Object -First 5 |
      Format-Table -AutoSize -Wrap

# 6. Installing the Chocolatier provider
Install-PackageProvider -Name Chocolatier -Force |
  Out-Null

# 7. Verifying Chocolatier is in the list of installed providers
Get-PackageProvider |
  Select-Object -Property Name,Version

# 8. Discovering Packages from Chocolatier
$Start = Get-Date
$CPackages = Find-Package -ProviderName Chocolatier -Name *
"$($CPackages.Count) packages available from Chocolatey"
$End = Get-Date

# 9. Displaying how long it took for Chocolatier
$Elapsed = $End - $Start
"Took {0:n3} seconds" -f $Elapsed.TotalSeconds
