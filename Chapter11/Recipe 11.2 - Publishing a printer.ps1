# Recipe 11.2 - Publishing a printer
#
# Run on PSRV - domain joined host in reskit.org domain
# Uses Printer added in 11.1

# 1. Getting the printer to publish and store the returned object in $Printer
$Printer = Get-Printer -Name SalesPrinter1

# 2. Viewing the printer details
$Printer | Format-Table -Property Name, Published

# 3. Publishing and sharing the printer to AD
$Printer | Set-Printer -Location '10th floor 10E4'
$Printer | Set-Printer -Shared $true -Published $true

# 4. Viewing the updated publication status
Get-Printer -Name SalesPrinter1 |
  Format-Table -Property Name, Location, Drivername, Published
