# 3.2 Using the Windows PowerSHell Compatibility solution
#
# run on SRV1 after loading PowerSHerll 7/VS Code.


# 1. Discovering the Server Manager module
Get-Module -Name ServerManager -ListAvailable

# 2. Discovering a command in the Server Manager module
Get-Command -Name Get-WindowsFeature

# 3. Importing the module explicitly
Import-Module -Name ServerManager

# 4. Discovering the module again
Get-Module -Name ServerManager | Format-List

# 5. Using a command in the ServerManager module
Get-WindowsFeature -Name TFTP-Client

# 6. Running the command in a remoting session
$Session = Get-PSSession -Name WInPSCompatSession
Invoke-Command -Session $Session -ScriptBlock {
  Get-WindowsFeature -Name 'TFTP-Client' |
    Format-Table
}

# 7. Removing the ServerManager module from the current session
Get-Module -Name ServerManager |
  Remove-Module

# 8. Installing a Windows feature using module autoload
Install-WindowsFeature -Name TFTP-Client 

# 9. Discovering the feature
Get-WindowsFeature -Name TFTP-Client

# 10. View output inside Windows PowerShell session
Invoke-Command -Session $Session -ScriptBlock {
    Get-WindowsFeature -Name 'TFTP-Client' |
      Format-Table
}