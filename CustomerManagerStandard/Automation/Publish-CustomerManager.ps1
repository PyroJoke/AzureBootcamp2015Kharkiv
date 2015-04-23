. $PSScriptRoot\Account.ps1

$webSiteName = "skrcmanager"
$prefix = "skrcm"

$projectFilePath = "$PSScriptRoot\..\CustomerManager\CustomerManager.csproj"

& $PSScriptRoot\Publish-WebApplication.ps1 -WebSiteName $webSiteName -ProjectFile $projectFilePath -Prefix $prefix