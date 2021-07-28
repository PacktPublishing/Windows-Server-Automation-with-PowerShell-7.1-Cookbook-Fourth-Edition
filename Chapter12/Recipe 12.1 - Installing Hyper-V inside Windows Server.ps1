# Recipe 12.1 - Installing Hyper-V inside Windows Server

# Run on HV1

# 1. Installing the Hyper-V feature on HV1, HV2
$SB = {
  Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
}
Invoke-Command -ComputerName HV1, HV2 -ScriptBlock $Sb

# 2. Rebooting the servers to complete the installation
Restart-Computer -ComputerName HV2 -Force 
Restart-Computer -ComputerName HV1 -Force 

# 3. Creating a PSSession with both HV Servers (after reboot)
$S = New-PSSession HV1, HV2

# 4. Creating and setting the location for VMs and VHDs on HV1 and HV2
$SB = {
    New-Item -Path C:\VM -ItemType Directory -Force |
        Out-Null
    New-Item -Path C:\VM\VHDS -ItemType Directory -Force |
        Out-Null
    New-Item -Path C:\VM\VMS -ItemType Directory -force |
        Out-Null
}        
Invoke-Command -ScriptBlock $SB -Session $S | Out-Null

# 5. Setting default paths for Hyper-V VM disk/config information
$SB = {
  $VHDS = 'C:\VM\VHDS'
  $VMS  = 'C:\VM\VMS'
  Set-VMHost -ComputerName Localhost -VirtualHardDiskPath $VHDS
  Set-VMHost -ComputerName Localhost -VirtualMachinePath $VMS
}
Invoke-Command -ScriptBlock $SB -Session $S

# 6. Setting NUMA spanning
$SB = {
  Set-VMHost -NumaSpanningEnabled $true
}
Invoke-Command -ScriptBlock $SB -Session $S

# 7. Setting EnhancedSessionMode
$SB = {
 Set-VMHost -EnableEnhancedSessionMode $true
}
Invoke-Command -ScriptBlock $SB -Session $S

# 8. Setting host resource metering on HV1, HV2
$SB = {
 $RMInterval = New-TimeSpan -Hours 0 -Minutes 15
 Set-VMHost -ResourceMeteringSaveInterval $RMInterval
}
Invoke-Command -ScriptBlock $SB -Session $S

# 9. Reviewing key VM host settings
$SB = {
  Get-VMHost 
}
$P = 'Name', 'V*Path','Numasp*', 'Ena*','RES*'
Invoke-Command -Scriptblock $SB -Session $S |
  Format-Table -Property $P