Param(
    [string][Parameter(Mandatory=$true)] $WebSiteName,
    [string] $ResourceGroupName = $WebSiteName,
    [string] $StorageAccountName = $ResourceGroupName.ToLowerInvariant() + "storage",
    [string] $ResourceGroupLocation = "West Europe",
    [string] $StorageContainerName = $WebSiteName.ToLowerInvariant(),
    [string] $TemplateFile = '.\Templates\WebSiteDeploySQL.json'
)

$ErrorActionPreference = "Stop";

$TemplateFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateFile);

#Define SQL server
$sqlServerName = $WebSiteName.toLowerInvariant() + "server";
$sqlDbName = $WebSiteName.toLowerInvariant() + "db";
$sqlServerAdminLogin = "userDB"
#$plainTextPassword = "P{0}!" -f ([System.Guid]::NewGuid()).Guid.Replace("-", "").Substring(0, 10);
$plainTextPassword = "Qwerty11";
$sqlServerAdminPassword = ConvertTo-SecureString $plainTextPassword -AsPlainText -Force

Switch-AzureMode AzureResourceManager;

$VerbosePreference = "Continue";
New-AzureResourceGroup -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $TemplateFile `
                       -sqlServerName $sqlServerName `
                       -sqlServerLocation $ResourceGroupLocation `
                       -sqlServerAdminLogin $sqlServerAdminLogin `
                       -sqlServerAdminPassword $sqlServerAdminPassword `
                       -sqlDbName $sqlDbName `
                       -webSiteName $webSiteName `
                       -webSiteLocation $ResourceGroupLocation `
                       -webSiteHostingPlanName "Standard2instances" `
                       -webSiteHostingPlanSKU "Standard" `
					             -storageAccountNameFromTemplate $StorageAccountName `
                       -Force `
					             -Verbose;
