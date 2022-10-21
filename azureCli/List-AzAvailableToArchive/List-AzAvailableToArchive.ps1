<#
.DESCRIPTION
    This script allows you to list all available recovery point available to move to the Archive tier on azure recovery service vaults
.PARAMETER subscriptionId
    Subscription where the vault is
.PARAMETER tenantId
    Tenant Id.
.PARAMETER resourceGroupName
    Resource Group where the VM is.
.PARAMETER backupVaultName
    Name of the Recovery Service Vaults
.PARAMETER backupWorkloadType
    Workload type, the value can be AzureIaasVM, AzureStorage, AzureWorkload
.PARAMETER backupType
    Type of the backup, the value can be AzureFileShare, MSSQL, SAPHANA, SAPHanaDatabase, SQLDataBase, VM
.Example 
    ./List-AzAvailableToArchive.ps1 -tenantId <tenantId> `
        -subscriptionId <subscriptionId> `
        -resourceGroupName <vaultResourceGroupName> `
        -backupVaultName <BackupVaultName> `
        -backupWorkloadType <AzureIaasVM> `
        -backupType <VM>
.NOTES
    Version: 1
    Date: 01/24/2022
    Version Notes: This version only checks VM workload.
#>

#Parameters section

param(
    [parameter(Mandatory=$true,HelpMessage="Your tenantid")]
    [string]$tenantId,

    [parameter(Mandatory=$true,HelpMessage="subscriptionId where the backup vault is")]
    [string]$subscriptionId,

    [parameter(Mandatory=$true,HelpMessage="Resource Group where the vault is")]
    [string]$resourceGroupName,

    [parameter(Mandatory=$true,HelpMessage="Name of the vault that you want to check the RPOs")]
    [string]$backupVaultName,

    [parameter(Mandatory=$true,HelpMessage="Workload that you want to check")]
    [string]$backupWorkloadType,

    [parameter(Mandatory=$true,HelpMessage="Type of the backup that you want to check the RPO")]
    [string]$backupType
)


#Azure Login
Write-Host "_______________________________________________" -ForegroundColor DarkBlue

Write-Host "Log-in on Azure Tenant" -ForegroundColor Blue
$null = az login --tenant $tenantId
Write-Host "Selecting Azure Subscription..." -ForegroundColor Blue

$null = az account set --subscription $subscriptionId

Write-Host "Checking Vault Name: $backupVaultName" -ForegroundColor Blue
Write-Host "_______________________________________________" -ForegroundColor DarkBlue

$sessionList = New-Object -TypeName "System.Collections.ArrayList"

$listBackupContainers = az backup container list --backup-management-type $backupWorkloadType  --resource-group $resourceGroupName --vault-name $backupVaultName   | ConvertFrom-Json
$containerList = $listBackupContainers.name

Write-Host "_______________________________________________" -ForegroundColor DarkBlue
Write-Host "Starting vault analysis...."

if($backupWorkloadType -eq "AzureIaasVM" -and $backupType -eq "VM")
{
    foreach($container in $containerList)
    {
        $backupArchiveState = az backup recoverypoint list -g $resourceGroupName -v $backupVaultName -c $container -i $container.Split(";")[3] --backup-management-type $backupWorkloadType --workload-type $backupType --recommended-for-archive | ConvertFrom-Json
        
        if($null -eq $backupArchiveState)
        { 
            Write-Warning -Message "Looking for available RPO's to archive...."
        }
        else
        {
            #Listing Available recovery points

            Write-Host "VM" $container.Split(";")[3]  "Does have avaliable RPO's to archive"
            Write-Host "Number of available recovery Points" $backupArchiveState.properties.recoveryPointTime -ForegroundColor Green
                
                if( $null -eq $backupArchiveState.properties.recoveryPointTime){
                    Write-Warning -Message "Looking for available RPO's to archive...."
                }
                else
                {
                    ForEach($backup in $backupArchiveState)
                    {    
                        #Getting VM 
                        $vmName = $container.Split(";")[3]
                        $vmResourceGroupName = $container.Split(";")[2]
                        $azVmList = az vm show --name $vmName --resource-group $vmResourceGroupName | ConvertFrom-Json
                        #Checking os disk size
                        $osDiskSizeInGib = az disk show --ids $azVmList.storageProfile.osDisk.managedDisk.id | ConvertFrom-Json
                        #checking data disk
                            if ($null -ne $azVmList.storageProfile.dataDisks.managedDisk.id)
                            {
                                #Listing datadisks
                                    foreach ($dataDisk in $azVmList.storageProfile.dataDisks.managedDisk.id){
                                        $getDataDiskSizeInGib = az disk show --ids $dataDisk | ConvertFrom-Json
                                        #variable below will store the sum of the disk sizes
                                        [int]$dataDiskTotalInGib = $dataDiskTotalInGib + $getDataDiskSizeInGib.diskSizeGb
                                    }
                            }
                            #Sum of osDisk + dataDisks
                            $totaUsageSpace = [int]$osDiskSizeInGib.diskSizeGb + [int]$dataDiskTotalInGib
                            
                                $azAdvPoolItems = [PSCustomObject]@{
                                    "backupObjectName" = $container.Split(";")[3];
                                    "azureDataCentre" = $azVmList.location ;
                                    "operatingSystem" = $backup.properties.osType;
                                    "rpoToArchiveDate" = $backup.properties.recoveryPointTime;
                                    "estimatedSpaceUsage" = $totaUsageSpace
                                }
                                $null = $sessionList.Add($azAdvPoolItems) | Format-Table
                        #Cleaning variables
                        $dataDiskTotalInGib = $null
                        $totaUsageSpace = $null
                }       
            }
        }
    }
    #exporting csvFile
    $csvFile = $backupVaultName + ".csv"
    $sessionList | Format-Table | Out-File $csvFile
}
else 
{
    Write-Warning -Message "Function not available..."
}