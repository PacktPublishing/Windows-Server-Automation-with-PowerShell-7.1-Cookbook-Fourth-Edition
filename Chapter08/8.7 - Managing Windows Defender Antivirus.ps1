# 8.7 - Managing Windows Defender Anti-Virus

# Run on DC1

# 1. Ensuring Defender and tools are associated installed
$DHT = @{
  Name                   =  'Windows-Defender' 
  IncludeManagementTools = $true  
}
$Defender = Install-WindowsFeature @DHT
If ($Defender.RestartNeeded -eq 'Yes') {
  Restart-Computer
}

# 2. Discovering the cmdlets in the Defender module
Import-Module -Name Defender
Get-Command -Module Defender

# 3. Checking the Defender service status
Get-Service  -Name WinDefend

# 4. Checking the operational status of Defender on this host
Get-MpComputerStatus 

# 5. Getting and counting threat catalog
$ThreatCatalog = Get-MpThreatCatalog
"There are $($ThreatCatalog.count) threats in the catalog"

# 6. Viewing five threats in the catalog
$ThreatCatalog |
  Select-Object -First 5 |
    Format-Table -Property SeverityID, ThreatID, ThreatName

# 7. Setting key settings
# Enable real-time monitoring
Set-MpPreference -DisableRealtimeMonitoring 0
# Enable sample submission
Set-MpPreference -SubmitSamplesConsent Always
# Enable checking signatures before scanning
Set-MpPreference -CheckForSignaturesBeforeRunningScan 1
# Enable email scanning
Set-MpPreference -DisableEmailScanning 0

# 8. Creating a false positive threat
$TF = 'C:\Foo\FalsePositive1.Txt'
$FP = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-' +
      'STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
$FP | Out-File -FilePath $TF
Get-Content -Path $TF

# 9. Running a quick scan on C:\Foo
$ScanType = 'QuickScan'
Start-MpScan -ScanType $ScanType -ScanPath C:\Foo

# 10. Viewing detected threats
Get-MpThreat
