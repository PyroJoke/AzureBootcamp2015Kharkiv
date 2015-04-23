Param(
    [string][Parameter(Mandatory=$true)] $WebSiteName,
    [string][ValidateScript({Test-Path $_ -PathType 'Leaf'})] [Parameter(Mandatory=$true)] $ProjectFile,
    [string] $ResourceGroupName = $WebSiteName,
    [string] $Prefix = $ResourceGroupName.ToLowerInvariant(),
    [string] $StorageAccountName = $Prefix + "stor",
    [string] $StorageContainerName = ("{0}-{1}" -f $WebSiteName.ToLowerInvariant(), (Get-Date -format "hh-mm-ss-dd-mm-yyyy")),
    [string] $LocalStorageDropPath = '.\StorageDrop',
    [string] $AzCopyPath = '.\Tools\AzCopy.exe',
    [string] $webSitePackage = "CustomerManager.zip",
    [string] $TemplateFile = '.\Templates\PublishWebApp.json'
)

$ErrorActionPreference = "Stop";
$wasServiceManagementMode = Get-Module -Name Azure -ListAvailable;

$AzCopyPath = [System.IO.Path]::Combine($PSScriptRoot, $AzCopyPath);
$TemplateFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateFile);
$LocalStorageDropPath = [System.IO.Path]::Combine($PSScriptRoot, $LocalStorageDropPath);

Push-Location

#Local Drop Cleanup
Remove-Item ($LocalStorageDropPath + '\*') -ErrorAction SilentlyContinue

New-Item $LocalStorageDropPath -ItemType directory -ErrorAction SilentlyContinue

Write-Host "Building and creating msdeploy package..."
#Publish to Local Drop
$publishXmlFile = ".\WebDeployPackage.pubxml";
& "$env:windir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" $ProjectFile `
    /p:VisualStudioVersion=12.0 `
    /p:DeployOnBuild=true `
    /p:DesktopBuildPackageLocation=$LocalStorageDropPath `
    /p:PublishProfile=WebDeployPackage.pubxml;

	
Switch-AzureMode -Name AzureServiceManagement;
Write-Host "Copying application package to the storage..."

$storageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary;
$storageAccountContext = New-AzureStorageContext $StorageAccountName $storageAccountKey;
$dropLocation = $storageAccountContext.BlobEndPoint + $StorageContainerName;
& "$AzCopyPath" """$LocalStorageDropPath"" $dropLocation /DestKey:$storageAccountKey /S /Y";

Write-Host "Setting the drop location for msdeploy..."

$dropLocationSasToken = New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $storageAccountContext -Permission r;
$dropLocationSasToken = ConvertTo-SecureString $dropLocationSasToken -AsPlainText -Force;

Switch-AzureMode AzureResourceManager;

Write-Host "Publishing the application..."

$ResourceGroupLocation = (Get-AzureResourceGroup -Name $ResourceGroupName).Location;
New-AzureResourceGroup -Name $ResourceGroupName `
                       -Location $ResourceGroupLocation `
                       -TemplateFile $TemplateFile `
                       -webSiteName $webSiteName `
                       -dropLocation $dropLocation `
                       -dropLocationSasToken $dropLocationSasToken `
					   -webSitePackage $webSitePackage `
                       -Force `
					   -Verbose;

# Switch back to original mode before exiting 
if ($wasServiceManagementMode) {  
    Switch-AzureMode AzureServiceManagement 
}

Pop-Location