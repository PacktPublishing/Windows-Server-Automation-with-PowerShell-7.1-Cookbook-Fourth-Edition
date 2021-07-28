# Recipe 10.2 - Securing your SMB file Server

# Run on SRV2

# 1. Adding File Server features to SRV2
$Features = 'FileAndStorage-Services',
            'File-Services',
            'FS-FileServer',
            'RSAT-File-Services'
Add-WindowsFeature -Name $Features

# 2. Viewing the SMB server settings
Get-SmbServerConfigura
tion

# 3. Turning off SMB1 
$CHT = @{
  EnableSMB1Protocol = $false 
  Confirm            = $false
}
Set-SmbServerConfiguration @CHT

# 4. Turning on SMB signing and encryption
$SHT1 = @{
    RequireSecuritySignature = $true
    EnableSecuritySignature  = $true
    EncryptData              = $true
    Confirm                  = $false
}
Set-SmbServerConfiguration @SHT1

# 5. Turning off default server and workstations shares 
$SHT2 = @{
    AutoShareServer       = $false
    AutoShareWorkstation  = $false
    Confirm               = $false
}
Set-SmbServerConfiguration @SHT2

# 6. Turning off server announcements
$SHT3 = @{
    ServerHidden   = $true
    AnnounceServer = $false
    Confirm        = $false
}
Set-SmbServerConfiguration @SHT3

# 7. Restarting SMB Server service with the new configuration
Restart-Service lanManServer -Force




# For testing
<# undo and set back to defults

Get-SMBShare foo* | remove-SMBShare -Confirm:$False

Set-SmbServerConfiguration -EnableSMB1Protocol $true `
                           -RequireSecuritySignature $false `
                           -EnableSecuritySignature $false `
                           -EncryptData $False `
                           -AutoShareServer $true `
                           -AutoShareWorkstation $false `
                           -ServerHidden $False `
                           -AnnounceServer $True
Restart-Service lanmanserver
#>
