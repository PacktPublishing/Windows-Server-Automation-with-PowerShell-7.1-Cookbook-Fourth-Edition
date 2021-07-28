# 9.1 Exploring WMI namespaces
#
# Run on SRV1


# 1. Viewing Win32_Share class
Get-CimClass -ClassName Win32_Share

# 2. Viewing Win32_Share class properties
Get-CimClass -ClassName Win32_Share |
  Select-Object -ExpandProperty CimClassProperties |
    Sort-Object -Property Name |
      Format-Table -Property Name, CimType

# 3. Getting methods of Win32_Share class
Get-CimClass -ClassName Win32_Share |
  Select-Object -ExpandProperty CimClassMethods

# 4. Getting classes in a non-default namespace
Get-CimClass -Namespace root\directory\LDAP |
  Where-Object CimClassName -match '^ds_group'


# 5. Viewing the instances of the ds_group class
Get-CimInstance -Namespace root\directory\LDAP -Classname 'DS_Group' |
  Select -First 10 |
    Format-Table -Property DS_name, DS_Member