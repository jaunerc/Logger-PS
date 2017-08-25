Import-Module "$PSScriptRoot\..\LoggerHousekeeper.psm1" -force

Describe "Get-LastAcceptedDate" {
    It "test accepted date" {
        Get-LastAcceptedDate -logMaxAgeDays 10 | Should Be ((get-date).addDays(-10).Date)
    }
}