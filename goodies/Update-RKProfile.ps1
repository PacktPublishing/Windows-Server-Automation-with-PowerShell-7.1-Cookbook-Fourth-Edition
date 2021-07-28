# Update-RKProfile

# Rebuilds PowerShell profiles ext after an account change

# 1. Set Execution Policy for Windows PowerShell
Write-Host 'Setting Execution Policy'
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# 2. Ensure the C:\Foo Folder exists
Write-Host 'Checking C:\Foo'
If (Test-Path -Path C:\Foo ) {
    Write-Host "C:\Foo exists!"
}
Else {
  Write-Host "C:\Foo does not exist - creating now"
  $LFHT = @{
    ItemType    = 'Directory'
    ErrorAction = 'SilentlyContinue' # should it already exist
    }
  New-Item -Path C:\Foo @LFHT
}

# 3. Create PowerShell Console Profile
Write-Host "Creating Default profiles"
$URI = 'https://raw.githubusercontent.com/doctordns/Wiley20/master/' +
       'Goodies/Microsoft.PowerShell_Profile.ps1'
$ProfileFile = 
  "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
New-Item $ProfileFile -Force -WarningAction SilentlyContinue |
   Out-Null
(Invoke-WebRequest -Uri $URI).Content | 
  Out-File -FilePath  $ProfileFile

$ProfilePath = Split-Path -Path $ProfileFile
$ISEProfile = Join-Path -Path $ProfilePath -ChildPath 'Microsoft.PowerShellISE_profile.ps1'
New-Item $ISEProfile -Force -WarningAction SilentlyContinue |
   Out-Null
(Invoke-WebRequest -Uri $URI).Content | 
  Out-File -FilePath  $ISEProfile

# 4. Create VS Code Profile
Write-Host "Creating VS Code Default profile"
$VSCodeProfileFile = 
"$env:UserProfile\Documents\PowerShell\Microsoft.VSCode_profile.ps1"

New-Item $VSCodeProfileFile -Force -WarningAction SilentlyContinue | Out-Null
$VSCodePS7Sample = 
  'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
  'scripts/goodies/Microsoft.VSCode_profile.ps1'
Start-BitsTransfer -Source $VSCodePS7Sample -Destination $VSCodeProfileFile

Write-Host 'Creating PWSH 7 Console Profile'
$ProfilePath = Split-Path -Path $VSCodeProfileFile
$ConsoleProfile = Join-Path -Path $ProfilePath -ChildPath 'Microsoft.PowerShell_profile.ps1'
New-Item $ConsoleProfile -Force -WarningAction SilentlyContinue | Out-Null
$ConsolePS7Sample = 
  'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
  'scripts/goodies/Microsoft.PowerShell_Profile.ps1'
Start-BitsTransfer -Source $ConsolePS7Sample -Destination $ConsoleProfile


# 5. Update Local User Settings for VS Code
Write-Host "Updating VSCode Settings"
$JSON = @'
{
  "workbench.colorTheme": "Visual Studio Light",
  "powershell.codeFormatting.useCorrectCasing": true,
  "files.autoSave": "onWindowChange",
  "files.defaultLanguage": "powershell",
  "editor.fontFamily": "'Cascadia Code',Consolas,'Courier New'",
  "workbench.editor.highlightModifiedTabs": true,
  "window.zoomLevel": 1,
  "terminal.integrated.shell.windows": "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
  "powershell.powerShellAdditionalExePaths": [
    {
        "exePath": "C:\\PSDailyBuild\\pwsh.exe",
        "versionName": "PowerShell 7.1 Daily Build"
    },
    {
        "exePath": "C:\\PSPreview\\pwsh.exe",
        "versionName": "PowerSHell 7.1 Preview Latest"
    }
  ]
}
'@
$JHT = ConvertFrom-Json -InputObject $JSON -AsHashtable
$Path = $Env:APPDATA
$CP   = '\Code\User\Settings.json'
$Settings = Join-Path  $Path -ChildPath $CP
$JHT |
  ConvertTo-Json  |
    Out-File -FilePath $Settings

