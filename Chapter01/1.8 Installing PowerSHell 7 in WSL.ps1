# 1.8 Installing PowerSHell 7 in WSL
#
#  Run on SRV1 after installing PowerShell 7 etc
#  Run in an elevated console

# 0. Ensure virtualisation is enable in SRV1
#    Run this on VM Host
Stop-VM -VMName SRV1
Set-VMProcessor -VMName SRV1 -ExposeVirtualizationExtensions $true
Start-VM -VMName SRV1

# 1 Install WSL and VMP
$WSLName = 'Microsoft-Windows-Subsystem-Linux'
Enable-WindowsOptionalFeature -Online -FeatureName $WSLName -norestart
$VMPName = 'VirtualMachinePlatform'
Enable-WindowsOptionalFeature -Online -FeatureName $VMPName -NoRestart

# 2. Restart to complete installing WSL on SRV1
Restart-Computer

# 3. Use The GUI to set WinUpdate to get MSFT updates


# 4. Get and run the WSL kernel update
$SourceKU = 'https://wslstorestorage.blob.core.windows.net/wslblob/' +
          'wsl_update_x64.msi'
$TargetKU = 'C:\Foo\wsl_update_X64.msi'
Start-BitsTransfer -Source $SourceKU -Destination $TargetKU  -Verbose
& $Target

# 6. Add Kernel V2
wsl --set-default-version 2
wsl --update

# 7. Download Ubuntu 20.04
# goto https://docs.microsoft.com/en-us/windows/wsl/install-manual to see how to dowunoad other distros
$Source = 'https://aka.ms/wslubuntu2004'
$Target = 'C:\Foo\wslubuntu2004.zip'
Start-BitsTransfer -Source $Source -Destination $Target

# 8. Expand the download into C:\Ubuntu
$Ubuntu = 'C:\Ubuntu'
Expand-Archive  -Path $Target -DestinationPath $Ubuntu
Get-ChildItem -Path $Ubuntu

# 9. Run the Ubuntu installation
C:\Ubuntu\Ubuntu2004.exe

# 10 Use WSL for the first time
