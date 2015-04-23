Param(
    [Parameter(Mandatory=$true)] 
    [string]$WebSiteName,
    [string] $ResourceGroupName = $WebSiteName,
    [string] $Prefix = $ResourceGroupName.ToLowerInvariant(),
    [string] $StorageAccountName = $Prefix + "stor",
    [string] $ResourceGroupLocation = "West Europe",
    [string] $StorageContainerName = $WebSiteName.ToLowerInvariant(),
    [string] $TemplateFile = '.\Templates\WebSiteDeploySQL.json'
)

$ErrorActionPreference = "Stop";

$TemplateFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateFile);

#Define SQL server
$sqlServerName = ($Prefix + "-" +  "sqlserver01").ToLowerInvariant();
$sqlDbName = $Prefix + $WebSiteName +  "db";
$sqlServerAdminLogin = "userDB"
$plainTextPassword = "P{0}!" -f ([System.Guid]::NewGuid()).Guid.Replace("-", "").Substring(0, 10);
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
