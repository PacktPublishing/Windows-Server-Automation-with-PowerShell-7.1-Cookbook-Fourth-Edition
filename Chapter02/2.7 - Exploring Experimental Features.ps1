# 2.7 EXploring Experimental Features
#
# Run on SRV1 after installing PowerShell 7

# 1. Discovering experimental features
Get-ExperimentalFeature -Name * |
  Format-Table Name, Enabled, Description -Wrap

# 2. Examining command not found result with no experimental features available
Foo  

# 3. Enabling one experimental feature as current user
Get-ExperimentalFeature -Name * | 
  Select-Object -First 1 |
    Enable-ExperimentalFeature -Scope CurrentUser -Verbose

# 4. Enabling one experimental feature for all users
Get-ExperimentalFeature -Name * | 
  Select-Object -Skip 1 -First 1 |
    Enable-ExperimentalFeature -Scope AllUsers -Verbose

# 5. Start a new PowerShell console

# 6. Examining experimental features
Get-ExperimentalFeature

# 7. Examining output from command not found suggestion feature
foo
