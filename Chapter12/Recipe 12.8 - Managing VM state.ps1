# Recipe 12.8 - Managing VM state

# Run on HV1

# 1. Getting the VM's state to check if it is off
Stop-VM -Name PSDirect -WarningAction SilentlyContinue
Get-VM -Name PSDirect

# 2. Starting the VM
Start-VM -VMName PSDirect
Wait-VM -VMName PSDirect -For IPAddress
Get-VM -VMName PSDirect

# 3. Suspending and viewing the PSDirect VM
Suspend-VM -VMName PSDirect
Get-VM -VMName PSDirect

# 4. Resuming the PSDirect VM
Resume-VM -VMName PSDirect
Get-VM -VMName PSDirect

# 5. Saving the VM
Save-VM -VMName PSDirect
Get-VM -VMName PSDirect

# 6. Resuming the saved VM and viewing the status
Start-VM -VMName PSDirect
Get-VM -VMName PSDirect

# 7. Restarting the PSDirect VM
Restart-VM -VMName PSDirect -Force
Get-VM     -VMName PSDirect

# 8. Waiting for the PSDirect VM to get an IP address
Wait-VM    -VMName PSDirect -For IPaddress
Get-VM     -VMName PSDirect

# 9. Performing a hard power off on the PSDirect VM
Stop-VM -VMName PSDirect -TurnOff
Get-VM  -VMname PSDirect