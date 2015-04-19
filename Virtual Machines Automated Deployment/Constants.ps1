$VirtualMachines = @([pscustomobject]@{ Name = "bootcampvm0"; WebDeployPort = 8080 }, [pscustomobject]@{ Name = "bootcampvm1"; WebDeployPort = 8081 })
$AdminUserName = "BootcampAdmin"
$AdminUserPassword = "some@strongPassword1"
$CloudServiceName = "azurebootcamp2015kh"
$DefaultSubscription = "Windows Azure MVP - Visual Studio Ultimate"
$StorageAccountName = "azurebootcamp2015kh"
$Region = "West Europe"
$SqlServerVMName = "bootcampSQL";