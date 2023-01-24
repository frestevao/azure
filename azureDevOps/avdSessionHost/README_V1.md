# Azure Virtual Desktop Deployment Automation


<img src="solutionDiagram.png" alt="project Diagram">


> Diagrama 
#
 ## Detalhes do Diagrama
---

Abaixo podemos observar os detalhes do apresentados no diagrama, levando em consideração a númeração informada no diagrama.

> 1. Azure DevOps Organization


Dentro da organização do Azure DevOps será necessário a criação dos itens abaixo:

- Criação de um novo projeto.
  - Projeto deverá ser de uso exclusivo dessa automação.
- Criação de uma service connection.
  - Service connection deverá ter o privilégio de owner na assinatura que receberá os novos session hosts.
    - Item 4 do diagrama.
- Repositório de código.
  - O repositório será responsável por armazenar:
    - arm template:
      - template.deploy.json: Contém sequência lógica responsável pelo deploy dos nós de avd.
      - template.parameters.json: Contém parâmetros necessário para realizar o deployment. (tags, vnet, vmName, etc)
      - pipeline.deploy.yml: Contém sequência lógica para execução das automações no Azure DevOps.


>2. Azure DevOps Self Host Agent

Dentro desse projeto é necessário que os jobs sejam executados através de um self-host agent que tenha comunicação com a rede onde o controlador de domínio o o private end point do key vault se encontram.

- As máquinas do AVD são do tipo Domain Join e a automação faz uma consulta em determinado step para que as contas de computadores existentes sejam deletadas.
- Por medidas de segurança o acesso ao keyVault é realizado apenas via VNET.
- Para um controle de custos, a máquina de self-host agent será ligada apenas 2hrs antes da execução do job e desligada após a conclusão do mesmo.

> 3. Azure Key Vault

O keyVault é utilizado para armazenar as senhas das credenciais de localUserAccount, domainJoin, deleteADDSComputerAccount & o token que é gerado para registrar os session hosts no pool de AVD.

- localUserAccount: Conta local que é criada no deployment dos session hosts.
- domainJoinUser: Conta utilizada para ingressar os session hosts no domínio.
- deleteADDSComputerAccount: Usuário de serviço que possui delegated control na OU onde as contas de computador são armazenadas.

>4. Azure AD Enterprise Application

Este é o app criado pela service connection do projeto no Azure DevOps.

- Essa service connect deve ter o privilégio de OWNER na assinatura.

>5. Azure Compute Gallery

O Azure compute gallery é responsável por conter as imagens do ambiente.

> 6. Session Hosts

Servidores que os usuários acessam através da experiência de remote app.

>7. Controlador de domínio

Para utilização do AVD é necessário que os servidores sejam inseridos em um domínio do ADDS.

* A automação realiza o delete das contas de computadores das máquinas que foram deletadas.