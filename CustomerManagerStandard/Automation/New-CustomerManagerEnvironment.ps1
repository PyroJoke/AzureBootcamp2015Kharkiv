Param(
    [string] [Parameter(Mandatory=$true)]$ResourceGroupName,
    [string] $StorageAccountName = $ResourceGroupName.ToLowerInvariant() + "storage",
    [string] $ResourceGroupLocation = "West Europe",
    [string] $TemplateFile = '.\Templates\StorageSql.json'
)

$VerbosePreference = "Continue";
$ErrorActionPreference = "Stop";

#Define sql server
$sqlServerName = $ResourceGroupName.ToLowerInvariant() + "server";
$sqlDbName = "dmres1";
$sqlServerAdminLogin = "userDB";
#$plainTextPassword = "P{0}!" -f ([System.Guid]::NewGuid()).Guid.Replace("-", "").Substring(0, 10);
$plainTextPassword = "Qwerty11";
$sqlServerAdminPassword = ConvertTo-SecureString $plainTextPassword -AsPlainText -Force;

Switch-AzureMode AzureResourceManager;

New-AzureResourceGroup -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $TemplateFile `
                       -sqlServerName $sqlServerName `
                       -sqlServerLocation $ResourceGroupLocation `
                       -sqlServerAdminLogin $sqlServerAdminLogin `
                       -sqlServerAdminPassword $sqlServerAdminPassword `
                       -sqlDbName $sqlDbName `
                       -storageAccountNameFromTemplate $StorageAccountName `
                       -Force -Verbose;
