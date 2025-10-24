# Tutorial de Instalação do Academy LMS em VPS Ubuntu

## Introdução

Este guia detalha o processo completo para instalar o **Academy LMS** em uma **VPS (Virtual Private Server)** dedicada, utilizando o sistema operacional **Ubuntu 22.04 ou 24.04**. A abordagem descrita é a de uma instalação manual, configurando um ambiente de servidor web **LAMP (Linux, Apache, MySQL, PHP)** do zero. Este método oferece controle total sobre o ambiente e é ideal para quem busca otimizar a performance e a segurança.

---

## Pré-requisitos

- **VPS com Ubuntu 22.04 ou 24.04**: Uma instância de servidor virtual com acesso root ou um usuário com privilégios `sudo`.
- **Acesso SSH**: Um cliente SSH para se conectar ao servidor.
- **Domínio**: Um nome de domínio registrado que aponte para o endereço IP da sua VPS.

---

## Passo 1: Conexão e Atualização do Servidor

Primeiro, conecte-se à sua VPS via SSH e atualize os pacotes do sistema para garantir que todas as dependências estejam na versão mais recente.

```bash
# Conecte-se ao seu servidor (substitua com seu usuário e IP)
ssh seu_usuario@seu_ip_da_vps

# Atualize o índice de pacotes e os pacotes instalados
sudo apt update && sudo apt upgrade -y
```

---

## Passo 2: Instalação do Servidor Web Apache

O Academy LMS funciona bem com o servidor web Apache. Instale-o e configure o firewall para permitir tráfego web.

```bash
# Instale o Apache2
sudo apt install -y apache2

# Permita o tráfego HTTP e HTTPS através do firewall
sudo ufw allow 'Apache Full'

# Verifique o status do Apache
sudo systemctl status apache2
```

---

## Passo 3: Instalação do Banco de Dados MySQL

O sistema requer um banco de dados MySQL para armazenar todas as informações.

```bash
# Instale o servidor MySQL
sudo apt install -y mysql-server

# Execute o script de segurança para configurar a senha do root e outras opções
sudo mysql_secure_installation
```

Após a instalação, crie o banco de dados e um usuário dedicado para a aplicação, o que é uma prática de segurança recomendada.

```bash
# Acesse o prompt do MySQL
sudo mysql

# Crie o banco de dados (substitua 'academy_lms' se desejar)
CREATE DATABASE academy_lms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Crie um usuário e uma senha (substitua 'sua_senha_forte')
CREATE USER 'academy_user'@'localhost' IDENTIFIED BY 'sua_senha_forte';

# Conceda todos os privilégios ao usuário no banco de dados criado
GRANT ALL PRIVILEGES ON academy_lms.* TO 'academy_user'@'localhost';

# Aplique as alterações e saia
FLUSH PRIVILEGES;
EXIT;
```

---

## Passo 4: Instalação do PHP e Extensões Necessárias

O Academy LMS é construído em PHP. Instale o PHP e todas as extensões que o sistema requer para funcionar corretamente.

```bash
# Instale o PHP, o módulo do Apache e as extensões necessárias
sudo apt install -y php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-zip

# Verifique a versão do PHP instalada
php -v
```

---

## Passo 5: Download e Preparação dos Arquivos da Aplicação

Agora, baixe o código-fonte do Academy LMS do repositório GitHub e coloque-o no diretório correto do Apache.

```bash
# Crie o diretório para a sua aplicação
sudo mkdir -p /var/www/academy

# Clone o repositório para o diretório criado
sudo git clone https://github.com/BrusCode/webeduca.git /var/www/academy

# Mude a propriedade dos arquivos para o usuário do Apache (www-data)
sudo chown -R www-data:www-data /var/www/academy

# Defina as permissões corretas para os diretórios de upload e backup
sudo chmod -R 775 /var/www/academy/uploads
sudo chmod -R 775 /var/www/academy/backups
```

---

## Passo 6: Configuração do Apache Virtual Host

Crie um arquivo de Virtual Host para que o Apache saiba como servir o seu domínio.

```bash
# Crie um novo arquivo de configuração para o seu site
sudo nano /etc/apache2/sites-available/academy.conf
```

Cole o seguinte conteúdo no arquivo, substituindo `seudominio.com` pelo seu domínio real:

```apache
<VirtualHost *:80>
    ServerAdmin admin@seudominio.com
    ServerName seudominio.com
    ServerAlias www.seudominio.com
    DocumentRoot /var/www/academy

    <Directory /var/www/academy>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Agora, habilite o novo site e o módulo `rewrite` do Apache, que é essencial para o CodeIgniter.

```bash
# Habilite o novo site
sudo a2ensite academy.conf

# Habilite o módulo de reescrita de URL
sudo a2enmod rewrite

# Desabilite o site padrão do Apache
sudo a2dissite 000-default.conf

# Teste a configuração do Apache
sudo apache2ctl configtest

# Reinicie o Apache para aplicar as alterações
sudo systemctl restart apache2
```

---

## Passo 7: Configuração da Aplicação e Importação do Banco de Dados

Com os arquivos no lugar, configure a conexão com o banco de dados e importe a estrutura inicial.

```bash
# Navegue até o diretório da aplicação
cd /var/www/academy

# Edite o arquivo de configuração do banco de dados
sudo nano application/config/database.php
```

Localize o array `$db['default']` e atualize com as credenciais do banco de dados que você criou no Passo 3. O arquivo já está preparado para ler variáveis de ambiente, mas para uma VPS dedicada, você pode inserir os valores diretamente para simplicidade, ou definir as variáveis no ambiente do servidor.

**Método 1: Inserir Credenciais Diretamente (Mais Simples)**

```php
'hostname' => 'localhost',
'username' => 'academy_user',
'password' => 'sua_senha_forte',
'database' => 'academy_lms',
```

Após salvar o arquivo, importe o banco de dados inicial.

```bash
# Importe o arquivo install.sql para o banco de dados
sudo mysql -u academy_user -p academy_lms < uploads/install.sql
```

Digite a senha do usuário `academy_user` quando solicitado.

---

## Passo 8: Instalação do Certificado SSL (Let's Encrypt)

Para garantir a segurança do seu site, instale um certificado SSL gratuito da Let's Encrypt usando o Certbot.

```bash
# Instale o Certbot e o plugin para Apache
sudo apt install -y certbot python3-certbot-apache

# Execute o Certbot para obter e instalar o certificado
sudo certbot --apache -d seudominio.com -d www.seudominio.com
```

Siga as instruções na tela. O Certbot irá configurar o SSL e redirecionar o tráfego HTTP para HTTPS automaticamente.

---

## Passo 9: Finalização

Abra seu navegador e acesse `https://seudominio.com`. Você deverá ver a página inicial do Academy LMS. Como a instalação foi manual, o primeiro usuário que você registrar se tornará o administrador do sistema. Vá para a página de registro, crie sua conta e comece a configurar sua plataforma de ensino.

Parabéns! Você instalou e configurou com sucesso o Academy LMS em sua VPS dedicada.

---

## Solução de Problemas (Troubleshooting)

- **Erro 500 (Internal Server Error)**: Verifique os logs de erro do Apache em `/var/log/apache2/error.log`. Geralmente, são erros de permissão ou problemas no `.htaccess`.
- **Página em Branco**: Pode indicar um erro de PHP. Verifique os logs do Apache e certifique-se de que todas as extensões PHP foram instaladas.
- **Erro de Conexão com o Banco de Dados**: Verifique se as credenciais no arquivo `application/config/database.php` estão corretas e se o usuário MySQL tem os privilégios necessários.

