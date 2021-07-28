# Recipe 5.2 - Setting up and securing SMB file server
#
# Run from SRV2

# 1. Discovering existing shares and access rights
Get-SmbShare -Name * | 
  Get-SmbShareAccess |
    Format-Table -GroupBy Name

# 2. Sharing a new folder 
New-Item -Path C:\ -Name ITShare -ItemType Directory |
  Out-Null
New-SmbShare -Name ITShare -Path C:\ITShare

# 3. Updating the share to have a description
$CHT = @{Confirm=$False}
Set-SmbShare -Name ITShare -Description 'File Share for IT' @CHT

# 4. Setting folder enumeration mode
$CHT = @{Confirm = $false}
Set-SMBShare -Name ITShare -FolderEnumerationMode AccessBased @CHT

# 5. Setting encryption on for ITShare share
Set-SmbShare -Name ITShare -EncryptData $true @CHT

# 6. Removing all access to ITShare share for the Everyone group
$AHT1 = @{
  Name        =  'ITShare'
  AccountName = 'Everyone'
  Confirm     =  $false
}
Revoke-SmbShareAccess @AHT1 | Out-Null

# 7. Adding Reskit\Administrators to have read permission
$AHT2 = @{
    Name         = 'ITShare'
    AccessRight  = 'Read'
    AccountName  = 'Reskit\ADMINISTRATOR'
    ConFirm      =  $false 
} 
Grant-SmbShareAccess @AHT2 | Out-Null

# 8. Adding system full access
$AHT3 = @{
    Name          = 'ITShare'
    AccessRight   = 'Full'
    AccountName   = 'NT Authority\SYSTEM'
    Confirm       = $False 
}
Grant-SmbShareAccess  @AHT3 | Out-Null

# 9. Setting Creator/Owner to Full Access
$AHT4 = @{
    Name         = 'ITShare'
    AccessRight  = 'Full'
    AccountName  = 'CREATOR OWNER'
    Confirm      = $False 
}
Grant-SmbShareAccess @AHT4  | Out-Null

# 10. Granting Sales group read access, SalesAdmins has Full access
$AHT5 = @{
    Name        = 'ITShare'
    AccessRight = 'Read'
    AccountName = 'Sales'
    Confirm     = $false 
}
Grant-SmbShareAccess @AHT5 | Out-Null

# 11. Reviewing share access
Get-SmbShareAccess -Name ITShare | 
  Sort-Object AccessRight

# 12. Set file ACL to be same as share acl
Set-SmbPathAcl -ShareName 'ITShare'

# 13. Creating a file in C:\ITShare
'File Contents' | Out-File -FilePath C:\ITShare\File.Txt

# 14. Setting file ACL to be same as share ACL
Set-SmbPathAcl -ShareName 'ITShare'

# 15. Viewing file ACL
Get-NTFSAccess -Path C:\ITShare\File.Txt |
  Format-Table -AutoSize
  




# For testing

<# reset the shares 
Get-smbshare ITShare| Remove-SmbShare -Confirm:$false

#>
