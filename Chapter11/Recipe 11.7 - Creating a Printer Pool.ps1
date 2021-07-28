# Recipe 11.7 - create a Printer Pool
#
# Run on PSRV  - domain joined host in reskit.org domain

# 1. Adding a port for the printer 
$P = 'SalesPP2' # new printer port name
Add-PrinterPort -Name $P -PrinterHostAddress 10.10.10.62 

# 2. Creating the printer pool for SalesPrinter1
$Printer = 'SalesPrinter1'
$P1      = 'SalesPP'   # First printer port
$P2      = 'SalesPP2'  # Second printer port
rundll32.exe printui.dll,PrintUIEntry /Xs /n $Printer Portname "$P1,$P2"

# 3. Viewing the printer pool
Get-Printer $Printer |
   Format-Table -Property Name, Type, DriverName, PortName -AutoSize

