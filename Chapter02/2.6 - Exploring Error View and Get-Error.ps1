# 2.6 - Exploring Error view and Get-Error
#
# Run on SRV1 after installing PS 7 and VS Code

# 1. Creating a simple script
$SCRIPT = @'
  # divide by zero
  42/0  
'@
$SCRIPTFILENAME = 'C:\Foo\ZeroDivError.ps1'
$SCRIPT | Out-File -Path $SCRIPTFILENAME

# 2. Running the script and seeing the default error view
& $SCRIPTFILENAME

# 3. Running the same line from the console
42/0  

# 4. Viewing $ErrorView variable
$ErrorView 

# 5. Viewing potential values of $ErrorView
$Type = $ErrorView.GetType().FullName
[System.Enum]::GetNames($Type)

# 6. Setting $ErrorView to 'NormalView' and recreating the error
$ErrorView = 'NormalView'
& $SCRIPTFILENAME

7. Setting $ErrorView to 'CategoryView' and recreating the error
$ErrorView = 'CategoryView'
& $SCRIPTFILENAME

# 8. Setting back to ConciseView (default)
$ErrorView = 'ConciseView'
