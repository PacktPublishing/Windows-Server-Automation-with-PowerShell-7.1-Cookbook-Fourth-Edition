# Recipe 4.5 - Establishing a script signing environment

# Performed on SRV1

# 1. Creating a script-signing self signed certificate
$CHT = @{
  Subject           = 'Reskit Code Signing'
  Type              = 'CodeSigning' 
  CertStoreLocation = 'Cert:\CurrentUser\My'
}
New-SelfSignedCertificate @CHT | Out-Null

# 2. Displaying the newly created certificate
$Cert = Get-ChildItem -Path Cert:\CurrentUser\my -CodeSigningCert
$Cert | 
  Where-Object {$_.SubjectName.Name -match $CHT.Subject}

# 3. Creating and viewing a simple script
$Script = @"
  # Sample Script
  'Hello World from PowerShell 7!'
  "Running on [$(Hostname)]"
"@
$Script | Out-File -FilePath C:\Foo\Signed.ps1
Get-ChildItem -Path C:\Foo\Signed.ps1

# 4. Signing your new script
$SHT = @{
  Certificate = $cert
  FilePath    = 'C:\foo\signed.ps1'
}
Set-AuthenticodeSignature @SHT

# 5. Checking script after signing
Get-ChildItem -Path C:\Foo\Signed.ps1

# 6. Viewing the signed script
Get-Content -Path C:\Foo\Signed.ps1.

# 7. Testing the signature
Get-AuthenticodeSignature -FilePath C:\Foo\Signed.ps1 |
  Format-List

# 8. Running the signed script
C:\Foo\Signed.ps1  

# 9. Setting the execution policy to all signed
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope Process

# 10. Running the signed script
C:\Foo\Signed.ps1  

# 11. Copying Certificate to Current User Trusted Root store
$DestStoreName  = 'Root'
$DestStoreScope = 'CurrentUser'
$Type   = 'System.Security.Cryptography.X509Certificates.X509Store'
$MHT = @{
  TypeName = $Type  
  ArgumentList  = ($DestStoreName, $DestStoreScope)
}
$DestStore = New-Object  @MHT
$DestStore.Open(
  [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$DestStore.Add($Cert)
$DestStore.Close()

# 12. Checking the signature
Get-AuthenticodeSignature -FilePath C:\Foo\Signed.ps1 | 
  Format-List

# 13. Running the signed script
C:\Foo\Signed.ps1  

# 14. Copying cert to Trusted Publisher store
$DestStoreName  = 'TrustedPublisher'
$DestStoreScope = 'CurrentUser'
$Type   = 'System.Security.Cryptography.X509Certificates.X509Store'
$MHT = @{
  TypeName = $Type  
  ArgumentList  = ($DestStoreName, $DestStoreScope)
}
$DestStore = New-Object  @MHT
$DestStore.Open(
  [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$DestStore.Add($Cert)
$DestStore.Close()

# 15. Running the signed script
C:\Foo\Signed.ps1  



# UnDo 

Gci cert:\ -recurse | where subject -match 'Reskit Code Signing' | RI -Force
ri C:\foo\signed.ps1


