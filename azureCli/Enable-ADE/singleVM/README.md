# Enable-ADESingleVM

## __WHAT IS THIS SCRIPT?__
---
This scripts aloows you to deploy Azure Disk Encryption on a specific VM.

    - ref: https://docs.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview

## __REQUIREMENTS__
#


* Most recent version of Azure CLI.
    - ref: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
* Check if your operate system supports ADE.
    - linux: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disk-encryption-overview#supported-vms-and-operating-systems
    - windows: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-overview#supported-operating-systems

````powershell

#Azure Login parameters
$tenantId = "" #Tenat que será utilizado
$subscriptionId = "" #Subscription que contem as VM's

#Automation parameters
$resourceGroupToEncrypt = "" #Resource Group com as VM's que serão criptografadas.
$azureKeyVaultName = "" #KeyVault que contém a KEK.
$customKey = "" # KEK URI

````

#
.NOTES

    I'm not responsible for any damage that you may cause.
    Please, review the code before running on production environment.
    Don't do tests on production environments.