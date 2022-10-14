# New-AzSigImageVersion

## __WHAT IS THIS?__
#

This script allows you to create a new image version. To learn more about this automation, please take a look on this [article](https://techf.cloud/index.php/2022/03/28/azure-compute-gallery-automation/).

#
## __REQUIREMENTS__
#

* Most recent version of Azure CLI.
    - ref: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
* Execute the agent deprovision.
    - linux: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disable-provisioning#deprovision-and-create-an-image
    - windows: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation?view=windows-11#generalize-an-image


````powershell
#Execution sample:

./New-AzSigImageVersion -subscriptionId <subscriptionId> -tenantId <tenantId> -VmResourceGroupName <VmResourceGroupName> -SigVmVmResourceGroupName <SigVmVmResourceGroupName> -vmName <VmName> -sigName <SigName> -imageDefinition <imageDefinition> -imageVersion <imageVersion>

````

#
.NOTES

    I'm not responsible for any damage that you may cause.
    Please, review the code before running on production environment.
    Don't do tests on production environments.