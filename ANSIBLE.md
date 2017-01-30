# Automação e provisionamento agil com Ansible

Hoje irei falar um pouco sobre minha experiencia com uma ferramenta muito util de automação, o _Ansible_.
Estou trabalhando em um projeto onde é desenvolvida uma aplicação que depende de uma série de dependencias e serviços para funcionar. Além de ter que automatizar todo o processo de instalação de bibliotecas, instalação/atualização de pacotes, serviços, deploy e etc, tambe tinha que contar com a possibilidade de futuramente ter que rodar essa mesma aplicação e suas dependencias em outros servidores, mantendo sempre tudo atualizado e replicado em _Real Time_ para todos os nós e por ultimo e não menos importante, precisava pensar em uma forma de validar de forma "idempotent" se nessas maquinas ja existiam essas depedencias, ou seja, o comando só poderia ser aplicado quando ele realmente necessitar ser aplicado. Explicando de uma forma mais precisa o significado do termo _idempotent_ para nosso cenario, pense que voce precisa para instalar um determinado pacote em uma maquina, porem nao sabemos se ja existe esse pacote instalado e voce precisa validar se o pacote existe no host remoto, caso não exista, a tarefa será executada e o pacote será instalado, caso exista, a tarefa não será executada. Depois de pesquisar um pouco e conversar com meus colegas de capitulo, conheci o Ansible que me ajudou bastante com essa questão. Neste artigo falarei um pouco de como é sua estrutura, como instalar o Ansible e como usei ele no meu projeto.

## O que é o Ansible?

O Ansible é uma ferramenta Opensource de automação e provisionamento agil desenvolvida inicialmente por Michael DeHaan e atualmente mantida pela comunidade e pela Red Hat. O Ansible é de fácil aprendizagem e utiliza SSH para se comunicar com os clientes(nodes) não necessitando de agent, sua única dependência é ter Python2 instalado no(s) node(s) que já é nativo na maioria das distribuições Linux.

Com Ansible é possível automatizar tarefas como:

+ Instalação e atualização de pacotes;
+ Configuração e deploy de aplicações;
+ Gerenciamento de usuários e muitas outras tarefas administrativas com ganho enorme de desempenho, velocidade e produtividade;

A documentação oficial fica em:
http://docs.ansible.com/ansible/intro_installation.html

### A estrutura do Ansible

+ **Inventory:** É um arquivo de inventario onde tera declarado quais os nós ou "hosts-alvos" que serão gerenciados pelo Ansible-Server;
+ **Modules:** Controlam os recursos (serviços, pacotes, arquivos, etc.) do(s) host(s) remoto(s);
+ **Tasks:** Tarefas que serão executadas no(s) host(s);
+ **Playbooks:** Conjunto de tarefas escritas em YAML(chave:valor) que serão executadas no(s) host(s);

### Caracteristicas do Ansible

+ Escrito em Python que é uma linguagem interpretada, de script, imperativa e orientada a objetos;
+ Não necessita de agents sejam instalados nos hosts remotos;
+ Utiliza SSH para se conectar aos hosts;
+ Para os Playbooks, utiliza a linguagem YAML que é facilmente entendida por seres humanos;
+ Utiliza linguagem Jinja2 para templates;
- Enorme quantidade de módulos e codigos no Github. Através do site https://galaxy.ansible.com/ ou do comando ansible-galaxy, é possível baixar e reutilizar playbooks escritos por outros usuários.


### Instalando o Ansible
**O que iremos precisar?**
Neste exemplo eu usei minha maquina e duas maquinas virtuais com SO Ubuntu16.04(Porque eu gosto, porque eu quero e porque sim) sendo a minha o Ansible-Server e as outras os nós gerenciados. A instalação é relativamente simples, você precisa instalá-lo somente em uma máquina que funcionará como um ponto central.

**Para a instalação do Ansible-Server voce precisará seguir os seguintes steps:**

**APT-Ubuntu**
![apt](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/apt.png)

**YUM**
![yum](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/yum.png)

**Debian**
![debian](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/debian.png)

**PKG**
![pkg](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/pkg.png)

**Homebrew**
![homebrew](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/homebrew.png)


### Gerenciando Servidores
**O invetário**
O arquivo de hosts de inventário do Ansible é usado para listar e agrupar seus servidores. Sua localização default é /etc/ansible/hosts.

Eu costumo copiar e mover o default para que eu possa fazer referência a ele mais tarde:
+ sudo mv /etc/ansible/hosts /etc/ansible/hosts.orig

Depois de mover o arquivo de inventário de exemplo, crie um novo arquivo /etc/ansible/hosts e defina os servidores a serem gerenciados.

Caso queira ter seu arquivo de hosts Ansible em outro local particular, você pode definir esta variável de ambiente:
+ export ANSIBLE_HOSTS=/root/ansible_hosts

Ou pode especificar o local de hosts Ansible ao executar comandos com a flag --inventory-file = (ou -i):
+ ansible all --inventory-file=/root/ansible_hosts -m ping

Aqui vamos definir os dois servidores sob o rótulo "webservers" e um com "local" para testes locais:

![inventory](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/inventory.png)


### Conectando nos Servidores
Para conectar ao seus servidores sem ter que digitar uma senha ou caso você ainda não tiver autenticação via chave ssh configurada para seus nós filhos, gere a chave no nó master:

![keygen](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/keygen.png)

Apos o termino das confirmações, teremos 2 arquivos:

+ ~/.ssh/id_rsa
+ ~/.ssh/id_rsa.pub

Em seguida, copie sua chave pública para os servidores com o comando **ssh-copy-id**:

+ $ ssh-copy-id -i ~/.ssh/id_rsa.pub <user>@<host>

