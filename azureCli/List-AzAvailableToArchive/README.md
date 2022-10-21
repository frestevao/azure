# List-AzAvailableToArchive


## __WHAT IS THIS?__
#

This scripts allows you to list the RPO's that you can move to the Archive tier on Azure Recovery Services vaults.
After the script execution, it will generate a CSV file with the RPO's that you can move to the Archive tier as the VM disk information to calculate the cost.

Version Note: This version only works for Azure VM Workload.

 [More on Microsoft Docs](https://docs.microsoft.com/en-us/azure/backup/archive-tier-support)

## __REQUIREMENTS__
#

* Most recent version of Azure CLI.
    - ref: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

* Only the workloads below are elegible to use this tier.

    - ref: https://docs.microsoft.com/en-us/azure/backup/archive-tier-support#supported-workloads
        - SQL DataBases.
        - SAP HANA.
        - Azure VMs

```powershell
#Execution example
    ./List-AzAvailableToArchive.ps1 -tenantId <tenantId> `
        -subscriptionId <subscriptionId> `
        -resourceGroupName <vaultResourceGroupName> `
        -backupVaultName <BackupVaultName> `
        -backupWorkloadType <AzureIaasVM> `
        -backupType <VM>
```

# Contribution Guidelines

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

Additional tips:

- Alphabetize your entry.
- Search previous suggestions before making a new one, as yours may be a duplicate.
- Suggested READMEs should be beautiful or stand out in some way.
- Make an individual pull request for each suggestion.
- New categories, or improvements to the existing categorization are welcome.
- Keep descriptions short and simple, but descriptive.
- Start the description with a capital and end with a full stop/period.
- Check your spelling and grammar.
- Make sure your text editor is set to remove trailing whitespace.
- Use the #readme anchor for GitHub READMEs to link them directly


Thank you for your suggestions!

---
## Contact

<p align="left" style="background:">
<a href="https://techf.cloud" target="_blank">
  <img align="center" src="https://img.shields.io/badge/-Techf.Cloud-05122A?style=flat&logo=.net" alt="codepen"/>
</a>
<a href="https://twitter.com/estevofr" target="_blank">
  <img align="center" src="https://img.shields.io/badge/-Estevão França-05122A?style=flat&logo=twitter" alt="twitter"/>  
</a>
<a href="https://www.linkedin.com/in/estevao-fr/" target="_blank">
  <img align="center" src="https://img.shields.io/badge/-Estevão França-05122A?style=flat&logo=linkedin" alt="linkedin"/>
</a>
</p>
