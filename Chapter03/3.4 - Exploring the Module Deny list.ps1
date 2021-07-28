# 3.4 Exploring the Module Load Deny List

# Fun on SRV1 after loading PowerShell 7 and VS Code.

# 1. Getting the PowerShell configuration file
$CFFile = "$PSHOME/powershell.config.json"
Get-Item -Path $CFFile

# 2. Viewing contents
Get-Content -Path $CFFile

# 3. Attempting to load a module in deny list
Import-Module -Name BestPractices

# 4. Loading the module overriding edition check
Import-Module -Name BestPractices -SkipEditionCheck

# 5. Viewing the module definition
Get-Module -Name BestPractices

# 6. Attempting to use Get-BpaModel
Get-BpaModel 

