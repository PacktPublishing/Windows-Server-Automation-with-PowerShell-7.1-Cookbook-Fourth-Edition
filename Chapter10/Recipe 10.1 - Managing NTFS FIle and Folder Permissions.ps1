# Recipe 10.1 - Managing NTFS FIle and Folder Permissions
# 
# Run on SRV2 -After creating F: on Disk 1.

# 1. Downloading NTFSSecurity module from PSGallery
Install-Module NTFSSecurity -Force

# 2. Getting commands in the module
Get-Command -Module NTFSSecurity 

# 3. Creating a new folder and a file in the folder
New-Item -Path F:\Secure1 -ItemType Directory |
    Out-Null
"Secure" | Out-File -FilePath F:\Secure1\Secure.Txt
Get-ChildItem -Path F:\Secure1

# 4. Viewing ACL of the folder
Get-NTFSAccess -Path F:\Secure1 |
  Format-Table -AutoSize

# 5. Viewing ACL of the file
Get-NTFSAccess F:\Secure1\Secure.Txt |
  Format-Table -AutoSize

# 6. Creating the Sales group in AD if it does not exist
$SB = {
  try {
    Get-ADGroup -Identity 'Sales' -ErrorAction Stop
  }
  catch {
    New-ADGroup -Name Sales -GroupScope Global |
      Out-Null
  }
}
Invoke-Command -ComputerName DC1 -ScriptBlock $SB

# 7. Displaying Sales AD Group
Invoke-Command -ComputerName DC1 -ScriptBlock {
                                   Get-ADGroup -Identity Sales}

# 8. Addding explicit full control for DomainAdmins
$AHT1 = @{
  Path         = 'F:\Secure1'
  Account      = 'Reskit\Domain Admins' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AHT1

# 9. Removing builtin\users access from secure.txt file
$AHT2 = @{
  Path         = 'F:\Secure1\Secure.Txt'
  Account      = 'Builtin\Users'
  AccessRights = 'FullControl'
}  
Remove-NTFSAccess @AHT2

# 10. Removing inherited rights for the folder:
$IRHT1 = @{
  Path                       = 'F:\Secure1'
  RemoveInheritedAccessRules = $True
}
Disable-NTFSAccessInheritance @IRHT1

# 11. Adding Sales group access to the folder
$AHT3 = @{
  Path         = 'F:\Secure1\'
  Account      = 'Reskit\Sales' 
  AccessRights = 'FullControl'
}
Add-NTFSAccess @AHT3

# 12. Getting ACL on path
Get-NTFSAccess -Path F:\Secure1 |
  Format-Table -AutoSize

# 13. Getting resulting ACL on the file
Get-NTFSAccess -Path F:\Secure1\Secure.Txt |
  Format-Table -AutoSize
