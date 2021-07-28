# 5.5 Create New Cmdlet

# Run on SRV1 after loading PowerShell

# 1. Installling the .NET SDK
# Navigate to "https://dotnet.microsoft.com/download/" and go from there

# 2. Creating the cmdlet folder
New-Item -Path C:\Foo\Cmdlet -ItemType Directory -Force
Set-Location C:\Foo\Cmdlet

# 3. Creating a new lass library project
dotnet new classlib --name SendGreeting

# 4. Viewing contents of new folder
Set-Location -Path .\SendGreeting
Get-ChildItem

# 5. Creating and displaying global.json
dotnet new globaljson
Get-Content -Path .\global.json

# 6. Adding PowerShell package
dotnet add package PowerShellStandard.Library

# 7. Create the cmdlet source file
$Cmdlet = @"
using System.Management.Automation;  // Windows PowerShell assembly.
namespace Reskit
{
  // Declare the class as a cmdlet
  // Specify verb and noun = Send-Greeting
  [Cmdlet(VerbsCommunications.Send, "Greeting")]
  public class SendGreetingCommand : PSCmdlet
  {
    // Declare the parameters for the cmdlet.
    [Parameter(Mandatory=true)]
    public string Name
    {
      get { return name; }
      set { name = value; }
    }
    private string name;
    // Override the ProcessRecord method to process the
    // supplied name and write a geeting to the user by 
    // calling the WriteObject method.
    protected override void ProcessRecord()
    {
      WriteObject("Hello " + name + " - have a nice day!");
    }
  }
}
"@
$Cmdlet | Out-File .\SendGreetingCommand.cs

# 8. Removing the unused class file 
Remove-Item -Path .\Class1.cs

# 9. Building the cmdlet
dotnet build 

# 10. Importing the DLL holding the cmdlet
$DLLPath = '.\bin\Debug\net5.0\SendGreeting.dll'
Import-Module -Name $DLLPath

# 11. Examining the module's details
Get-Module SendGreeting

# 12. Using the cmdlet
Send-Greeting -Name 'Jerry Garcia'