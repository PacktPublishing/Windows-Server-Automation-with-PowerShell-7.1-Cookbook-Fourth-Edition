# 1.3 - Exploring PWSH 7 Installation Artifacts
#
# Run in PWSH 7 Console

# 1. Checking the version table for PowerShell 7 console
$PSVersionTable

# 2. Examining the PowerShell 7 installation folder
Get-ChildItem -Path $env:ProgramFiles\PowerShell\7 -Recurse |
  Measure-Object -Property Length -Sum

# 3. Viewing PowerShell 7 configuration JSON file
Get-ChildItem -Path $env:ProgramFiles\PowerShell\7\powershell*.json |
  Get-Content

# 4. Checking initial Execution Policy for PowerShell 7
Get-ExecutionPolicy

# 5. Viewing module folders
$I = 0
$ModPath = $env:PSModulePath -split ';'
$ModPath |
  Foreach-Object {
    "[{0:N0}]   {1}" -f $I++, $_
  }

# 6. Checking the modules
$TotalCommands = 0
Foreach ($Path in $ModPath){
  Try { $Modules = Get-ChildItem -Path $Path -Directory -ErrorAction Stop
        "Checking Module Path:  [$Path]"
  }
  Catch [System.Management.Automation.ItemNotFoundException] {
    "Module path [$path] DOES NOT EXIST ON $(hostname)"
  }
  $TotalCommands = 0
  Foreach ($Module in $Modules) {
    $Cmds = Get-Command -Module ($Module.name)
    $TotalCommands += $Cmds.Count
  }
}

# 7. Viewing totals of commands and modules
$Mods = (Get-Module * -ListAvailable | Measure-Object).count
"{0} modules providing {1} commands" -f $Mods,$TotalCommands



