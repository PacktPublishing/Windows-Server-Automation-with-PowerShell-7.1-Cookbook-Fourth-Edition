# 5.1 Exploring Assemblies

# Run on SRV1

# 1. Counting loaded assemblies
$Assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() 
"Assemblies loaded: {0:n0}" -f $Assemblies.Count

# 2. Viewing first 10
$Assemblies | Select-Object -First 10

# 3. Checking assemblies in Windows PowerShell
$SB = {
  [System.AppDomain]::CurrentDomain.GetAssemblies() 
} 
$PS51 = New-PSSession -UseWindowsPowerShell
$Assin51 = Invoke-Command -Session $PS51 -ScriptBlock $SB
"Assemblies loaded in Windows PowerShell: {0:n0}" -f $Assin51.Count
 
# 4. Viewing Microsoft.PowerShell assemblies
$Assin51 | 
  Where-Object FullName -Match "Microsoft\.Powershell" |
    Sort-Object -Property Location

# 5. Exploring the Microsoft.PowerShell.Management module
$Mod = 
  Get-Module -Name Microsoft.PowerShell.Management -ListAvailable
$Mod  | Format-List

# 6. Viewing module manifest
$Manifest = Get-Content -Path $Mod.Path
$Manifest | Select-Object -First 20

# 7. Discovering the module's assembly
Import-Module -Name Microsoft.PowerShell.Management
$Match = $Manifest | Select-String Modules
$LINE = $Match.Line
$DLL = ($Line -Split '"')[1]
Get-Item -Path $PSHOME\$DLL

# 8. Viewing associated loaded assembly
$Assemblies2 = [System.AppDomain]::CurrentDomain.GetAssemblies() 
$Assemblies2 | Where-Object Location -match $DLL

# 9. Getting details of a PowerShell command inside a module DLL
$Commands  = $Assemblies |
               Where-Object Location -match Commands.Management\.dll
$Commands.GetTypes() | 
  Where-Object Name -match "Addcontentcommand$" 

