# 1.5 Install-VSCode
#
# Run on SRV1 after installing PowerShell 7
# Run in PowerShell 7 console

# 1. Downloading the VS Code installation script from PS Gallery
$VSCPATH = 'C:\Foo'
Save-Script -Name Install-VSCode -Path $VSCPATH
Set-Location -Path $VSCPATH

# 2. Running the installation script and adding in some popular extensions
$Extensions =  'Streetsidesoftware.code-spell-checker',
               'yzhang.markdown-all-in-one',
               'hediet.vscode-drawio'
$InstallHT = @{
  BuildEdition         = 'Stable-System'
  AdditionalExtensions = $Extensions
  LaunchWhenDone       = $true
}
.\Install-VSCode.ps1 @InstallHT | Out-Null

# 3. Exiting from VS Code

# 4. Restarting VS Code as an Administrator

# 5. Opening a VS Code Terminal and running PowerShell 7.

# 6. Creating a profile file for VS Code
$SAMPLE =
  'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
  'scripts/goodies/Microsoft.VSCode_profile.ps1'
(Invoke-WebRequest -Uri $Sample).Content |
  Out-File $Profile

# 7. Updating local user settings for VS Code
$JSON = @'
{
  "workbench.colorTheme": "Visual Studio Light",
  "powershell.codeFormatting.useCorrectCasing": true,
  "files.autoSave": "onWindowChange",
  "files.defaultLanguage": "powershell",
  "editor.fontFamily": "'Cascadia Code',Consolas,'Courier New'",
  "workbench.editor.highlightModifiedTabs": true,
  "window.zoomLevel": 1
}
'@
$JHT = ConvertFrom-Json -InputObject $JSON -AsHashtable
$PWSH = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
$JHT += @{
  "terminal.integrated.shell.windows" = "$PWSH"
}
$Path = $Env:APPDATA
$CP   = '\Code\User\Settings.json'
$Settings = Join-Path  $Path -ChildPath $CP
$JHT |
  ConvertTo-Json  |
    Out-File -FilePath $Settings

# 8. Creating a short cut to VSCode
$SourceFileLocation  = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
$ShortcutLocation    = "C:\foo\vscode.lnk"
# Create a  new wscript.shell object
$WScriptShell        = New-Object -ComObject WScript.Shell
$Shortcut            = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $SourceFileLocation
# Save the Shortcut to the TargetPath
$Shortcut.Save()

# 9. Creating a short cut to PowerShell 7
$SourceFileLocation  = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
$ShortcutLocation    = 'C:\Foo\pwsh.lnk'
# Create a  new wscript.shell object
$WScriptShell        = New-Object -ComObject WScript.Shell
$Shortcut            = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $SourceFileLocation
#Save the Shortcut to the TargetPath
$Shortcut.Save()

# 10. Building an updated Layout XML file
$XML = @'
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
  xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
  xmlns:defaultlayout=
    "http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
  xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
  xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
  Version="1">
<CustomTaskbarLayoutCollection>
<defaultlayout:TaskbarLayout>
<taskbar:TaskbarPinList>
 <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Foo\vscode.lnk" />
 <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Foo\pwsh.lnk" />
</taskbar:TaskbarPinList>
</defaultlayout:TaskbarLayout>
</CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
'@
$XML | Out-File -FilePath C:\Foo\Layout.Xml

# 11. Importing the  start layout XML file
#     You get an error if this is not run in an elevated session
Import-StartLayout -LayoutPath C:\Foo\Layout.Xml -MountPath C:\

# 12. Creating a profile file for PWSH 7 Consoles
$ProfileFile2   = 'Microsoft.PowerShell_Profile.ps1'
$ConsoleProfile = Join-Path -Path $ProfileFolder -ChildPath $ProfileFile2
New-Item $ConsoleProfile -Force -WarningAction SilentlyContinue |
   Out-Null
$URI2 = 'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
        "scripts/goodies/$ProfileFile2"
(Invoke-WebRequest -Uri $URI2).Content |
  Out-File -FilePath  $ConsoleProfile

# 13. Logging off 
logoff.exe

# 14. Logging into Windows to observe the updated task bar

# 15. Running PowerShell console and observe the profile file running

# 16. Running VS Code from shortcut and observe the profile file running
