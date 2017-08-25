Import-Module "$PSScriptRoot\Logger.psm1" -force

$PROPERTIES_FILEPATH = ".\logger.properties"
$PROPERTIES_MAXAGE_DAYS = "housekeeper.maxage.days"

<#
.SYNOPSIS
Creates a new housekeeper object.

.DESCRIPTION
A housekeeper object stores basic informations.
The properties are read from the log.properties file.

.PARAMETER logDir
The directory of the logfiles.

.PARAMETER logger
Instance of a logger object.

.EXAMPLE
$housekeeper = New-LogHousekeeper -logDir ".\test\" -logger $logger

#>
function New-LogHousekeeper {
	param(
		[Parameter(Mandatory=$true)]
		[string]$logDir,
		[Parameter(Mandatory=$true)]
		$logger
	)
	$logProperties = Get-LogProperties
	new-object psobject -property @{
		logDir = $logDir
		logProperties = $logProperties
		logger = $logger
	}
}

<#
.SYNOPSIS
Removes old logfiles in the log directory.

.DESCRIPTION
This function deletes all expired log-files in the log directory.

.EXAMPLE
$housekeeper | Remove-OldLogs

#>
function Remove-OldLogs {
	param(
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		[string]$logDir,
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		$logProperties,
		[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
		$logger
	)
	$logMaxAge = $logProperties.item($PROPERTIES_MAXAGE_DAYS)
	$lastAcceptedDate = Get-LastAcceptedDate -logMaxAgeDays $logMaxAge
	$logfiles = Get-ChildItem -Path $logDir -Filter *.log
	
	foreach($file in $logfiles) {
		$lastWriteDate = $file.LastWriteTime.Date
		if($lastWriteDate -lt $lastAcceptedDate) {
			$result = Remove-Logfile -logfilePath ($file.FullName)
			if($result) {
				$logger | Write-InfoEntry -logMessage ("Logfile " + $file.Name + " was deleted.")
			} else {
				$logger | Write-ErrorEntry -logMessage ("Unable to delete logfile " + $file.Name)
			}
		}
	}
}

function Get-LastAcceptedDate {
	param(
		[Parameter(Mandatory=$true)]
		[int]$logMaxAgeDays
	)
	return ((get-date).addDays(-$logMaxAgeDays).Date)
}

function Remove-Logfile {
	param(
		[Parameter(Mandatory=$true)]
		[string]$logfilePath
	)
	$fileWasDeleted = $true
	try {
		Remove-Item $logfilePath -ErrorAction Stop
	} catch {
		$fileWasDeleted = $false
	}
	return $fileWasDeleted
}

function Get-LogProperties {
	return ConvertFrom-StringData (get-content $PROPERTIES_FILEPATH -raw)
}