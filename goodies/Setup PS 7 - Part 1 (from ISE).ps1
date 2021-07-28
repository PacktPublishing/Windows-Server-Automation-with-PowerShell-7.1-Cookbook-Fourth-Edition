#requires –RunAsAdministrator
# mondo script to setup a VM - Part 1
#
# Run INSIDE the VM inside an elevated PowerShell 5.1 ISE Console

# 1. Set Execution Policy for Windows PowerShell
Write-Host 'Setting Execution Policy'
Set-ExecutionPolicy -ExecutionPolicy Unrestricted  -Force

# 2. Install the latest versions of Nuget and PowerShellGet
Register-PSRepository -default -ErrorAction silentlycontinue # in case
Write-Host 'Updating PowerShellGet and Nuget'
Install-PackageProvider Nuget -MinimumVersion 2.8.5.201 -Force |
  Out-Null
Get-Module | Remove-Module -Force
Install-Module -Name PowerShellGet -Force -AllowClobber 

# 3. Ensure the C:\Foo Folder exists
Write-Host 'Creating C:\Foo'
$LFHT = @{
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue' # should it already exist
}
New-Item -Path C:\Foo @LFHT | Out-Null

# 4. Download PowerShell 7.1 installation script
Write-Host "Downloading Pwsh 7.1 installation script"
Set-Location C:\Foo
$URI = 'https://aka.ms/install-powershell.ps1'
Invoke-RestMethod -Uri $URI | 
  Out-File -FilePath C:\Foo\Install-PowerShell.ps1

# 5. Install PowerShell 7
Write-Host "Installing Pwsh 7.1"
$EXTHT = @{
  UseMSI                 = $true
  Quiet                  = $true 
  AddExplorerContextMenu = $true
  EnablePSRemoting       = $true
}
C:\Foo\Install-PowerShell.ps1 @EXTHT | Out-Null

# 6. For the Adventurous - install the preview and daily builds as well
Write-Host "Installing Pwsh 7.2 preview"
C:\Foo\Install-PowerShell.ps1 -Preview -Destination C:\PSPreview |
  Out-Null
Write-Host "Installing Pwsh 7.2 Daily Build"
C:\Foo\Install-PowerShell.ps1 -Daily   -Destination C:\PSDailyBuild |
  Out-Null

# 7. Create Windows PowerShell default Profiles
#    NB: You create PowerShell 7 profiles in a later script
Write-Host "Creating default Windows PowerShell profiles"
$URI = 'https://raw.githubusercontent.com/doctordns/Wiley20/master/' +
       'Goodies/Microsoft.PowerShell_Profile.ps1'
$ProfileFile = $Profile.CurrentUserCurrentHost
New-Item $ProfileFile -Force -WarningAction SilentlyContinue |
   Out-Null
(Invoke-WebRequest -Uri $URI).Content | 
  Out-File -FilePath  $ProfileFile
$ProfilePath = Split-Path -Path $ProfileFile
$ConsoleProfile = Join-Path -Path $ProfilePath -ChildPath 'Microsoft.PowerShell_profile.ps1'
(Invoke-WebRequest -Uri $URI).Content | 
  Out-File -FilePath  $ConsoleProfile

# 8. Download the VS Code installation script from PS Gallery
Write-Host "Download VS Code Installation Script"
$VSCPATH = 'C:\Foo'
Save-Script -Name Install-VSCode -Path $VSCPATH
Set-Location -Path $VSCPATH

# 9. Run the installation script and add in some popular extensions
#   NB: sometimes this flakes out and does NOT actually install VS Code -= just rerun this stwp
Write-Host "Installing VS Code"
$Extensions =  'Streetsidesoftware.code-spell-checker',
               'yzhang.markdown-all-in-one',
               'hediet.vscode-drawio'
$InstallHT = @{
  BuildEdition         = 'Stable-System'
  AdditionalExtensions = $Extensions
  LaunchWhenDone       = $true
}             
.\Install-VSCode.ps1 @InstallHT -ea 0 | Out-Null

# 10. Define registry path for autologon, then set admin logon
Write-Verbose -Message 'Setting Autologon'
$RegPath  = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
$User     = 'Administrator'
$Password = 'Pa$$w0rd'
$Dom      = 'Reskit'  
Set-ItemProperty -Path $RegPath -Name DefaultUserName   -Value $User     -EA 0  
Set-ItemProperty -Path $RegPath -Name DefaultPassword   -Value $Password -EA 0
Set-ItemProperty -Path $RegPath -Name DefaultDomainName -Value $Dom      -EA 0 
Set-ItemProperty -Path $RegPath -Name AutoAdminLogon    -Value 1         -EA 0  

# 11. Set the PowerConfig to not turn off the virtual monitor
Write-Verbose -Message 'Setting Monitor poweroff to zero'
powercfg /change monitor-timeout-ac 0

# 12. All done with Windows PowerShell
Write-Host "Close VS code, restart as admin and do part 2 inside VS Code"
Write-Host "Make sure you use an elevated VS CODE!!"

