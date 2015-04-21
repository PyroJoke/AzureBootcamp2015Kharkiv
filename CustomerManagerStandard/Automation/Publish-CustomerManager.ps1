. $PSScriptRoot\Account.ps1

$webSiteName = "CustomerManager"
$projectFilePath = "$PSScriptRoot\..\CustomerManager\CustomerManager.csproj"

& $PSScriptRoot\Publish-WebApplication.ps1 -WebSiteName $webSiteName -ProjectFile $projectFilePath