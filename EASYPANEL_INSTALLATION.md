# Tutorial de Instalação do Academy LMS com EasyPanel

## Introdução

Este tutorial detalha o processo de instalação do **Academy LMS** em um ambiente gerenciado pelo **EasyPanel**. O guia pressupõe que você já possui uma instância do EasyPanel em execução e o código-fonte do Academy LMS está disponível em seu repositório GitHub.

O processo padrão de instalação do Academy LMS utiliza um assistente web que não é ideal para ambientes de implantação automatizados como o EasyPanel. Portanto, este guia demonstrará como adaptar a aplicação para uma configuração baseada em variáveis de ambiente, permitindo um deploy mais robusto e seguro.

---

## Pré-requisitos

Antes de começar, certifique-se de que você possui:

1.  **Acesso a uma instância do EasyPanel** devidamente instalada e funcional.
2.  **O código-fonte do Academy LMS** enviado para um repositório GitHub ao qual seu EasyPanel tenha acesso. Para este tutorial, usaremos `BrusCode/webeduca`.
3.  **As credenciais do seu banco de dados**, que serão criadas no Passo 1.

---

## Passo 1: Criar o Banco de Dados MySQL

O Academy LMS requer um banco de dados MySQL para operar. A primeira etapa é criar este banco de dados através do EasyPanel.

1.  No painel do EasyPanel, navegue até a seção de **Bancos de Dados**.
2.  Clique em **"Adicionar Novo"** ou **"Criar Banco de Dados"**.
3.  Selecione **MySQL** como o tipo de banco de dados.
4.  Defina um nome para o serviço (ex: `academy-db`), um nome para o banco de dados (ex: `academy_lms`), um usuário e uma senha segura.
5.  **Anote as seguintes credenciais**, pois elas serão usadas mais tarde:
    *   **Host do Serviço**: Geralmente, é o nome do serviço que você definiu (ex: `academy-db`).
    *   **Nome do Banco de Dados**: `academy_lms`
    *   **Usuário**: O usuário que você criou.
    *   **Senha**: A senha que você definiu.

---

## Passo 2: Modificar o Código para Usar Variáveis de Ambiente

Para evitar o instalador web e tornar a configuração segura, modificaremos o arquivo de configuração do banco de dados para que ele leia as credenciais a partir de variáveis de ambiente, em vez de estarem fixas no código.

1.  Clone o repositório `BrusCode/webeduca` em sua máquina local.
2.  Abra o arquivo `application/config/database.php`.
3.  Substitua o array `$db["default"]` pelo seguinte código. Este código utiliza a função `getenv()` para buscar as credenciais do ambiente do EasyPanel:

    ```php
    $db['default'] = array(
        'dsn'   => '',
        'hostname' => getenv('DB_HOST') ?: '127.0.0.1',
        'username' => getenv('DB_USER') ?: 'root',
        'password' => getenv('DB_PASS') ?: '',
        'database' => getenv('DB_NAME') ?: 'academy_lms',
        'dbdriver' => 'mysqli',
        'dbprefix' => '',
        'pconnect' => FALSE,
        'db_debug' => (ENVIRONMENT !== 'production'),
        'cache_on' => FALSE,
        'cachedir' => '',
        'char_set' => 'utf8',
        'dbcollat' => 'utf8_general_ci',
        'swap_pre' => '',
        'encrypt' => FALSE,
        'compress' => FALSE,
        'stricton' => FALSE,
        'failover' => array(),
        'save_queries' => TRUE
    );
    ```

4.  Salve o arquivo, faça o commit da alteração e envie para o seu repositório no GitHub.

    ```sh
    git add application/config/database.php
    git commit -m "refactor: usar variáveis de ambiente para conexão com DB"
    git push origin main
    ```

---

## Passo 3: Criar o Projeto no EasyPanel

Agora, vamos criar o projeto no EasyPanel que irá hospedar a aplicação.

