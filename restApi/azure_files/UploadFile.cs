// Obtenha uma cadeia de conexão para nossa conta de armazenamento do Azure. Você pode
// obtenha sua cadeia de conexão do Portal do Azure (clique
// Chaves de acesso em Configurações na folha da conta do Portal Storage)
// ou usando a CLI do Azure com:
//
// conta de armazenamento az show-connection-string --name <account_name> --resource-group <resource_group>
//
// E você pode fornecer a string de conexão para seu aplicativo
// usando uma variável de ambiente.

string connectionString = "<Your ConectionString>";

// Nome do compartilhamento, diretório e arquivo que criaremos
string shareName = "myshare2";
string dirName = "myDirectory";
string fileName = "myFile";

// Caminho para o arquivo local para upload ** Caso a aplicação rode local
string localFilePath = @"Your Path";

// Obtenha uma referência para um compartilhamento e crie-o
ShareClient share = new ShareClient(connectionString, shareName);
share.CreateIfNotExists();

// Obter uma referência para um diretório e criá-lo
ShareDirectoryClient directory = share.GetDirectoryClient(dirName);
directory.CreateIfNotExists();

// Obter uma referência para um arquivo e carregá-lo
ShareFileClient file = directory.GetFileClient(localFilePath);
using (FileStream stream = File.OpenRead(fileName))
{
    Console.WriteLine(file.Uri.AbsolutePath);
    Console.WriteLine(file.Uri.Authority);
    Console.WriteLine(file.Uri);

    file.Create(stream.Length);
    file.UploadRange(
        new Azure.HttpRange(0, stream.Length),
        stream);
}

