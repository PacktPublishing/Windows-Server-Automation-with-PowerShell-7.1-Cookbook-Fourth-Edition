# VSCode Profile Sample
# Created 14 Aug 2020
# tfl@psp.co.uk

# For use with Thomas Lee's Packt Book on PSH 7

# 1. Write details
"In Customisations for [$($Host.Name)]"
"On $(hostname)"

# 2. Set $Me
$ME = whoami
Write-Host "Logged on as $ME"

# 3. Set Format enumeration limit
$FormatEnumerationLimit = 99

# 4. Set some command Defaults
$PSDefaultParameterValues = @{
  "*:autosize"       = $true
  'Receive-Job:keep' = $true
  '*:Wrap'           = $true
}

# 5. Set home to C:\Foo for ~, then go there
New-Item C:\Foo -ItemType Directory -Force -EA 0 | Out-Null
$Provider = Get-PSProvider -PSProvider Filesystem
$Provider.Home = 'C:\Foo'
Set-Location -Path ~
Write-Host 'Setting home to C:\Foo'

# 6. Add a new function Get-HelpDetailed and set an alias
Function Get-HelpDetailed { 
    Get-Help $args[0] -Detailed
} # End Get-HelpDetailed Function

# 7. Set aliases for help
Set-Alias gh    Get-Help
Set-Alias ghd   Get-HelpDetailed

# 8. Create Reskit Credential
$Urk = 'Reskit\Administrator'
$Prk = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
$Credrk = New-Object System.Management.Automation.PSCredential $Urk, $Prk
Write-Host "`$Credrk created for $($Credrk.Username)"

### VS COde specific

# Fix colour scheme if VS Code
$Path       = $Env:APPDATA
$CP         = '\Code\User\Settings.json'
$JsonConfig = Join-Path  $Path -ChildPath $CP
$ConfigJSON = Get-Content $JsonConfig
$Theme = $ConfigJson | 
           ConvertFrom-Json | Select-Object -ExpandProperty 'workbench.colorTheme'
If ($Theme -eq 'Solarized Light' -or 
    $Theme -eq 'Visual Studio Light' ) {
  Write-Host "Updating VS Code Colour Scheme"
  Set-PSReadLineOption -Colors @{
    Emphasis  = "`e[33m"
    Number    = "`e[34m"
    Parameter = "`e[35m"
    Variable  = "`e[33m"  
    Member    = "`e[34m"
    Command   = 'red'
    Operator  = "`e[35m"  
  }
}

# All done
Write-Host "Completed Customisations to $(hostname)"
