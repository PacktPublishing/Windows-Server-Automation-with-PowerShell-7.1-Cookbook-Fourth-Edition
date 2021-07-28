# 9.1 Exploring WMI namespaces
#
# Run on SRV1


# 1. Viewing WMI classes in the root namespace
Get-CimClass -Namespace 'ROOT' | 
  Select-Object -First 10

# 2. Viewing the __NAMESPACE class in ROOT
Get-CimInstance -Namespace 'ROOT' -ClassName __NAMESPACE |
  Sort-Object -Property Name

# 3. Getting and counting classes in ROOT\CIMV2
$Classes = Get-CimClass -Namespace 'ROOT\CIMV2'  
"There are $($Classes.Count) classes in ROOT\CIMV2"

# 4. Discovering all the namespaces on SRV1
$EAHT = @{ErrorAction = 'SilentlyContinue'}
Function Get-WMINamespaceEnum {
  [CmdletBinding()]
  Param($NS) 
  Write-Output $NS
  Get-CimInstance "__Namespace" -Namespace $NS @EAHT | 
  ForEach-Object { Get-WMINamespaceEnum "$ns\$($_.name)"   }
}  # End of function
$Namespaces = Get-WMINamespaceEnum 'ROOT' | 
  Sort-Object
"There are $($Namespaces.Count) WMI namespaces on SRV1"


# 5. Viewing first 25 namespaces on SRV1
$Namespaces |
  Select-Object -First 25

# 6. Creating a script block to count namespaces and classes
$SB = {
 Function Get-WMINamespaceEnum {
   [CmdletBinding()]
   Param(
     $NS
    ) 
   Write-Output $NS
   $EAHT = @{ErrorAction = 'SilentlyContinue'}
   Get-CimInstance "__Namespace" -Namespace $NS @EAHT | 
     ForEach-Object { Get-WMINamespaceEnum "$NS\$($_.Name)"   }
   }  # End of function
   $Namespaces = Get-WMINamespaceEnum 'ROOT' | Sort-Object
   $WMIClasses = @()
   Foreach ($Namespace in $Namespaces) {
   $WMIClasses += Get-CimClass -Namespace $Namespace
  }
 "There are $($Namespaces.Count) WMI namespaces on $(hostname)"
 "There are $($WMIClasses.Count) classes on $(hostname)"
}

# 7. Running the script block locally on SRV1
Invoke-Command -ComputerName SRV1 -ScriptBlock $SB

# 8. Running the script block on SRV2
Invoke-Command -ComputerName SRV2 -ScriptBlock $SB

# 9. Running the script block on DC1
Invoke-Command -ComputerName DC1 -ScriptBlock $SB