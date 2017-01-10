#[Instalando o Ansible]

**Ansible** usa Python felizmente ele já é nativo em versões modernas do OSX.

+ sudo easy_install pip

+ sudo pip install ansible --quiet

Caso voce queira atualizar o Ansible mais tarde, faça:
+ sudo pip install ansible --upgrade

##[Gerenciando Servidores]

A Ansible possui um arquivo de inventário padrão usado para definir quais servidores ele vai gerenciar. O arquivo de hosts de inventário do Ansible é usado para listar e agrupar seus servidores. Sua localização default é /etc/ansible/hosts.

Eu costumo copiar e mover o default para que eu possa fazer referência a ele mais tarde:
+ sudo mv /etc/ansible/hosts /etc/ansible/hosts.orig

Depois de mover o arquivo de inventário de exemplo, crie um novo arquivo /etc/ansible/hosts e defina os servidores a serem gerenciados.

Se você quiser ter seu arquivo de hosts Ansible em outro local, então você pode definir esta variável de ambiente:
+ export ANSIBLE_HOSTS=/root/ansible_hosts

Ou pode especificar o local de hosts Ansible ao executar comandos com a flag --inventory-file = (ou -i):
+ ansible all --inventory-file=/root/ansible_hosts -m ping

Aqui vamos definir os dois servidores sob o rótulo "testcloud" e um com "local" para testes locais:

"This is the Host File."
[testcloud]
10.9.1.22
10.200.4.20

[local]
127.0.0.1


##[Conectando nos Servidores]
Para conectar ao seus servidores sem ter que digitar uma senha ou caso você ainda não tiver autenticação via chave ssh configurada para seus nós filhos, gere a chave no nó master:

+ ssh-keygen -t rsa -C "ansible_server"

Em seguida, copie sua chave pública para os servidores com ssh-copy-id:

+ ssh-copy-id testcloud@10.9.1.22
+ ssh-copy-id testcloud@10.200.4.20

> ref: [Post-Install Setup](https://valdhaus.co/writings/ansible-post-install/)


##[Executando comandos]

Assim que tiver um inventário configurado, podemos começar a executar Tarefas nos os servidores definidos.

O Ansible assumirá que você tem acesso SSH disponível para seus servidores, normalmente baseado em SSH-Key. Como o Ansible usa SSH, o servidor em que ele está instalado precisa de acesso via SSH aos servidores do inventário.

+ [talmeida@localhost test_ansible]$ ansible all -m ping
10.200.4.20 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
10.9.1.22 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}


A saída que temos do Ansible é JSON que nos diz se a Tarefa fez quaisquer alterações e o seu resultado.
Se precisamos definir o usuário e talvez algumas outras configurações para se conectar ao nosso servidor, podemos fazer uso das seguintes FLAGS

+ [talmeida@localhost test_ansible]$ ansible all -m ping -k -u testcloud
10.200.4.20 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
10.9.1.22 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

Onde:

+ All - Use todos os servidores definidos a partir do arquivo de inventário
+ m ping - Use o módulo "ping", que simplesmente executa o comando ping e retorna os resultados
+ s - Use "sudo" para executar os comandos
+ k - Solicitar uma senha em vez de usar a autenticação baseada em chave
+ u testcloud - Log em servidores usando usuário testcloud

##[Modules]

Ansible usa "módulos" para realizar a maioria de suas tarefas. Os módulos podem fazer coisas como instalar software, copiar arquivos, usar modelos e etc.

+ ansible local -s -m dnf -a 'name=nginx'

Nota: Perceba que eu usei o rotulo "local" para limitar a ação somente em minha maquina.

Aqui, o comando sudo dnf install nginx será executado usando o módulo "shell". O sinalizador -a é usado para transmitir argumentos para o módulo. Eu uso -s para executar este comando usando sudo. Se usarmos um módulo mais apropriado, podemos executar comandos com uma garantia do resultado. Os módulos Ansible asseguram indempotência - podemos executar as mesmas tarefas sem afetar o resultado final.

+ ansible local -m dnf -a 'name=nginx state=installed' --ask-sudo

Ele fara uso do módulo dnf para instalar o Nginx (se não estiver instalado). O resultado da execução da Tarefa foi "changed": false. Isso mostra que não houve mudanças; Eu já tinha instalado o Nginx. Posso executar este comando repetidamente sem me preocupar com ele afetando o resultado desejado.

##Algumas FLAGS:

+ All - Executar em todos os hosts definidos a partir do arquivo de inventário
+ s - Executar usando o sudo
+ m dnf - Use o módulo dnf
+ a 'name=nginx state=instalado' - Fornece os argumentos para o módulo dnf, incluindo o nome do pacote e o estado final desejado.
+ --ask-sudo - pede senha de sudo

Podemos executar todas as nossas tarefas necessárias (através de módulos) desta forma ad-hoc, mas vamos tornar isso mais gerenciável. Vamos mover essa tarefa para um Playbook, que pode executar e coordenar várias tarefas.


##[Playbook básico]

Os Playbooks podem executar várias Tarefas(TASKS) e fornecer algumas funcionalidades mais avançadas. Vamos escrever a tarefa acima em um playbook.

Crie o arquivo nginx.yml com a configuração abaixo:

![PLAYBOOK](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/playbook.png)

Esta tarefa faz exatamente o mesmo que o nosso comando ad-hoc, no entanto eu escolhi especificar o meu grupo "local" de servidores em vez de "all" ou "testcloud". Podemos executar o playbook com o comando ansible-playbook:

![PLAYBOOK2](https://github.com/cs-tiago-almeida/cs-codes/blob/development/img/playbook2.png)
Use -s ou --ask-sudo para dizer ao Ansible para usar sudo e em seguida, informe o arquivo Playbook nginx.yml.
Eu costumo adicionar -vvv para visualizar com mais detalhes a xecução das tarefas e seu resultado final.
Comoo vemos acima, ele executou as tarefas com sucesso, porem nada foi alterado pois eu já tenho o Nginx instalado.

A sintaxe do comando para execução dos playbooks é:

ansible-playbook -i inventario playbook

> ref: [Playbooks](http://docs.ansible.com/ansible/playbooks_intro.html).
