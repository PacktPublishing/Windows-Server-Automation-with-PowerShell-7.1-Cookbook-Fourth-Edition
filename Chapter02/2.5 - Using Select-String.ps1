# 2.5 - Using Select-String

# Run on SRV1 after installing PowerShell 7


# 1. Getting a file of text to work with
$Source       = 'https://www.gutenberg.org/files/1661/1661-0.txt'
$Destination  = 'C:\Foo\Sherlock.txt'
Start-BitsTransfer -Source $Source -Destination $Destination

# 2. Getting book contents
$Contents = Get-Content -Path $Destination

# 3. Checking the length of The Adventures of Sherlock Holmes
"The book is {0} lines long" -f $Contents.Length

# 4. Searching for "Watson" in book contents
$Match1 = $Contents | Select-String -Pattern 'Watson'
"Watson is found {0} times" -f $Match1.Count

# 5. Viewing first few matches
$Match1 | Select-Object -First 5

# 6. Searching for 'Dr. Watson' with a regular expression
$Contents | Select-String -Pattern 'Dr\. Watson'

# 7. Searching for Dr. Watson using a simple match
$Contents | Select-String -Pattern 'Dr. Watson' -SimpleMatch

# 8. Viewing output when searchng from files
Get-ChildItem -Path $Destination |
  Select-String -Pattern 'Dr\. Watson'
