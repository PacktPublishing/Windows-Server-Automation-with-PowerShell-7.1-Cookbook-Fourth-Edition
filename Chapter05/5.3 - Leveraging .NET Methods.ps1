# 5.3 Leveraging .NET methods

# 1. Starting Notepad
notepad.exe

# 2. Obtaining methods on the Notepad process
$Notepad = Get-Process -Name Notepad
$Notepad | Get-Member -MemberType Method

# 3. Using the Kill() method
$Notepad | 
  ForEach-Object {$_.Kill()}

# 4. Confirming Notepad process is destroyed
Get-Process -Name Notepad

# 5. Creating a new folder and some files
$Path = 'C:\Foo\Secure'
New-Item -Path $Path -ItemType directory -ErrorAction SilentlyContinue  |
  Out-Null
1..3 | ForEach-Object {
  "Secure File" | Out-File "$Path\SecureFile$_.txt"
}

# 6. Viewing files in $Path folder
$Files = Get-ChildItem -Path $Path
$Files | Format-Table -Property Name, Attributes

# 7. Encrypting the files
$Files| ForEach-Object Encrypt

# 8. Viewing file attributes
Get-ChildItem -Path $Path |
  Format-Table -Property Name, Attributes

# 9. Decrypting and viewing the files
$Files| ForEach-Object {
  $_.Decrypt()
}
Get-ChildItem -Path $Path |
  Format-Table -Property Name, Attributes
