# 5.4 - Create a C# PowerShell Extension

# Run on SRV1

# 1. Examining overloaded method definition
("a string").Trim

# 2. Creating a C# class definition in here string
$NewClass = @"
namespace Reskit {
   public class Hello {
     public static void World() {
         System.Console.WriteLine("Hello World!");
     }
   }
  }   
"@

# 3. Adding the type into the current PowerShell session
Add-Type -TypeDefinition $NewClass

# 4. Examining method definition
[Reskit.Hello]::World

# 5. Using the class's method
[Reskit.Hello]::World()

# 6. Extending the code with parameters
$NewClass2 = @"
using System;
using System.IO;
namespace Reskit {
  public class Hello2  {
    public static void World() {
      Console.WriteLine("Hello World!");
    }
    public static void World(string name) {
      Console.WriteLine("Hello " + name + "!");
    }
  }
}  
"@

# 7. Adding the type into the current PowerShell session
Add-Type -TypeDefinition $NewClass2 -Verbose

# 8. Viewing method definitions
[Reskit.Hello2]::World

# 9. Calling with no parameters specified
[Reskit.Hello2]::World()

# 10. Calling new method with a parameter
[Reskit.Hello2]::World('Jerry')

