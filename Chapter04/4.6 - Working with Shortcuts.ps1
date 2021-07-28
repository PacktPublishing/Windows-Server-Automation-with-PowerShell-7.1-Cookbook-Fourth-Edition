# 4.8 - Working with Shortcuts

# Run on SRV1


# 1. Finding the PSShortCut module 
Find-Module -Name '*Shortcut'

# 2. Installing PSShortcut module
Install-Module -Name PSShortcut -Force

# 3. Reviewing PSShortcut module
Get-Module -Name PSShortCut -ListAvailable |
  Format-List

# 4. Discovering commands in PSShortcut module  
Get-Command -Module PSShortcut

# 5. Discovering all shortcuts on SRV1
$SHORTCUTS = Get-Shortcut
"Shortcuts found on $(hostname): [{0}]" -f $SHORTCUTS.Count

# 6. Discovering PWSH shortcuts
$SHORTCUTS | Where-Object Name -match '^PWSH'

# 7. Discovering URL shortcut
$URLSC = Get-Shortcut -FilePath *.url
$URLSC

# 8. Viewing content of shortcut
$URLSC | Get-Content

# 9. Creating a URL shortcut
$NEWURLSC  = 'C:\Foo\Google.url'
$TARGETURL = 'https://google.com'
New-Item -Path $NEWURLSC | Out-Null
Set-Shortcut -FilePath $NEWURLSC -TargetPath $TARGETURL

# 10. Using the URL Shortcut
& $NEWURLSC

# 11. Creating a file shortcut
$CMD  = Get-Command -Name notepad.exe
$NP   = $CMD.Source
$NPSC = 'C:\Foo\NotePad.lnk'
New-Item -Path $NPSC | Out-Null
Set-Shortcut -FilePath $NPSC -TargetPath $NP

# 12 Using the shortcut
& $NPSC
