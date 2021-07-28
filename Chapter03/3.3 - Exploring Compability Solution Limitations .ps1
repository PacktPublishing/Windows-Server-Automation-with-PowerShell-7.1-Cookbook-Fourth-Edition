# 3.3 Exploring Compatibility limitations


# 1. Attempting to view a Windows PowerShell module
Get-Module -Name ServerManager -ListAvailable

# 2. Trying to load a module without edition check
Import-Module -Name ServerManager -SkipEditionCheck

# 3. Disconvering a Windows PowerShell command
Get-Command -Name Get-WindowsFeature

# 4. Examining remote session
$Session = Get-PSSession
$Session | Format-Table -AutoSize

# 5. Invoking Get-WindowsFeature in the remote session
$SBRC = {Get-Command -Name Get-WindowsFeature}
Invoke-Command -Session $Session -ScriptBlock $SBRC

# 6. Invoking Get-WindowsFeature locally
Invoke-Command $SBRC