1.  No EasyPanel, vá para **"Projetos"** e clique em **"Criar Projeto"**.
2.  Selecione a opção para implantar a partir de um **repositório Git**.
3.  Escolha sua conta do GitHub e selecione o repositório `BrusCode/webeduca`.
4.  **Configuração do Build**:
    *   O EasyPanel deve detectar que é um projeto PHP. Se necessário, selecione um **template PHP/Nginx**.
    *   O **diretório raiz (root)** da aplicação é o diretório principal do repositório, onde o `index.php` está localizado.

5.  **Variáveis de Ambiente**:
    *   Navegue até a aba **"Variáveis"** ou **"Environment"** do seu novo projeto.
    *   Adicione as seguintes variáveis com os valores do banco de dados que você criou no Passo 1:

| Variável  | Valor                                     |
| :-------- | :---------------------------------------- |
| `DB_HOST` | O nome do serviço do seu DB (ex: `academy-db`) |
| `DB_NAME` | O nome do banco de dados (ex: `academy_lms`) |
| `DB_USER` | O nome do usuário do banco de dados         |
| `DB_PASS` | A senha do banco de dados                 |

---

## Passo 4: Importar o Banco de Dados Inicial

O Academy LMS vem com um arquivo SQL (`install.sql`) que cria a estrutura inicial do banco de dados. Precisamos importá-lo.

1.  Após o primeiro deploy (que pode falhar, pois o banco ainda está vazio), acesse o terminal/console do seu contêiner da aplicação através do EasyPanel.
2.  Execute o seguinte comando para importar o arquivo `install.sql` para o seu banco de dados. Substitua as credenciais pelos seus valores.

    ```sh
    mysql -h academy-db -u SEU_USUARIO -pSEU_BANCO < uploads/install.sql
    ```

    *   **Atenção**: Não há espaço entre `-p` e a senha.
    *   Pressione Enter e, quando solicitado, digite a senha do banco de dados.

3.  Após a importação bem-sucedida, **re-deploys** a aplicação no EasyPanel para que ela possa se conectar ao banco de dados agora populado.

---

## Passo 5: Configurar Volumes Persistentes

Para garantir que os arquivos enviados pelos usuários (como imagens de curso e avatares) não sejam perdidos durante os deploys, precisamos configurar volumes persistentes.

1.  Nas configurações do seu projeto no EasyPanel, encontre a seção **"Volumes"** ou **"Armazenamento"**.
2.  Mapeie os seguintes diretórios da aplicação para volumes persistentes:

    *   `/app/uploads` -> `academy_uploads_volume`
    *   `/app/backups` -> `academy_backups_volume`

    *O caminho `/app` pode variar dependendo da configuração do seu contêiner PHP no EasyPanel. Verifique o `WORKDIR` do seu Dockerfile ou a configuração do projeto.*

---

## Passo 6: Deploy e Configuração Final

1.  Com as variáveis de ambiente, o banco de dados importado e os volumes configurados, acione um novo **deploy** do seu projeto no EasyPanel.
2.  Acesse a URL pública fornecida pelo EasyPanel para sua aplicação.
3.  Você deverá ver a página inicial do Academy LMS.
4.  Como o instalador foi pulado, você precisa criar a conta de administrador. Navegue até a página de registro (geralmente em `https://sua-url/home/sign_up`) e crie o primeiro usuário. Este usuário normalmente se tornará o administrador principal.

Parabéns! Você concluiu a instalação do Academy LMS no EasyPanel.

---

## Solução de Problemas (Troubleshooting)

*   **Erro 500 (Internal Server Error)**: Verifique os logs da aplicação no EasyPanel. Causas comuns incluem credenciais de banco de dados incorretas ou falha na conexão com o banco.
*   **Página em Branco**: Pode indicar um erro de PHP. Verifique os logs de erro do PHP no contêiner.
*   **Permissões de Arquivo**: Se encontrar erros de permissão, certifique-se de que os volumes para `uploads/` e `backups/` estão montados corretamente e têm permissão de escrita para o usuário do servidor web (geralmente `www-data`).

