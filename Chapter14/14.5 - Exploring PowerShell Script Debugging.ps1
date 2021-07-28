# 14.5 - Exploring PowerShell Script Debugging

# Run on SRV1

# 1. Creating a script to debug
$SCR = @'
# Script to illustrate breakpoints
Function Get-Foo1 {
  param ($J)
  $K = $J*2           # NB: line 4
  $M = $K             # NB: $M written to
  $M
  $BIOS = Get-CimInstance -Class Win32_Bios
}
Function Get-Foo {
  param ($I)
  (Get-Foo1 $I)      # Uses Get-Foo1
}
Function Get-Bar { 
  Get-Foo (21)}
# Start of ACTUAL script
  "In Breakpoint.ps1"
  "Calculating Bar as [{0}]" -f (Get-Bar)
'@

# 2. Saving the script
$ScrFile = 'C:\Foo\Breakpoint.ps1'
$SCR | Out-File -FilePath $ScrFile

# 3. Executing the script
& $ScrFile

# 4. Adding a breakpoint at a line in the script
Set-PSBreakpoint -Script $ScrFile -Line 4 |  # breaks at line 4
    Out-Null
    
# 5. Adding a breakpoint on the script using a specific command
Set-PSBreakpoint -Script $SCRFile -Command "Get-CimInstance" |
  Out-Null

# 6. Adding a breakpoint when the script writes to $M
Set-PSBreakpoint -Script $SCRFile -Variable M -Mode Write |
  Out-Null

# 7. Viewing the breakpoints set in this session
Get-PSBreakpoint | Format-Table -AutoSize

# 8. Running the script - until the first breakpoint is hit
& $ScrFile

# 9. Viewing the value of $J from the debug console
$J

# 10. Viewing the value of $K from the debug console
$K

# 11. Continuing script execution from the DBG prompt until the next breakpoint
continue

# 12. Continuine script executiont until the execution of Get-CimInstance
continue

# 13. Continuing script execution from until the end of the script
continue
