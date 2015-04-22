Get-AzureVM | Remove-AzureVM
"Delete VMs disks also"
while(Get-AzureDisk | Where-Object { $_.AttachedTo -like "RoleName*" }){
sleep -Seconds 10
}
Get-AzureDisk | Remove-AzureDisk -DeleteVHD