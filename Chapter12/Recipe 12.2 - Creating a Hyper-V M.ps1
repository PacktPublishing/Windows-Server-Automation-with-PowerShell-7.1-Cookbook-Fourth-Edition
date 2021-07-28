# Recipe 12.2 - Creating a Hyper-V VM

# run on HV1 - having downloaded the ISO image from
# https://www.microsoft.com/en-gb/evalcenter/evaluate-windows-server-2019

# 1. Setting up the VM name and paths for this recipe
$VMname      = 'PSDirect'
$VMLocation  = 'C:\VM\VMS'
$VHDlocation = 'C:\VM\VHDS'
$VhdPath     = "$VHDlocation\PSDirect.Vhdx"
$ISOPath     = 'C:\Builds\en_windows_server_x64.iso'
If ( -not (Test-Path -Path $ISOPath -PathType Leaf)) {
  Throw "Windows Server ISO DOES NOT EXIST" 
}

# 2.  Creating a new VM
New-VM -Name $VMname -Path $VMLocation -MemoryStartupBytes 1GB

# 3. Creating a virtual disk file for the VM
New-VHD -Path $VhdPath -SizeBytes 128GB -Dynamic | Out-Null

# 4. Adding the virtual hard drive to the VM
Add-VMHardDiskDrive -VMName $VMname -Path $VhdPath

# 5. Setting ISO image in the VM's DVD drive
$IHT = @{
  VMName           = $VMName
  ControllerNumber = 1
  Path             = $ISOPath
}
Set-VMDvdDrive @IHT

# 6. Starting the VM
Start-VM -VMname $VMname 

# 7. Viewing the VM
Get-VM -Name $VMname
