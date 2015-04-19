# Import constants
. .\Constants.ps1
# Remote Powershell to created VMs
$secPassword = ConvertTo-SecureString $AdminUserPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AdminUserName, $secPassword)
foreach($virtualMachine in $VirtualMachines){
# Return back the correct URI for Remote PowerShell  
$uri = Get-AzureWinRMUri -ServiceName $CloudServiceName -Name $virtualMachine.Name 

Invoke-Command -ConnectionUri $uri.ToString() -Credential $credential -ScriptBlock {
Set-Alias ps64 "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"
ps64 {
    # Opening WebDeploy port
    "Opening port"
    $port = New-Object -ComObject HNetCfg.FWOpenPort
    $port.Port = 8172
    $port.Name = 'WebDeploy Inbound Port'
    $port.Enabled = $true
    
    $fwMgr = New-Object -ComObject HNetCfg.FwMgr
    $profile = $fwMgr.LocalPolicy.CurrentProfile
    $profile.GloballyOpenPorts.Add($port)

    "Download WebPI cmd line"
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $targetFile = "$desktopPath\WebDeploy_amd64_en-US.msi"
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("http://download.microsoft.com/download/D/4/4/D446D154-2232-49A1-9D64-F5A9429913A4/WebDeploy_amd64_en-US.msi", $targetFile)

    #"Installing WebDeploy on server"
    Invoke-Expression "msiexec.exe /I $targetFile /L*v $env:TEMP\output.log /passive /quiet"
    #Start-Process -FilePath "msiexec.exe" -ArgumentList "/I $targetFile /L*v $env:TEMP\output.log /passive /quiet INSTALLLOCATION=C:/WebDeploy" -Wait
    #Start-Process -FilePath "$env:TEMP\webpi\WebpiCmdLine.exe" -ArgumentList "/Products:WDeployNoSMO /accepteula" -Wait
    #Invoke-Expression "$env:TEMP\webpi\WebpiCmdLine.exe /Products:WDeployNoSMO /accepteula"
}
}
}