# Recipe 10.8 - Implementing FSRM Reporting
#
# Run on SRV1 after you run Recipe 10.7 to install FSRM

# 1. Creating a new FSRM storage report for large files on C:\ on SRV1
$NRHT = @{
  Name             = 'Large Files on SRV1'
  NameSpace        = 'C:\'
  ReportType       = 'LargeFiles'
  LargeFileMinimum = 10MB 
  Interactive      = $true 
}
New-FsrmStorageReport @NRHT

# 2. Getting existing FSRM reports
Get-FsrmStorageReport * | 
  Format-Table -Property Name, NameSpace, 
                         ReportType, ReportFormat

# 3. Viewing Interactive reports available on SRV1
$Path = 'C:\StorageReports\Interactive'
Get-ChildItem -Path $Path

# 4. Viewing the report
$Rep = Get-ChildItem -Path $Path\*.html
Invoke-Item -Path $Rep

# 5. Extracting key information from the FSRM XML output
$XF   = Get-ChildItem -Path $Path\*.xml 
$XML  = [XML] (Get-Content -Path $XF)
$Files = $XML.StorageReport.ReportData.Item
$Files | Where-Object Path -NotMatch '^Windows|^Program|^Users'|
  Format-Table -Property name, path,
    @{ Name ='Sizemb'
       Expression = {(([int]$_.size)/1mb).tostring('N2')}},
       DaysSinceLastAccessed -AutoSize

# 6. Creating a monthly task in task scheduler
$Date = Get-Date '04:20'
$NTHT = @{
  Time    = $Date
  Monthly = 1
}
$Task = New-FsrmScheduledTask @NTHT
$NRHT = @{
  Name             = 'Monthly Files by files group report'
  Namespace        = 'C:\'
  Schedule         = $Task 
  ReportType       = 'FilesbyFileGroup'
  FileGroupINclude = 'Text Files'
  LargeFileMinimum = 25MB
}
New-FsrmStorageReport @NRHT | Out-Null

# 7. Getting details of the task
Get-ScheduledTask | 
  Where-Object TaskName -Match 'Monthly' |
    Format-Table -AutoSize

# 8. Running the task now
Get-ScheduledTask -TaskName '*Monthly*' | 
  Start-ScheduledTask
Get-ScheduledTask -TaskName '*Monthly*'

# 9. Viewing the report in the StorageReports folder
$Path = 'C:\StorageReports\Scheduled'
$Rep = Get-ChildItem -Path $path\*.html
$Rep

# 10. Viewing the report
Invoke-item -Path $Rep




#  cleanup
Unregister-ScheduledTask -TaskName "StorageReport-Monthly report on Big Files" -Confirm:$False
Get-FsrmStorageReport | Remove-FsrmStorageReport