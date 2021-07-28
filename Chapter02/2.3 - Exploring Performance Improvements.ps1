# 2.3 - Exploring Performance Improvements

# run on SRV1 after installing pwsh 7
# run elevated


# 1. Creating a remoting connection to the local host
New-PSSession -UseWindowsPowerShell -Name 'WPS'

# 2. Getting the remoting session
$Session = Get-PSSession -Name 'WPS'

# 3. Checking the version of PowerShell in the remoting session
Invoke-Command -Session $Session  -ScriptBlock {$PSVersionTable}

# 4. Defining a long running script block using ForEach-Object
$SB1 = {
  $Array  = (1..10000000)
  (Measure-Command {
    $Array | ForEach-Object {$_}}).TotalSeconds
}

# 5. Runing The script block locally
[gc]::Collect()
$TimeInP7 = Invoke-Command -ScriptBlock $SB1 
"Foreach-Object in PowerShell 7.1: [{0:n4}] seconds" -f $TimeInP7

# 6. Running it in PowerShell 5.1 
[gc]::Collect()
$TimeInWP  = Invoke-Command -ScriptBlock $SB1 -Session $Session
"ForEach-Object in Windows PowerShell 5.1: [{0:n4}] seconds" -f $TimeInWP

# 7. Defining another long running script block using ForEach
$SB2 = {
    $Array  = (1..10000000)
    (Measure-Command {
      ForEach ($Member in $Array) {$Member}}).TotalSeconds
}

# 8. Running it locally in PowerShell 7
[gc]::Collect()
$TimeInP72 = Invoke-Command -ScriptBlock $SB2 
"Foreach in PowerShell 7.1: [{0:n4}] seconds" -f $TimeInP72
  
# 9. Running it in Windows PowerShell 5.1 
[gc]::Collect()
$TimeInWP2  = Invoke-Command -ScriptBlock $SB2 -Session $Session
"Foreach in Windows PowerShell 5.1: [{0:n4}] seconds" -f $TimeInWP2
