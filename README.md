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

This action will produce the following log entry (with the default log properties).
```
[2017.08.25 03:07:26,542]|DEBUG|test.ps1|This is a test message.
```
