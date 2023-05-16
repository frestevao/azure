# File Share Azure

# Integration - Services

## Integration
---

Azure Files provides hosted cloud file shares that you can access (mount) by using industry-standard file system protocols such as SMB and NFS. When you mount a file share on your computer by using SMB or NFS, your operating system redirects API requests for the local file system. 

The redirection includes local API requests that you make by using .NET System.IO interfaces or Python open, read, or write methods. This means that users of these applications don't need to do anything special or even know that their data is on a remote file share instead of local storage.

This integration can be done by using Azure Functions.

- Connection: The connection is realized via connect string. The connection values are provided and manage on the required Azure File Share. It's required to define the data traffic as sensible. Also, it's recommended to use the App Server or Function options to store the sensitive information, or, use an Azure Key Vault.

- Request - To build an URI an realize the file upload, it's required to structure the request object. The object should receive the filename, file extension and, the file it self sent via bash/stream (file) or base64.

- Response - The expected return is 201, that is responsible to inform that the file was created. In case the file already exists, the response is 200. It's possible to create aditional policies to control the files upload.

-	Current version does not check for file changes.


## Postman 
---

To use via Postman it is necessary to create a new HTTP Request, inform the verb and the connection properties.

- What can be confusing is that the upload must happen in two steps. First you create the space for the file and then upload the file.

- File Creation.

Use postman to issue a call configured like this:

PUT https://[storagename].file.core.windows.net/[sharename][/subdir]/[filename][Your SAS Key from earlier]
x-ms-type:file
x-ms-content-length:<informe o tamanho do arquivo em bytes>
x-ms-version:2018-11-09

- Propriedades 

    - Myaccount: Storage Account Name.
    - myShare: File Share Name.
    - myDirectory: Optional, this is the path where you want to store the files.
    - myFile: File Name.


