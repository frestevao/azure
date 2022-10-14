<#
Author: Estevão F.
Date: 07/09/2021
Version: v1
Description: Enable Azure Disk Encryption
#>

$vmName = ""
$resourceGroupName = "LABESTE"
$subscriptionId = ""
$tenantId = ""
$keyVaultName = ""
$customKey = "" # Fill this with the KEK URI
$useCustomKey = "True" #|True to use KEK #|False to not Use

#Don't do Changes After here

#Login on Azure Tenant
Write-Host "Login on Azure tenant"
az login --tenant $tenantId --verbose

Start-Sleep -Seconds 10

#Select Azure Subscription
Write-Host "Selecting your Subscription" -ForegroundColor Green
az account set --subscription $subscriptionId --verbose

Start-Sleep -Seconds 10

# Checking Keyvault Status
$kvStatus = az keyvault show --name $keyVaultName | ConvertFrom-Json
if ($kvStatus.properties.enabledForDiskEncryption -ne "True"){
    Write-Host "Key Vault not allowed to use Disk Encryption" -ForegroundColor Red
    Write-Warning -Message "Failure"
    exit
}else {
    Write-Host "KeyVault allowed to use Disk Encryption" -ForegroundColor Green
}

#Check VM Encryption Status
$vmEncryptStatus = az vm encryption show --name $vmName --resource-group $resourceGroupName | ConvertFrom-json

if ($null -eq  $vmEncryptStatus){
    Write-Host "Disk Encryption Not Enabled..." -ForegroundColor Red
    Write-Host "Starting Disk Encryption Process!!" -ForegroundColor Cyan
    # After validade the Encryption Status, the script will check the variable "UseCustomKey"
    # If this variable is True, it will use the a Key Encryption Key to encrypt the disks.
    # Id not, will encrypt the VM withou the KEK
    if ($useCustomKey -eq "True"){

        # Enable using KEK
        Write-Host "We'll set the Disk Encryption with the CustomKey informed" -ForegroundColor Green
        az vm encryption enable --resource-group $resourceGroupName --name $vmName --disk-encryption-keyvault  $keyVaultName --key-encryption-key $customKey --volume-type All
        Write-Host "Encryption Executed. Checking Status..." -ForegroundColor Blue
            $encryption = az vm encryption show --name $vmName --resource-group $resourceGroupName | ConvertFrom-json
            $disklist = New-Object -TypeName "System.Collections.ArrayList"
            foreach ($encryptedDisk in $encryption.disks){
                $diskpoolproperty = [PSCustomObject]@{
                    "Disk Name" = $encryptedDisk.Name;
                    "EncryptionStatus" = $encryptedDisk.statuses.displayStatus;
                    "keyEncryptionKey" = $encryptedDisk.encryptionSettings.keyEncryptionKey.keyUrl;
                    "SourceVault" = $encryptedDisk.encryptionSettings.keyEncryptionKey.sourceVault.id
                }
                # Write-Output $encryptedDisk.Name
                $null = $disklist.Add($diskpoolproperty) | Format-Table
            }
    
    }else{
        
        # Enable on Running VM
        Write-Host "We'll set the Disk Encryption without a KEK" -ForegroundColor Cyan
        az vm encryption enable --resource-group $resourceGroupName --name $vmName --disk-encryption-keyvault $keyVaultName --volume-type All
        Write-Host "Encryption Executed. Checking Status..." -ForegroundColor Blue
            $encryption = az vm encryption show --name $vmName --resource-group $resourceGroupName | ConvertFrom-json
            $disklist = New-Object -TypeName "System.Collections.ArrayList"
            foreach ($encryptedDisk in $encryption.disks){
                $diskpoolproperty = [PSCustomObject]@{
                    "Disk Name" = $encryptedDisk.Name;
                    "EncryptionStatus" = $encryptedDisk.statuses.displayStatus;
                    "DiskEncryptionKey" = $encryptedDisk.encryptionSettings.diskEncryptionKey.secretUrl;
                    "SourceVault" = $encryptedDisk.encryptionSettings.diskEncryptionKey.sourceVault.id
                }
                # Write-Output $encryptedDisk.Name
                $null = $disklist.Add($diskpoolproperty) | Format-Table
                
            }
            
        }



}else {
    Write-Host "Disk Encryption Enabled" -ForegroundColor Green
    Write-Host "The Encryption settings are..."
    $encryption = az vm encryption show --name $vmName --resource-group $resourceGroupName | ConvertFrom-json
    $disklist = New-Object -TypeName "System.Collections.ArrayList"
    foreach ($encryptedDisk in $encryption.disks){
        $diskpoolproperty = [PSCustomObject]@{
            "Disk Name" = $encryptedDisk.Name;
            "EncryptionStatus" = $encryptedDisk.statuses.displayStatus;
            "keyEncryptionKey" = $encryptedDisk.encryptionSettings.keyEncryptionKey.keyUrl;
            "SourceVault" = $encryptedDisk.encryptionSettings.keyEncryptionKey.sourceVault.id
        }
        # Write-Output $encryptedDisk.Name
        $null = $disklist.Add($diskpoolproperty) | Format-Table         
    }
}

$disklist | Format-List *
