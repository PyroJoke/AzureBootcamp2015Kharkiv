Param(
    [string][Parameter(Mandatory=$true)] $WebSiteName,
	[string][ValidateScript({Test-Path $_ -PathType 'Leaf'})] [Parameter(Mandatory=$true)] $ProjectFile,
	[string] $ResourceGroupName = $WebSiteName,
	[string] $StorageAccountName = $ResourceGroupName.ToLowerInvariant() + "storage",
    [string] $StorageContainerName = $WebSiteName.ToLowerInvariant(),
	[string] $LocalStorageDropPath = '.\StorageDrop',
    [string] $AzCopyPath = '.\Tools\AzCopy.exe',
    [string] $TemplateFile = '.\Templates\PublishWebApp.json'
)

$ErrorActionPreference = "Stop";

$wasServiceManagementMode = Get-Module -Name Azure -ListAvailable;


$AzCopyPath = [System.IO.Path]::Combine($PSScriptRoot, $AzCopyPath);
$TemplateFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateFile);
$LocalStorageDropPath = [System.IO.Path]::Combine($PSScriptRoot, $LocalStorageDropPath);

#Build the application
$publishXmlFile = ".\WebDeployPackage.pubxml";

& "$env:windir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" $ProjectFile `
    /p:VisualStudioVersion=12.0 `
    /p:DeployOnBuild=true `
    /p:DesktopBuildPackageLocation=$LocalStorageDropPath `
    /p:PublishProfile=WebDeployPackage.pubxml;

	
Switch-AzureMode -Name AzureServiceManagement;

#Copy application package to the storage
$storageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary;
$storageAccountContext = New-AzureStorageContext $StorageAccountName (Get-AzureStorageKey $StorageAccountName).Primary;
$dropLocation = $storageAccountContext.BlobEndPoint + $StorageContainerName;
& "$AzCopyPath" """$LocalStorageDropPath"" $dropLocation /DestKey:$storageAccountKey /S /Y";

#Set drop location for msdeploy
$dropLocationSasToken = New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $storageAccountContext -Permission r;
$dropLocationSasToken = ConvertTo-SecureString $dropLocationSasToken -AsPlainText -Force;

Switch-AzureMode AzureResourceManager;

#Getting resource group location
$ResourceGroupLocation = (Get-AzureResourceGroup -Name CustomerManage).Location;

New-AzureResourceGroup -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $TemplateFile `
                       -webSiteName $webSiteName `
                       -dropLocation $dropLocation `
                       -dropLocationSasToken $dropLocationSasToken `
					   -webSitePackage "CustomerManager.zip" `
                       -Force `
					   -Verbose;

# Switch back to original mode before exiting 
if ($wasServiceManagementMode) {  
    Switch-AzureMode AzureServiceManagement 
}