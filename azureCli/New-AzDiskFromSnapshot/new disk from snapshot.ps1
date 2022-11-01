<#
.DESCRIPTION
    This script allows you to list all available recovery point available to move to the Archive tier on azure recovery service vaults
.PARAMETER subscriptionId
    Subscription where the vault is
.PARAMETER tenantId
    Tenant Id.
.PARAMETER resourceGroupName
    Resource Group where you'll store the snapshot and disk
.PARAMETER snapShotName
    Name of the snapshot that you'll create
.PARAMETER newDiskName
    Name of the new managed disk
.PARAMETER sourceDiskUri
    Uri of the managedDisk or vhd url
.Example 

./New-AzDiskFromSnapshot.ps1 -tenantId "<tenantId>" `
                                -subscriptionId "<subscriptionId>" `
                                -resourceGroupName "<resourceGroupName>" `
                                -snapShotName "NewDiskSnapShow" `
                                -newDiskName "newDiskBasedOnSnapshot" `
                                -sourceDiskUri "/subscriptions/<SubscriptionId>/resourceGroups/<DiskRG>/providers/Microsoft.Compute/disks/<ManagedDiskName>"

.NOTES
    Version: 1
    Date: 11/01/2022

#>

param(
    [parameter(Mandatory=$true,HelpMessage="Your tenantid")]
    [string]$tenantId,

    [parameter(Mandatory=$true,HelpMessage="subscriptionId where the backup vault is")]
    [string]$subscriptionId,

    [parameter(Mandatory=$true,HelpMessage="Name of the resourceGroup where you'll save the snapshot and new disk")]
    [string]$resourceGroupName,

    [parameter(Mandatory=$true,HelpMessage="Name of the new snapshot")]
    [string]$snapShotName,

    [parameter(Mandatory=$true,HelpMessage="Name of the new disk")]
    [string]$newDiskName,

    [parameter(Mandatory=$true,HelpMessage="URI of the disk that you want to create a new disk")]
    [string]$sourceDiskUri
)

Write-Host "_________________________________________________" -ForegroundColor Cyan
Write-Host "Log-in on Azure tenant...." -ForegroundColor Cyan
$null = az login --tenant $tenantId --verbose

Write-Host "Selecting azureSubscription" -ForegroundColor Cyan
$null = az account set --subscription $subscriptionId
Write-Host "_________________________________________________" -ForegroundColor Cyan

Write-Host "Checking parameters..."

if($null -eq $resourceGroupName -or $snapShotName -or $newDiskName -or $sourceDiskUri)
{
    Write-Warning -Message "Variables cannot be empty"
    exit 0
}
else
{
    Write-Host "Variables full filled" -ForegroundColor Green
    Write-Host "Moving forward ...." -ForegroundColor Green
}

Write-Host "Generating disk snapshot..." -ForegroundColor Green

$newSnapshot = az snapshot create -g $resourceGroupName -n $snapShotName --source $sourceDiskUri --verbose --debug | ConvertFrom-Json

Write-Host "Checking Snapshot integrity"
if($newSnapshot.provisioningState -ne "Succeeded")
{
    Write-Warning -Message "Snapshot compromissed"
}
else
{
    Write-Host "Snapshot provisioned with success!" -ForegroundColor Green
    Write-Host $newSnapshot.name -ForegroundColor Green
    Write-Host "Moving foward with the new disk deployment..." -ForegroundColor Green
}

Write-Host "Getting snapshotUri..." -ForegroundColor Green

$newDisk = az disk create -g $resourceGroupName -n $newDiskName --source $newSnapshot.id --verbose --debug | ConvertFrom-Json
Write-Host "Checking disk integrity...." -ForegroundColor Green
if($newDisk.provisioningState -ne "Succeeded")
{
    Write-Warning -Message "Disk compromissed"
}
else
{
    Write-Host "Disk provisioned with success!" -ForegroundColor Green
    Write-Host $newDisk.name -ForegroundColor Green
    Write-Warning -Message "Do you want to move forward and delete the snapshot?"
    Write-Warning -Message "Insert yes (to delete) or no (to keep de snapshot)"
        $deleteSnapShot = Read-Host
    
    if($deleteSnapShot -eq "yes")
    {
        Write-Host "Deleting snapshot...." -ForegroundColor Red
        $remove = az snapshot delete --ids $newSnapshot.id --debug --verbose | ConvertFrom-Json
        $remove.status
    }
    else
    {
        Write-Host "Nothing to do...."
    }
}