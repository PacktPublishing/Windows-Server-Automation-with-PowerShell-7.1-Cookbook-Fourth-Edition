# 2.1 Exploring New Operators

# Run on SRV1 after installing PowerShell 7 and VS C0de

# Pipeline chain operators && and ||

# 1. Checking results traditionally
Write-Output 'Something that succeeds'
if ($?) {Write-Output 'It worked'}

# 2. Checking results With pipeline operator &&
Write-Output 'Something that succeeds' && Write-Output 'It worked'

# 3. Using pipeline chain operator  ||
Write-Output 'Something that succeeds' || 
  Write-Output 'You do not see this message'

# 4. Define a simple function
function Install-CascadiaPLFont{
  Write-Host 'Installing Cascadia PL font...'
}

# 5. Using the || operator
$OldErrorAction        = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
Get-ChildItem -Path C:\FOO\CASCADIAPL.TTF  || 
   Install-CascadiaPLFont
$ErrorActionPreference = $OldErrorAction

# Null Coalescing

# 6. Create a function to test null handling
Function Test-NCO {
  if ($args -eq '42') {
    Return 'Test-NCO returned a result'
  }
}

# 7.	Testing null results traditionally
$Result1 = Test-NCO    # no parameter
if ($null -eq $Result1) {
    'Function returned no value'
} else {
    $Result1
}
$Result2 = Test-NCO 42  # using a parameter
if ($null -eq $Result2) { 
    'Function returned no value'
} else {
    $Result2
}

# 8. Testing using null coalescing operator ??
$Result3 =  Test-NCO
$Result3 ?? 'Function returned no value'
$Result4 =  Test-NCO 42
$Result4 ?? 'This is not output, but result is'

# 9. Demonstrating the Null conditional assignment operator
$Result5 = Test-NCO
$Result5 ?? 'Result is is null'
$Result5 ??= Test-NCO 42
$Result5

# 10. Running a method on a null object traditionally
$BitService.Stop()

# 11. Using the Null conditional operator for a method
${BitService}?.Stop()

# 12. Testing null property name access
$x = $null
${x}?.Propname
$x = @{Propname=42}
${x}?.Propname

# 13. Testing array member access if a null object
$y = $null
${y}?[0]
$y = 1,2,3
${y}?[0]

# 14. Using the background processing operator &
Get-CimClass -ClassName Win32_Bios &

# 15. Waiting for the job to complete
$JobId = (Get-Job | Select-Object -Last 1).Id
Wait-Job -id $JobId


# 16. Viewing the output
$Results = Receive-Job -Id $JobId
$Results

# 17. Creating an object without using the ternary operator
$A = 42; $B = (42,4242) | Get-Random
$RandomTest = ($true, $false) | Get-Random
if ($A -eq $B) {
  $Property1 = $true
} else {
  $Property1 = $false
}
if ($RandomTest) {
  $Property2 = 'Hello'
} else {
  $Property2 = 'Goodbye'
}
[PSCustomObject]@{
  "Property1" = $Property1
  "Property2" = $Property2
} 


# 18. Creating an object using the ternary operator
[PSCustomObject]@{
    "Property1" = (($A -eq $B) ? $true : $false)
    "Property2" = (($RandomTest) ? 'Hello' : 'Goodbye')    
}
 