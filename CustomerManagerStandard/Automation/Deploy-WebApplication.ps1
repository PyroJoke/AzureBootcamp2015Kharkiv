Param(
    [string][Parameter(Mandatory=$true)] $WebSiteName,
    [string][Parameter(Mandatory=$true)] $ProjectFile,
    [string] $ResourceGroupName = $WebSiteName,
    [string] $StorageAccountName = $ResourceGroupName.ToLowerInvariant() + "storage",
    [string] $ResourceGroupLocation = "West Europe",
    [string] $StorageContainerName = $WebSiteName.ToLowerInvariant(),
    [string] $TemplateFile = '.\Templates\Environment.json',
    [string] $LocalStorageDropPath = '.\StorageDrop',
    [string] $AzCopyPath = '.\Tools\AzCopy.exe'
)

<#
    Since we rely on environment creation script, read most of the 
    info from settings file created by the script.
#>

$VerbosePreference = "Continue";
$ErrorActionPreference = "Stop";

$AzCopyPath = [System.IO.Path]::Combine($PSScriptRoot, $AzCopyPath);
$TemplateFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateFile);
$TemplateParametersFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile);
$LocalStorageDropPath = [System.IO.Path]::Combine($PSScriptRoot, $LocalStorageDropPath);

#Build the application
$publishXmlFile = ".\WebDeployPackage.pubxml";

& "$env:windir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" $ProjectFile `
    /p:VisualStudioVersion=12.0 `
    /p:DeployOnBuild=true `
    /p:DesktopBuildPackageLocation=$LocalStorageDropPath `
    /p:PublishProfile=WebDeployPackage.pubxml;

Switch-AzureMode -Name AzureServiceManagement;

#Create new Azure Storage if it does not exist
if(!(Test-AzureName -Storage $StorageAccountName)) {
    $storageAcct = New-AzureStorageAccount -StorageAccountName $StorageAccountName -Location $ResourceGroupLocation -Verbose;
    if ($storageAcct)
    {
        Write-Verbose "[Finish] creating $Name storage account in $Location location"
    }
    else
    {
        throw "Failed to create a Windows Azure storage account. Failure in New-AzureStorage.ps1"
    }
}

#Copy application package to the storage
$storageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary
$storageAccountContext = New-AzureStorageContext $StorageAccountName (Get-AzureStorageKey $StorageAccountName).Primary
$dropLocation = $storageAccountContext.BlobEndPoint + $StorageContainerName
& "$AzCopyPath" """$LocalStorageDropPath"" $dropLocation /DestKey:$storageAccountKey /S /Y"

$dropLocationSasToken = New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $storageAccountContext -Permission r 
$dropLocationSasToken = ConvertTo-SecureString $dropLocationSasToken -AsPlainText -Force

#Define sql server
$sqlServerName = "dmresource1server"
$sqlDbName = "dmres1"
$sqlServerAdminLogin = "userDB"
#$plainTextPassword = "P{0}!" -f ([System.Guid]::NewGuid()).Guid.Replace("-", "").Substring(0, 10);
$plainTextPassword = "Qwerty11"
$sqlServerAdminPassword = ConvertTo-SecureString $plainTextPassword -AsPlainText -Force

Switch-AzureMode AzureResourceManager;
New-AzureResourceGroupDeployment -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $TemplateFile `
                       -dropLocation $dropLocation `
                       -dropLocationSasToken $dropLocationSasToken `
                       -sqlServerName $sqlServerName `
                       -sqlServerLocation $ResourceGroupLocation `
                       -sqlServerAdminLogin $sqlServerAdminLogin `
                       -sqlServerAdminPassword $sqlServerAdminPassword `
                       -sqlDbName $sqlDbName `
                       -webSiteName $webSiteName `
                       -webSiteLocation $ResourceGroupLocation `
                       -webSiteHostingPlanName "FreePlan" `
                       -webSiteHostingPlanSKU "Free" `
                       -webSitePackage "CustomerManager.zip" `
                       -Force -Verbose;
