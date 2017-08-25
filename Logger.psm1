
$LEVEL_DEBUG = 0
$LEVEL_INFO = 1
$LEVEL_WARNING = 2
$LEVEL_ERROR = 3

$PROPERTIES_FILEPATH = ".\logger.properties"
$PROPERTIES_KEY_TIMEFORMAT = "log.timeformat"
$PROPERTIES_KEY_SEPARATOR = "log.separator"
$PROPERTIES_KEY_FILEFORMAT = "log.fileformat"

$LOGFILE_PATTERN_DATE = "%DATE%"

<#
.SYNOPSIS
Creates a new logger object.

.DESCRIPTION
A logger object stores basic log informations.
The log properties are read from the log.properties file. This function doesn't write anything to the logfile.

.PARAMETER logDir
The directory of the logfile.

.PARAMETER logSource
The source of the log messages (e.g. a ps script filename or function)

.EXAMPLE
$logger = New-Logger -logDir ".\test\" -logSource "test.ps1"
Creates a new logger object for a test.ps1 file. The logfile will be saved in .\test.

#>
function New-Logger {
	param(
		[Parameter(Mandatory=$true)]
		[string]$logDir,
		[Parameter(Mandatory=$true)]
		[string]$logSource
	)
	
	$logProperties = Get-LogProperties
	$LogFilePath = New-LogFilePath -logDir $logDir -logFileFormat ($logProperties.item($PROPERTIES_KEY_FILEFORMAT))
	
	new-object psobject -property @{
		logFilePath = $LogFilePath
		logSource = $logSource
		logProperties = $logProperties
	}
}

function New-LogFilePath {
	param(
		[Parameter(Mandatory=$true)]
		[string]$logDir,
		[Parameter(Mandatory=$true)]
		[string]$logFileFormat
	)
	if (-not $logDir.endsWith("\")) {
		$logDir += "\"
	}
	return ($logDir + (New-LogName -logFileFormat $logFileFormat))
}

function New-LogName {
	param(
		[Parameter(Mandatory=$true)]
		[string]$logFileFormat
	)
	$splittedFormat = $logFileFormat.split("_")
	$logFileName = ""
	for($i=0; $i -lt $splittedFormat.length; $i++) {
		if($splittedFormat[$i].Length -ne 0) {
			$logFileName += Convert-LogFormat -logFormat ($splittedFormat[$i]) -isPrefix ($i -eq 0)
		}
	}
	$logFileName += ".log"
	return $logFileName
}

function Convert-LogFormat {
	param(
		[Parameter(Mandatory=$true)]
		[string]$logFormat,
		[Parameter(Mandatory=$true)]
		[boolean]$isPrefix
	)
	if(-not $isPrefix) {
		$logNamePart = "_"
	}
	$logNamePart += $logFormat
	if($logFormat.equals($LOGFILE_PATTERN_DATE)) {
		$logNamePart = get-date -uformat "%d_%m_%y"
	}
	return $logNamePart
}

function Get-LogProperties {
	return ConvertFrom-StringData (get-content $PROPERTIES_FILEPATH -raw)
}

<#
.SYNOPSIS
Writes an info state to the logfile.

.DESCRIPTION
Writes an info state to the logfile without loglevel.

.EXAMPLE
$logger | Write-InitState

#>
function Write-InitState {
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		[string]$logFilePath
	)
	ECHO "**********************************************************************" | Out-File -FilePath $logFilePath -append
	ECHO ("Logfile from " + (get-date)) | Out-File -FilePath $logFilePath -append
	ECHO "**********************************************************************" | Out-File -FilePath $logFilePath -append
}

function Write-DebugEntry {
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		[string]$logFilePath,
		[Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
		[string]$logSource,
		[Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
		$logProperties,
		[Parameter(Mandatory=$true)]
		[string]$logMessage
	)
	Write-LogEntry -logFilePath $logFilePath -logSource $logSource -logProperties $logProperties -logLevel $LEVEL_DEBUG -logMessage $logMessage
}

function Write-InfoEntry {
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		[string]$logFilePath,
		[Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
		[string]$logSource,
		[Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
		$logProperties,
		[Parameter(Mandatory=$true)]
		[string]$logMessage
	)
	Write-LogEntry -logFilePath $logFilePath -logSource $logSource -logProperties $logProperties -logLevel $LEVEL_INFO -logMessage $logMessage
}

function Write-WarningEntry {
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		[string]$logFilePath,
		[Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
		[string]$logSource,
		[Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
		$logProperties,
		[Parameter(Mandatory=$true)]
		[string]$logMessage
	)
	Write-LogEntry -logFilePath $logFilePath -logSource $logSource -logProperties $logProperties -logLevel $LEVEL_WARNING -logMessage $logMessage
}

function Write-ErrorEntry {
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		[string]$logFilePath,
		[Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
		[string]$logSource,
		[Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
		$logProperties,
		[Parameter(Mandatory=$true)]
		[string]$logMessage
	)
	Write-LogEntry -logFilePath $logFilePath -logSource $logSource -logProperties $logProperties -logLevel $LEVEL_ERROR -logMessage $logMessage
}

<#
.SYNOPSIS
Writes a new message to the logfile.

.DESCRIPTION
Writes the given text and loglevel in the correct format to the logfile.

.PARAMETER logLevel
The level of this message.

.PARAMETER logMessage
The text of this message.

.EXAMPLE
$logger | Write-LogEntry -logLevel $LEVEL_DEBUG -logMessage "This is a test message."


#>
function Write-LogEntry {
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		[string]$logFilePath,
		[Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
		[string]$logSource,
		[Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
		$logProperties,
		[Parameter(Mandatory=$true)]
		[int]$logLevel,
		[Parameter(Mandatory=$true)]
		[string]$logMessage
	)
	$separator = $logProperties.item($PROPERTIES_KEY_SEPARATOR)
	$dateTimeFormat = $logProperties.item($PROPERTIES_KEY_TIMEFORMAT)
	$logTimeStamp = New-LogTimeStamp -dateTimeFormat $dateTimeFormat
	$logLevelText = Get-LogLevelText -logLevel $logLevel
	("[{1}]{0}{2}{0}{3}{0}{4}" -f $separator, $logTimeStamp, $logLevelText, $logSource, $logMessage) | Out-File -FilePath $logFilePath -append
	
}

function New-LogTimeStamp {
	param(
		[Parameter(Mandatory=$true)]
		[string]$dateTimeFormat
	)
	return Get-Date -Format $dateTimeFormat
}

function Get-LogLevelText {
	param(
		[Parameter(Mandatory=$true)]
		[int]$logLevel
	)
	switch($logLevel) {
		0 { $statusText = "DEBUG"; break }
		1 { $statusText = "INFO"; break }
		2 { $statusText = "WARNING"; break }
		3 { $statusText = "ERROR" }
	}
	if($statusText -eq $null) {
		throw "The loglevel $logLevel is not supported."
	}
	return $statusText
}

export-modulemember -Variable LEVEL_*
export-modulemember -Function *