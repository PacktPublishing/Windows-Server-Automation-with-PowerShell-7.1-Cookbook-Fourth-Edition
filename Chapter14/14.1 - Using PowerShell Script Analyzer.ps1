# 14.2 Using the PowerShell Script Analyzer

# Run on SRV1

# 1. Discovering the Powershell Script Analyzer module
Find-Module -Name PSScriptAnalyzer |
  Format-List Name, Type, Desc*, Author, Company*, *Date, *URI*
  
# 2. Installing the script analyzer module
Install-Module -Name PSScriptAnalyzer -Force

# 3. Discovering the commands in the Script Analyzer module
Get-Command -Module PSScriptAnalyzer

# 4. Discovering analyzer rules
Get-ScriptAnalyzerRule | 
  Group-Object -Property Severity |
    Sort-Object -Property Count -Descending

# 5. Examining a rule
Get-ScriptAnalyzerRule | 
  Select-Object -First 1 |
    Format-List

# 6. Creating a script file with issues
@'
# Bad.ps1
# A file to demonstrate Script Analyzer
#
### Uses an alias
$Procs = gps
### Uses positional parameters
$Services = Get-Service 'foo' 21
### Uses poor function header
Function foo {"Foo"}
### Function redefines a built in command
Function Get-ChildItem {"Sorry Dave I cannot do that"}
### Command uses a hard coded computer name
Test-Connection -ComputerName DC1
### A line that has trailing white space
$foobar ="foobar"                                                                                       
### A line using a global variable
$Global:foo
'@ | Out-File -FilePath "C:\Foo\Bad.ps1"

# 7. Checking the newly created script file
Get-ChildItem C:\Foo\Bad.ps1


# 8. Analyzing the script file
Invoke-ScriptAnalyzer -Path C:\Foo\Bad.ps1 |
  Sort-Object -Property Line


# 9. Defining a function to format more nicely
$Script1 = @'
function foo {"hello!"
Get-ChildItem -Path C:\FOO
}
'@

# 10. Defining formatting settings
$Settings = @{
  IncludeRules = @("PSPlaceOpenBrace", "PSUseConsistentIndentation")
  Rules = @{
    PSPlaceOpenBrace = @{
      Enable = $true
      OnSameLine = $true
    }
    PSUseConsistentIndentation = @{
      Enable = $true
    }
  }
}

# 11. Invoking formatter
Invoke-Formatter -ScriptDefinition $Script1 -Settings $Settings

# 12. Changing settings and reformatting
$Settings.Rules.PSPlaceOpenBrace.OnSameLine = $False
Invoke-Formatter -ScriptDefinition $Script1 -Settings $Settings
