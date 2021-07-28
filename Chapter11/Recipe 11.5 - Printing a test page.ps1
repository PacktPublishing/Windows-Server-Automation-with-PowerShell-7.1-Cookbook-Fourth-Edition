# Recipe 11.5 - Printing a test page
#
# Run on PSRV  - domain joined host in reskit.org domain
# run after installing and configuring the printer server.

# 1. Getting the printer objects from WMI
$Printers = Get-CimInstance -ClassName Win32_Printer

# 2. Displaying the number of printers defined on PSRV
'{0} Printers defined on this system' -f $Printers.Count

# 3. Getting the Sales Group printer WMI object
$Printer = $Printers |
  Where-Object Name -eq 'SalesPrinter1'

# 4. Displying the printer's details
$Printer | Format-Table -AutoSize

# 5. Printing a test page
Invoke-CimMethod -InputObject $Printer -MethodName PrintTestPage

# 6. Checking on print job
Get-PrintJob -Printer SalesPrinter1