![ssh-copy](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/ssh-copy.png)


> ref: [Post-Install Setup](https://valdhaus.co/writings/ansible-post-install/)

### Executando comandos
**Comandos Ad-Hoc**
Assim que tiver um inventário configurado, podemos começar a executar Tarefas nos os servidores definidos.

O Ansible assumirá que você tem acesso SSH disponível para seus servidores, normalmente baseado em SSH-Key. Como o Ansible usa SSH, o servidor em que ele está instalado precisa de acesso via SSH aos servidores do inventário.

![ping_ansible](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/ping_ansible.png)

A saída que temos do Ansible é JSON que nos diz se a Tarefa fez alguma alteração e o seu resultado.
Se precisamos definir o usuário e talvez algumas outras configurações para se conectar ao nosso servidor, podemos fazer uso das seguintes FLAGS

+ $ ansible all -m ping -k -u <user>

Onde:

+ **All** - Use todos os servidores definidos a partir do arquivo de inventário
+ **m ping** - Use o módulo "ping", que simplesmente executa o comando ping e retorna os resultados
+ **s** - Use "sudo" para executar os comandos
+ **k** - Solicitar uma senha em vez de usar a autenticação baseada em chave
+ **u <user>** - Log em servidores usando usuário testcloud

### Modules

Ansible usa "módulos" para realizar a maioria de suas tarefas. Os módulos podem fazer coisas como instalar software, copiar arquivos, usar modelos e etc.

+ ansible local -s -m apt -a 'name=nginx'

Nota: Perceba que eu usei o rotulo "local" para limitar a ação somente em minha maquina.

Acima, o comando **sudo apt-get install nginx** foi executado usando o módulo "shell". O sinalizador **-a** é usado para transmitir argumentos para o módulo. Eu uso **-s** para executar este comando usando sudo. Se usarmos um módulo mais apropriado, podemos executar comandos com uma garantia do resultado. Os módulos Ansible asseguram indempotência, ou seja, poderemos executar as mesmas tarefas sem afetar o resultado final.

+ ansible local -m apt -a 'name=nginx state=installed' --ask-sudo

Ele fara uso do módulo **apt** para instalar o Nginx (se não estiver instalado). O resultado da execução da Tarefa foi "changed": false. Isso mostra que não houve mudanças pois eu já havia instalado o Nginx nesta maquina. Posso executar este comando repetidamente sem me preocupar com ele afetando o resultado desejado.

### Algumas FLAGS:

+ **All** - Executar em todos os hosts definidos a partir do arquivo de inventário
+ **s** - Executar usando o sudo
+ **m apt** - Use o módulo apt
+ **a 'name=nginx state=instalado'** - Fornece os argumentos para o módulo dnf, incluindo o nome do pacote e o estado final desejado.
+ **--ask-sudo** - pede senha de sudo

Podemos executar todas as nossas tarefas necessárias (através de módulos) desta forma ad-hoc, mas vamos tornar isso mais gerenciável. Vamos mover essa tarefa para um Playbook, que pode executar e coordenar várias tarefas ao mesmo tempo.

### Playbook Básico

Os Playbooks podem executar várias Tarefas(TASKS) e fornecer algumas funcionalidades mais avançadas. Segue um exemplo de um playbook com instação do requisitos do Apache LAMP.

![LAMP](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/LAMP.png)

Perceba que neste playbook, a primeira tarefa declarada foi instalar o php5, apache2, mysql e etc etc...
Na segunda tarefa, ele executa o comando que habilita o module **rewrite** do Apache e por ultimo reinicia o serviço Apache. Rá!!

Para cada tarefa, você pode especificar o grupo-alvo de nós e o usuário remoto para executar a operação.
![groups1](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/groups1.png)

Se você precisar executar a tarefa com usuário diferentes, especifique da seguinte forma:
![groups2](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/groups2.png)

Executar com **sudo**:
![groups3](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/groups3.png)

As tarefas do playbook serão executadas em todos os nós declarados no grupo **webservers** dentro do arquivo de invetanrio.

Para executar o playbook execute o comando:
![webserver](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/webserver.png)

Dando continuidade ao exemplo anterior, vamos colocar os comandos ad-hoc que executamos para instalar o NGINX dentro de um playbook ordenados em Tasks:

Crie o arquivo nginx.yml com a configuração abaixo:

![PLAYBOOK](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/playbook.png)

Esta tarefa faz exatamente o mesmo que o nosso comando ad-hoc, no entanto eu escolhi especificar o meu grupo "local" de servidores em vez de "all" ou "webservers". Podemos executar o playbook com o comando ansible-playbook:

![PLAYBOOK2](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/playbook2.png)
Usei --ask-sudo dizendo ao Ansible para usar **sudo** pedindo senha e em seguida, informei o arquivo Playbook nginx.yml.
Eu costumo adicionar -vvv para visualizar com mais detalhes a execução das tarefas e seu resultado final.
Como vemos acima, ele executou as tarefas com sucesso, porem nada foi alterado pois eu já tenho o Nginx instalado.

A sintaxe do comando para execução dos playbooks é:

+ $ ansible-playbook -i inventario playbook

> ref: [Playbooks](http://docs.ansible.com/ansible/playbooks_intro.html).

## Conclusão
Como vimos, o Ansible é uma ótima solução de provisionamento de ambientes e me ajudou bastante de forma rapida e eficiente. Existe alguns contras, como a exigente sintaxe e indentação do seu playbook. No entanto sua lógica é bastante simples. Sua documentacao é bem completa e há muitas opcoes que poderão te ajudar a construir seus proprios modulos em seus playbooks de acordo com sua necessidade.
