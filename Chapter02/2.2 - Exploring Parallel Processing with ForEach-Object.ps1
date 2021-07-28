# 2.2 Exploring Parallel processing

# Run in PS 7 on SRV1


# 1. Simulating a long running script block
$SB1 = {
  1..3 | ForEach-Object {
    "In iteration $_"
    Start-Sleep -Seconds 5
  } 
}
Invoke-Command -ScriptBlock $SB1

# 2. Timing the expression
Measure-Command -Expression $SB1

# 3. Refactoring into using jobs
$SB2 = {
1..3 | ForEach-Object {
  Start-Job -ScriptBlock {param($X) "Iteration $X " ;
                          Start-Sleep -Seconds 5} -ArgumentList $_ 
}
Get-Job | Wait-Job | Receive-Job -Keep
}

# 4. Invoking the script block
Invoke-Command -ScriptBlock $SB2

# 5. Removing any old jobs and timing the script block
Get-Job | Remove-Job
Measure-Command -Expression $SB2

# 6. Defining a script block using ForEach-Object -Parallel
$SB3 = {
1..3 | ForEach-Object -Parallel {
               "In iteration $_"
               Start-Sleep -Seconds 5
         } 
}

# 7. Executing the script block
Invoke-Command -ScriptBlock $SB3

# 8. Measuring the script block execution time
Measure-Command -Expression $SB3

# 9. Creating and running two short script blocks
$SB4 = {
    1..3 | ForEach-Object {
                   "In iteration $_"
             } 
}
Invoke-Command -ScriptBlock $SB4    

$SB5 = {
        1..3 | ForEach-Object -Parallel {
                       "In iteration $_"
             } 
}
Invoke-Command -ScriptBlock $SB5    

# 10. Measuring execution time for both script blocks
Measure-Command -Expression $SB4    
Measure-Command -Expression $SB5    
