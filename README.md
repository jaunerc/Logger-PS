# Logger-PS
The modules in this repo provides a simple logging solution under Powershell (v3.0 or higher).
It uses the [Pester](https://github.com/pester/Pester) framework for unit testing.

## Start logging
The logger needs to be initialized with a log directory and a log source.
```PowerShell
$logger = New-Logger -logDir ".\test\" -logSource "test.ps1"
```

After that you can start with logging.
```PowerShell
$logger | Write-DebugEntry -logMessage "This is a test message."
```
