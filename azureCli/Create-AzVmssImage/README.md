# Create-AzVmssImage

This script allows you to create a new image in the Azure Compute Gallery based on existend VMSS instance.

#
## HOW TO USE?
#

```powershell

#To execute the script you need to add value on the variables below

#Azure Login Parameters

$tenantId = ""
$subscriptionId = ""

#Instance Parameters

$vmssName = "" #VMSSName
$resourceGroupName = "" #VMSS ResourceGroup
$snapshotName = "" #Name of the Snapshot
$instanceId =  #Instance that you want to take a snapshot

#Azure Compute gallery Parameters

$galleryName = "" #Azure Compute Gallery Name
$galleryImageDefinition = "" #Image Definition Name
$imageVersion = "" #Version Id, Example -> 20.30.40
```

#
.NOTES

    I'm not responsible for any damage that you may cause.
    Please, review the code before running on production environment.
    Don't make tests on production environments.