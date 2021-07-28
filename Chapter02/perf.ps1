# 1. Test script block logging enabled
$Path = "Registry::HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
$Exists = Test-Path -Path $path
If (!$Exists) {"Script block logging not enabled"}

# 2. Run and time a pipeline
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Processed = Get-ChildItem -Path $env:windir -Filter *.log -Recurse -ErrorAction SilentlyContinue -Force |
               Measure-Object |
                 Select-Object -ExpandProperty Count
$Stopwatch.Stop()

# 3. Report results 
$Report = '{0} files proccessed in {1:n2} seconds' 
$Report -f $Processed, $stopwatch.Elapsed.TotalSeconds


# 4. Setup script block logging in the registry 
if (!$exists) { 
  $null = New-Item -Path $path -Force
}
$SBLHT1 = @{
  Path   = $Path
  Name   = 'EnableScriptBlockLogging'
  Type   = 'DWord'
  Value  = 1
}
Set-ItemProperty @SBLHT1
$SBLHT2 = @{
    Path   = $Path
    Name   = 'EnableScriptBlockInvocationLogging'
    Type   = 'DWord'
    Value  = 1
}
Set-ItemProperty @SBLHT2

# 5. Restart computer
Restart-Computer


# 6. Run and time a pipeline
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Processed = Get-ChildItem -Path $env:windir -Filter *.log -Recurse -ErrorAction SilentlyContinue -Force |
               Measure-Object |
                 Select-Object -ExpandProperty Count
$Stopwatch.Stop()

# 7. Report results 
$Report = '{0} files proccessed in {1:n2} seconds' 
$Report -f $Processed, $stopwatch.Elapsed.TotalSeconds


# 8. Now turn logging off
$path = "Registry::HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
Remove-ItemProperty -Path $path -Name EnableScriptBlockLogging  -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $path -Name EnableScriptBlockInvocationLogging  -ErrorAction SilentlyContinue
