# 8.4 Deploying PowerSHell Group Policies

# Run on DC1 - Login as Administrator


# 1. Discovering the GPO-related files
Get-ChildItem -Path $PSHOME -Filter *Core*Policy*

# 2. Installing the PowerShell 7 group policy files
$LOC = 'C:\Program Files\PowerShell\7\' +         # $PSHome
       'InstallPSCorePolicyDefinitions.ps1'       # Script
& $LOC -VERBOSE

# 3. Creating and displaying a new GPO for the IT group
$PshGPO = New-GPO -Name 'PowerShell GPO for IT'

# 4. Enabling module logging
$GPOKEY1 = 
  'HKCU\Software\Policies\Microsoft\PowerShellCore\ModuleLogging'
$GPOHT1 = @{
  DisplayName    = $PshGPO.DisplayName
  Key            = $GPOKEY1
  Type           = [Microsoft.Win32.RegistryValueKind]::DWord   
  ValueName      = 'EnableModuleLogging'
  Value          = 1
}
Set-GPRegistryValue @GPOHT1 | Out-Null

# 5. Configuring module names to log
$GPOHT2 = @{
  DisplayName    = $PshGPO.DisplayName
  Key            = "$GPOKEY1\ModuleNames"
  Type           = [Microsoft.Win32.RegistryValueKind]::String
  ValueName      = 'ITModule1', 'ITModule2'  
  Value          = 'ITModule1', 'ITModule2'
 }
Set-GPRegistryValue @GPOHT2 | Out-Null

# 6. Enabling script block logging
$GPOKey3 = 
  'HKCU\Software\Policies\Microsoft\PowerShellCore\ScriptBlockLogging'
$GPOHT3  = @{
    DisplayName    = $PshGPO.DisplayName
    Key            = $GPOKEY3
    Type           = [Microsoft.Win32.RegistryValueKind]::DWord
    ValueName      = 'EnableScriptBlockLogging'  
    Value          = 1
   }
Set-GPRegistryValue @GPOHT3 | Out-Null

# 7. Enabling Unrestricted Execution Policy
$GPOKey4 = 
  'HKCU\Software\Policies\Microsoft\PowerShellCore'
# create the key value to enable
$GPOHT4 =  @{
    DisplayName    = $PshGPO.DisplayName
    Key            = $GPOKEY4
    Type           = [Microsoft.Win32.RegistryValueKind]::DWord   
    ValueName      = 'EnableScripts'
    Value          = 1
  }
  Set-GPRegistryValue @GPOHT4 | Out-Null
# Set the default   
$GPOHT4 = @{
  DisplayName    = $PshGPO.DisplayName
  Key            = "$GPOKEY4"
  Type           = [Microsoft.Win32.RegistryValueKind]::String
  ValueName      = 'ExecutionPolicy'
  Value          = 'Unrestricted'
}
Set-GPRegistryValue @GPOHT4
 
# 8. Assigning GPO to IT OU
$Target = "OU=IT, DC=Reskit, DC=Org" 
New-GPLink -DisplayName $PshGPO.Displayname -Target $Target |
   Out-Null


# 9. Creating an RSOP report
$RSOPHT = @{
  ReportType = 'HTML'
  Path       = 'C:\Foo\GPOReport.Html'
  User       = 'Reskit\JerryG'
}
Get-GPResultantSetOfPolicy @RSOPHT
& $RSOPHT.Path
