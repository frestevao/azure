<#
.SYNOPSIS
    The script Enable-ADEMultipleVMs will enable the Azure Disk encryption on all VMs inside a specifc resourceGroup
.PARAMETER subscriptionId
    Subscription where the VM and Shared Image Gallery is.
.PARAMETER tenantId
    Tenant Id.
.PARAMETER resourceGroupToEncrypt
    Resource group that you'll encrypt all the VM's
.PARAMETER azureKeyVaultName
    Azure Key Vault that contains the KEK, you'll insert the URI of the KEK
.PARAMETER customKey
    Key that you'll use to encrypt the VM's
.PARAMETER useCustomKey
    This value specifies that you'll use a KEK
.NOTES
    Author: Estevão F.
    Version: 1
    Date: 09/04/2022
#>

#Azure Login parameters
$tenantId = ""
$subscriptionId = ""

#Automation parameters
$resourceGroupToEncrypt = ""
$azureKeyVaultName = ""
$customKey = "" # Fill this with the KEK URI

#Do not make changes after here

$useCustomKey = "True"

Write-Host "Log-in on Azure tenant..."

#logging into Azure tenant
$null = az login --tenant $tenantId

Write-Host "Selecting Azure Subscription...."
#Selecting the specified subscription
$null = az account set --subscription $subscriptionId --verbose

#Getting Key Vault
$kvSettings = az keyvault show --name $azureKeyVaultName | ConvertFrom-Json
Write-Host "Checking if the choose Key Vault can be used...." -ForegroundColor Green

if ($kvSettings.properties.enabledForDiskEncryption -eq "True"){

    Write-Host "Key Vault can be used for ADE..." -ForegroundColor Green

}else{
    Write-Error -Message "The Vault $azureKeyVaultName cannot be used for Azure Disk Encryption..."
    sleep 3
    Write-Host "Enabling the Azure Disk Encryption in the Vault...."
        az keyvault update --enabled-for-disk-encryption true --name $azureKeyVaultName --resource-group $kvSettings.resourceGroup
}

#Working on VMs
#Getting VM's inside the RG
$vmList = az vm list -g $resourceGroupToEncrypt | ConvertFrom-Json

foreach ($vm in $vmlist){
    $vmDetails = az vm show -n $vm.name -g $resourceGroupToEncrypt | ConvertFrom-Json
    $vmEncryptStatus = az vm encryption show --name $vm.name --resource-group $resourceGroupToEncrypt | ConvertFrom-json

    if ($null -eq  $vmEncryptStatus){
        Write-Host "Disk Encryption Not Enabled..." -ForegroundColor Red
        Write-Host "Starting Disk Encryption Process!!" -ForegroundColor Cyan
        # After validade the Encryption Status, the script will check the variable "UseCustomKey"
        # If this variable is True, it will use the a Key Encryption Key to encrypt the disks.
        # If not, will encrypt the VM withou the KEK
        
        if ($useCustomKey -eq "True"){
            Write-Host "You decide to specify the KEK:" -ForegroundColor Green
            Start-Sleep -Seconds 2
            Write-Host "Checking VM State..."
            
            $status = az vm get-instance-view --name $vm.name --resource-group $resourceGroupToEncrypt --query instanceView.statuses[1] -o json | ConvertFrom-Json
            Start-Sleep -Seconds 5
            if ($status.displayStatus -eq "VM running"){
                Write-Host "VM is Running" -ForegroundColor Green
            }else {
                Write-Host "The VM" $vm.name "is not running!!" -ForegroundColor Red
                Write-Host "Starting VM..." -ForegroundColor Green
                Start-Sleep -Seconds 3
                    az vm start -n $vm.name -g $resourceGroupName
                Start-Sleep -Seconds 15
            }
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
    

}

