# 1.6 Installing Cascadia Code Font

# Run on SRV1 after you install PowerShell 7 and VS Code

# 1. Get Download Locations
$CascadiaFont    = 'Cascadia.ttf'    # font file name
$CascadiaRelURL  = 'https://github.com/microsoft/cascadia-code/releases'
$CascadiaRelease = Invoke-WebRequest -Uri $CascadiaRelURL # Get all
$CascadiaPath    = "https://github.com" + ($CascadiaRelease.Links.href |
                      Where-Object { $_ -match "($CascadiaFont)" } |
                        Select-Object -First 1)
$CascadiaFile   = "C:\Foo\$CascadiaFont"

# 2. Download Cascadia Code font file
Invoke-WebRequest -Uri $CascadiaPath -OutFile $CascadiaFile

# 3. Install Cascadia Code font
$FontShellApp = New-Object -Com Shell.Application
$FontShellNamespace = $FontShellApp.Namespace(0x14)
$FontShellNamespace.CopyHere($CascadiaFile, 0x10)

# 4. Restart VS Code
