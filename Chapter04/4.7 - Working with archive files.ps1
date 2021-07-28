# 4.7 - Working with Archive Files

# Run on SRV1


# 1. Getting archive module
Get-Module -Name Microsoft.Powershell.Archive -ListAvailable

# 2. Discovering commands in archive module
Get-Command -Module Microsoft.PowerShell.Archive

# 3. Making a new folder
$NIHT = @{
  Name        = 'Archive'
  Path        = 'C:\Foo'
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item @NIHT | Out-Null

# 4. Creating files in the archive folder
$Contents = "Have a Nice day with PowerShell and WIndows Server" * 1000
1..100 | 
  ForEach-Object {
    $FName = "C:\Foo\Archive\Archive_$_.txt"
    New-Item -Path $FName -ItemType File  | Out-Null
    $Contents | Out-File -FilePath $FName
}

# 5. Measuring files to archive
$Files = Get-ChildItem -Path 'C:\Foo\Archive'
$Count = $Files.Count
$LenKB = (($Files | Measure-Object -Property length -Sum).Sum)/1mb
"[{0}] files, occupying {1:n2}mb" -f $Count, $LenKB

# 6. Compressing a set of files into an archive
$AFILE1 = 'C:\Foo\Archive1.zip'
Compress-Archive -Path $Files -DestinationPath "$AFile1"

# 7. Compressing a folder containing files
$AFILE2 = 'C:\Foo\Archive2.zip'
Compress-Archive -Path "C:\Foo\Archive" -DestinationPath $AFile2

# 8. Viewing the archive files
Get-ChildItem -Path $AFILE1, $Afile2

# 9. Viewing archive content with Windows Explorer
explorer.exe $AFILE1

# 10. Viewing second archive with Windows Explorer
explorer.exe $AFILE2

# 11. Making new output folder
$Opath = 'C:\Foo\Decompressed'
$NIHT2 = @{
  Path        = $Opath
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue'
}
New-Item @NIHT2 | Out-Null

# 12. Decompress the Archive1.zip archive
Expand-Archive -Path $AFILE1 -DestinationPath $Opath

# 13. Measuring the size of the decompressed files
$Files = Get-ChildItem -Path $Opath
$Count = $Files.Count
$LenKB = (($Files | Measure-Object -Property length -Sum).Sum)/1mb
"[{0}] decompressed files, occupying {1:n2}mb" -f $Count, $LenKB
