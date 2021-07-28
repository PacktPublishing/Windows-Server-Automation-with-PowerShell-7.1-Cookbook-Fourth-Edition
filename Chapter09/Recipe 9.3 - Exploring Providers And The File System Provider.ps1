# 9.3 - Exploring Providers And The File System Provider

# Run on SRV1

# 1. Getting providers  
Get-PSProvider

# 2. Getting registry drives
Get-PSDrive | Where-Object Provider -match 'registry'

# 3. Loooking at a registry key
$Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
Get-Item -Path $Path

# 4. Getting registered owner
(Get-ItemProperty -Path $Path -Name RegisteredOwner).RegisteredOwner

# 5. Counting aliases in the Alias: drive
Get-Item Alias:* | Measure-Object

# 6. Finding aliases for Remove-Item
Get-Childitem Alias:* | 
  Where-Object ResolvedCommand -match 'Remove-item$'

# 7. Counting environment variables on SRV1
Get-Item ENV:* | Measure-Object

# 8. Displaying Windows installation folder
"Windows installation folder is [$env:windir]"

# 9. Checking on FileSystem provider drives on SRV1
Get-PSProvider -PSProvider FileSystem | 
  Select-Object -ExpandProperty Drives |
    Sort-Object -Property Name

# 10. Getting home folder for FileSystem provider
$HF = Get-PSProvider -PSProvider FileSystem | 
  Select-Object -ExpandProperty Home    

# 11. Checking Function drive
Get-Module | Remove-Module -WarningAction SilentlyContinue
$Functions = Get-ChildItem -Path Function:
"Functions available [$($Functions.Count)]"

# 12. Creating a new function
Function Get-HelloWorld {'Hello World'}

# 13. Checking Function drive
$Functions2 = Get-ChildItem -Path Function:
"Functions now available [$($Functions2.Count)]"

# 14. Viewing function definition
Get-Item Function:\Get-HelloWorld | Format-List *

# 15. Counting defined variables
$Variables = Get-ChildItem -Path Variable:
"Variables defined [$($Variables.count)]"

# 16. Checking on on available functions 
Get-Item Variable:Function*

# 17. Getting trusted root certificates for the local machine
Get-ChildItem -Path Cert:\LocalMachine\Root | 
  Format-Table FriendlyName, Thumbprint

# 18. Examining ports in use by WinRM
Get-ChildItem -Path WSMan:\localhost\Client\DefaultPorts
Get-ChildItem -Path WSMan:\localhost\Service\DefaultPorts

# 19. Setting Trusted Hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force

# 20. Installing SHIPS and CimPSDrive modules
Install-Module -Name SHiPS, CimPSDrive -Force

# 21. Importing the CimPSDrive module and creating a drive
Import-Module -Name CimPSDrive
New-PSDrive -Name CIM -PSProvider SHiPS -Root CIMPSDrive#CMRoot

# 22. Examining BIOS
Get-ChildItem CIM:\Localhost\CIMV2\Win32_Bios
