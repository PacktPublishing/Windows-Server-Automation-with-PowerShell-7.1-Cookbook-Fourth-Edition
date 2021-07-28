# 1.4 - Build Profile files

# Run on SRV1 after installing PowerShell 7

# 1. Discovering the profile file names
$ProfileFiles = $PROFILE |  Get-Member -MemberType NoteProperty
$ProfileFiles | Format-Table -Property Name, Definition

# 2. Checking for existence of each PowerShell profile files
Foreach ($ProfileFile in $ProfileFiles){
  "Testing $($ProfileFile.Name)"
  $ProfilePath = $ProfileFile.Definition.split('=')[1]
  If (Test-Path $ProfilePath){
    "$($ProfileFile.Name) DOES EXIST"
    "At $ProfilePath"
  }
  Else {
    "$($ProfileFile.Name) DOES NOT EXIST"
  }
  ""
}

# 3. Discovering Current User/Current Host Profile
$CUCHProfile = $PROFILE.CurrentUserCurrentHost
"Current User/Current Host profile path: [$CUCHPROFILE]"

# 4. Creating a Current User/Current Host profile for PowerShell 7 console
$URI = 'https://raw.githubusercontent.com/doctordns/PACKT-PS7/master/' +
       'scripts/goodies/Microsoft.PowerShell_Profile.ps1'
New-Item $CUCHProfile -Force -WarningAction SilentlyContinue |
   Out-Null
(Invoke-WebRequest -Uri $URI).Content |
  Out-File -FilePath  $CUCHProfile

# 5. Exiting from PowerShell 7 console 
Exit

# 6. Restarting the PowerShell 7 console and viewing the profile output at startup
Get-ChildItem -Path $PROFILE
