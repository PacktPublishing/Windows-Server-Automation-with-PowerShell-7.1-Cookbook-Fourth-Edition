# Recipe 11.3 - Changing the spooler directory
#
# Run on PSRV - domain joined host in reskit.org domain

# 1. Loading the System.Printing namespace and classes
Add-Type -AssemblyName System.Printing

# 2. Defining the required permissions
$Permissions =
   [System.Printing.PrintSystemDesiredAccess]::AdministrateServer

# 3. Creating a PrintServer object with the required permissions
$NOHT = @{
  TypeName     = 'System.Printing.PrintServer'
  ArgumentList = $Permissions
}
$PS = New-Object @NOHT

# 4. Observing the default spool folder
"The default spool folder is: [{0}]" -f $PS.DefaultSpoolDirectory

# 5. Creating a new spool folder
$NIHT = @{
  Path        = 'C:\SpoolPath'
  ItemType    = 'Directory'
  Force       = $true
  ErrorAction = 'SilentlyContinue'
}
New-Item @NIHT | Out-Null 

# 6. Updating the default spool folder path
$Newpath = 'C:\SpoolPath'
$PS.DefaultSpoolDirectory = $Newpath

# 7. Committing the change
$Ps.Commit()

# 8. Restarting the Spooler to accept the new folder
Restart-Service -Name Spooler

# 9. Verifying the new spooler folder
New-Object -TypeName System.Printing.PrintServer |
  Format-Table -Property Name,
                DefaultSpoolDirectory

#  Another way to set the Spooler directory is by directly editing the registry as follows:

# 10. Stopping the Spooler service
Stop-Service -Name Spooler

# 11. Creating a new spool directory
$SPL = 'C:\SpoolViaRegistry'
$NIHT2 = @{
  Path        = $SPL
  Itemtype    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item  @NIHT2 | Out-Null

# 12. Creating the spooler folder and configuring it in the registry
$RPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\' +
         'Print\Printers'
$IP = @{
  Path    = $RPath
  Name    = 'DefaultSpoolDirectory'
  Value   = $SPL
}
Set-ItemProperty @IP

# 13. Creating the spooler folder and configuring it in the registry
Start-Service -Name Spooler

# 14. Viewing the results
New-Object -TypeName System.Printing.PrintServer |
  Format-Table -Property Name, DefaultSpoolDirectory