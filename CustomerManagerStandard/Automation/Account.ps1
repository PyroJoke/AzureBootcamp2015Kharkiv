<#
 # Create PWD File with this command: 
 # Read-Host -AsSecureString | ConvertFrom-SecureString | out-file C:\Users\dmitry\pwdfile.txt
 #>

$pwdFilePath = "C:\Users\dmitry\pwdfile.txt";
if(!(Test-Path $pwdFilePath)) { throw "PWD File not found"; }

$username = "deployment@dmytromykhailovepam.onmicrosoft.com";
$password =  cat $pwdFilePath | ConvertTo-SecureString;

$deploymentCreds = New-Object System.Management.Automation.PSCredential($username, $password);

Add-AzureAccount -Credential $deploymentCreds;