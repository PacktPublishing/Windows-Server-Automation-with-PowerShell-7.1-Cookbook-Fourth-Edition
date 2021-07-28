# 14.1 - Checking Network Details using Get-NetView

#  Run on SRV1


# 1. Finding the Get-NetView module on the PS Gallery
Find-Module -Name Get-NetView

# 2. Installing the latest version of Get-NetView
Install-Module -Name Get-NetView -Force -AllowClobber

# 3. Checking installed version of Get-NetView
Get-Module -Name Get-NetView -ListAvailable

# 4. Importing Get-NetView
Import-Module -Name Get-NetView -Force

# 5. Creating new folder
$OF = 'C:\NetViewOutput'
New-Item -Path $OF -ItemType directory | Out-Null

# 6. Running Get-View
Get-NetView -OutputDirectory $OF

# 7. Viewing the output folder using Get-ChildItem
$OFF = Get-ChildItem $OF
$OFF

# 8. Viewing the output folder contents using Get-ChildItem
$Results = $OFF | Select-Object -First 1
Get-ChildItem -Path $Results

# 9. Viewing IP configuration
Get-Content -Path $Results\_ipconfig.txt