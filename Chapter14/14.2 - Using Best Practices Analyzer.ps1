# 14.3 - Using Best Practices Analyzer

# Run on SRV1 with DC1 and DC2 online

# 1. Creating a remoting session to Windows PowerShell on DC1
$BPAS = New-PSSession -ComputerName DC1

# 2. Discovering the BPA module on DC1
$SB1 = {
  Get-Module -Name BestPractices -List |
    Format-Table -AutoSize     
}
Invoke-Command -Session $BPAS -ScriptBlock $SB1

# 3. Discovering the commands in the BPA module
$SB2 = {
    Get-Command -Module BestPractices  |
      Format-Table -AutoSize
}
Invoke-Command -Session $BPAS -ScriptBlock $SB2

# 4. Discovering all available BPA models on DC1
$SB3 = {
  Get-BPAModel  |
    Format-Table -Property Name,Id, LastScanTime -AutoSize    
}
Invoke-Command -Session $BPAS -ScriptBlock $SB3

# 5. Running the BPA DS model on DC1
$SB4 = {
  Invoke-BpaModel -ModelID Microsoft/Windows/DirectoryServices -Mode ALL |
    Format-Table -AutoSize
}    
Invoke-Command -Session $BPAS -ScriptBlock $SB4

# 6. Getting BPA results from DC1
$SB5 = {
    Get-BpaResult -ModelID Microsoft/Windows/DirectoryServices  |
      Where-Object Resolution -ne $null|
        Format-List -Property Problem, Resolution
}    
Invoke-Command -Session $BPAS -ScriptBlock $SB5
  