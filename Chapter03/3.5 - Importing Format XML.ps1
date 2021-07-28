# 3.5 Importing Format XML

# Run on SRV1


# 1.Importing the Server Manager Module
Import-Module -Name ServerManager

# 2. Checking a Windows Feature
Get-WindowsFeature -Name Simple-TCPIP

# 3 Running this command in the compatibility session 
$S = Get-PSSession -Name 'WinPSCompatSession'
Invoke-Command -Session $S -ScriptBlock {
    Get-WindowsFeature -Name Simple-TCPIP }

# 4. Running this command with formatting in the remote session
Invoke-Command -Session $S -ScriptBlock {
                    Get-WindowsFeature -Name Simple-TCPIP | 
                      Format-Table}   

# 5. Getting path to Windows PowerShell modules
$Paths = $env:PSModulePath -split ';' 
foreach ($Path in $Paths) {
  if ($Path -match 'system32') {$S32Path = $Path; break}
}
"System32 path: [$S32Path]"

# 6. Displaying path to the format XML for Server Manager module
$FXML = "$S32path/ServerManager"
$FF = Get-ChildItem -Path $FXML\*.format.ps1xml 
"Format XML file: [$FF]"

# 7. Updating the format XML
Foreach ($F in $FF) {
  Update-FormatData -PrependPath $F.FullName} 

# 8. Viewing the Windows Simple-TCPIP feature
Get-WindowsFeature -Name Simple-TCPIP

# 9. Adding Simple-TCP Services
Add-WindowsFeature -Name Simple-TCPIP

# 10. Examining Simple-TCPIP feature
Get-WindowsFeature -Name Simple-TCPIP

# 11. Using the Simple TCPIP feature
Install-WindowsFeature Telnet-Client |
  OUt-Null
Start-Service -Name simptcp

# 12. Using the quote of the day service
Telnet SRV1 qotd
