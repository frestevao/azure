# Enable-AzAcceleratedNetworkingMultipleVMs

## __WHAT IS THIS?__
#

This script allows you to enable Accelerated Networking on Multiples VM's. To better understand this script, please check the [post](https://techf.cloud/index.php/2022/03/01/enabling-accelerated-networking-on-multiples-vms/) on my blog.

#
## __REQUIREMENTS__
#

* Most recent version of Azure CLI.
    - ref: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
* Validade if your OS is able to use this feature..
    - linux/windows: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-operating-systems
* This resource isn't avaliable to all VMs sizes.
    - VM Should have at least 4 vCPUS.
        - ref: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances

````powershell
#Exemplo de execução:

./Enable-AzAcceleratedNicMultipleVMs.ps1 -subscriptionId <SubscriptionId> -tenantId <TenantId> -resourceGroupName <ResourceGroupName>

````

#
.NOTES

    I'm not responsible for any damage that you may cause.
    Please, review the code before running on production environment.
    Don't do tests on production environments.