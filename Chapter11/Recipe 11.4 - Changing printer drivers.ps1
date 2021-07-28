# Recipe 11.4 -  Change Printer Drivers
#
# Run on Psrv - domain joined host in reskit.org domain

# 1. Adding the print driver for the new printing device
$M2 = 'Xerox WorkCentre 6515 PCL6'
Add-PrinterDriver -Name $M2

# 2. Getting the Sales group printer object and store it in $Printer
$Printern = 'SalesPrinter1'
$Printer  = Get-Printer -Name $Printern

# 3. Updating the driver using the Set-Printer cmdlet
$Printer | Set-Printer -DriverName $M2

# 4. Observing the updated printer driver
Get-Printer -Name $Printern | 
  Format-Table -Property Name, DriverName, PortName, 
                Published, Shared