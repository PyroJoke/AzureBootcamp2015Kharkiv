cd webdeploy
# Include Constants
. ..\Constants.ps1
# Adding snapin to the current session
Add-PSSnapin WDeploySnapin3.0
function Get-MSBuildCmd
{
        process
        {

             $path =  Get-ChildItem "HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\" | 
                                   Sort-Object {[double]$_.PSChildName} -Descending | 
                                   Select-Object -First 1 | 
                                   Get-ItemProperty -Name MSBuildToolsPath |
                                   Select -ExpandProperty MSBuildToolsPath
        
            $path = (Join-Path -Path $path -ChildPath 'msbuild.exe')
            return Get-Item $path
    }
}
function New-WebDeployPackage
       {
       Param(
       [string] $ProjectFile,
       [string] $PackageDirectory)
            Write-Verbose 'Build-WebDeployPackage: Start'
            $msbuildCmd = '"{0}" "{1}" /T:Rebuild;Package /P:VisualStudioVersion=12.0 /p:OutputPath="{2}" /flp:logfile=msbuild.log,v=d' -f (Get-MSBuildCmd), $ProjectFile, $PackageDirectory
            Write-Verbose ('Build-WebDeployPackage: ' + $msbuildCmd)
            
            #Start execution of the build command
            $job = Start-Process cmd.exe -ArgumentList('/C "' + $msbuildCmd + '"') -WindowStyle Normal -Wait -PassThru
            if ($job.ExitCode -ne 0)
            {
                throw('MsBuild exited with an error. ExitCode:' + $job.ExitCode)
            }

       
           #Obtain the project name
           $projectName = (Get-Item $ProjectFile).BaseName
       
            #Construct the path to web deploy zip package
           $DeployPackageDir =  '{0}\_PublishedWebsites\{1}_Package' -f $PackageDirectory, $projectName
       
       
           #Get the full path for the web deploy zip package. This is required for MSDeploy to work
           $FullDeployPackage = Resolve-Path –LiteralPath $DeployPackageDir
       
           Write-Verbose 'Build-WebDeployPackage: End'
       
           return $FullDeployPackage
       }

$projectFile = "..\..\CustomerManagerStandard\CustomerManager\CustomerManager.csproj"
$projectName = (Get-Item $ProjectFile).BaseName
$packageDirectory = New-WebDeployPackage -ProjectFile $projectFile -PackageDirectory (Resolve-Path -LiteralPath ".\packages")

# Modify SetParameters.xml
$setParametersFilePath = "{0}\{1}.SetParameters.xml" -f $packageDirectory, $projectName
$xml = [xml] (Get-Content $setParametersFilePath)
$appNode = $xml.parameters.setParameter | where { $_.Name -eq "IIS Web Application Name" }
$appNode.value = "Default Web Site"
$connectionStringNode = $xml.parameters.setParameter | where { $_.Name -eq "CustomerManagerContext-Web.config Connection String" }
$connectionStringNode.value = "Data Source=$SqlServerVMName;Initial Catalog=bootcampdb;Integrated Security=True"
$xml.Save($setParametersFilePath)

# Run MsDeploy and deploy web application to Azure VMs
foreach($virtualMachine in $VirtualMachines){
$deployScript = '{0}\{1}.deploy.cmd' -f $packageDirectory, $projectName
$deployScriptArgs = ' /y /m:https://{0}.cloudapp.net:{1}/msdeploy.axd /u:{2} /p:{3} /a:basic -allowUntrusted' -f $CloudServiceName, $virtualMachine.WebDeployPort.ToString(), $AdminUserName, $AdminUserPassword
# Start MsDeploy
$job = Start-Process -FilePath $deployScript -ArgumentList $deployScriptArgs -WindowStyle Normal -Wait -PassThru
if ($job.ExitCode -ne 0)
{
    throw('MsDeploy exited with an error. ExitCode:' + $job.ExitCode)
}

}