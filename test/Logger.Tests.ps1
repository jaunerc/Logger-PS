Import-Module "$PSScriptRoot\..\Logger.psm1" -force

Describe "New-LogName" {
    It "test logname format" {
        New-LogName -logFileFormat "logfile_" | Should Be 'Logfile.log'
    }
	
	It "test logname format with multiple underscores" {
        New-LogName -logFileFormat "logfile_asdf_ff" | Should Be 'logfile_asdf_ff.log'
    }
}

Describe "Convert-LogFormat" {
    It "test log format converting - prefix" {
        Convert-LogFormat -logFormat "logfile" -isPrefix $true | Should Be 'logfile'
    }
	
	It "test log format converting - not prefix" {
        Convert-LogFormat -logFormat "partInTheMiddle" -isPrefix $false | Should Be '_partInTheMiddle'
    }
	
	It "test log format converting - date" {
        Convert-LogFormat -logFormat "%DATE%" -isPrefix $false | Should Be (get-date -uformat "%d_%m_%y")
    }
}

Describe "New-LogFilePath" {
    It "test log file path without backslash" {
        New-LogFilePath -logDir "K:\users\tester" -logFileFormat "logfile" | Should Be 'K:\users\tester\logfile.log'
    }
	
	It "test log file path with backslash" {
        New-LogFilePath -logDir "K:\users\tester\" -logFileFormat "logfile" | Should Be 'K:\users\tester\logfile.log'
    }
}

Describe "New-LogTimeStamp" {
    It "test time format" {
        New-LogTimeStamp -dateTimeFormat "yyyy.MM.d hh:mm" | Should Be (Get-Date -Format "yyyy.MM.d hh:mm")
    }
}

Describe "Get-LogLevelText" {
    It "test log level text - debug" {
        Get-LogLevelText -logLevel 0 | Should Be "DEBUG"
    }
	
	It "test log level text - info" {
        Get-LogLevelText -logLevel 1 | Should Be "INFO"
    }
	
	It "test log level text - warning" {
        Get-LogLevelText -logLevel 2 | Should Be "WARNING"
    }
	
	It "test log level text - error" {
        Get-LogLevelText -logLevel 3 | Should Be "ERROR"
    }
	
	It "test log level text - not supported" {
        try {
			Get-LogLevelText -logLevel -1
		} catch {
			$true | Should Be $true
			return
		}
		$false | Should Be $true
    }
}