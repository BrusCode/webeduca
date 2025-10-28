> Este tutorial foi criado por **Manus AI** em 24 de Outubro de 2025.

# Guia Completo: Instalação do Academy LMS em Ubuntu 22.04/24.04

## 🎯 Visão Geral

Este guia detalha o processo completo para instalar o **Academy LMS** em um servidor Ubuntu 22.04 ou 24.04 do zero, configurando um ambiente de produção otimizado com o stack **LAMP (Linux, Apache, MySQL, PHP)**.

Este método oferece **controle total** sobre o ambiente, permitindo otimizações de performance e segurança de baixo nível, mas exige maior conhecimento em administração de sistemas.

### 📋 Stack de Tecnologia

| Componente | Versão/Configuração |
|------------|-----------------------|
| **OS** | Ubuntu 22.04 / 24.04 LTS |
| **Servidor Web** | Apache 2.4 |
| **Banco de Dados** | MySQL 8.0 |
| **PHP** | 8.1 + OPcache |

---

## 🚀 Passo 1: Preparação do Servidor

### 1.1. Conexão e Atualização

Conecte-se ao seu servidor via SSH e atualize os pacotes do sistema.

```bash
# Conectar ao servidor (substitua com seu IP)
ssh root@SEU_IP_DO_SERVIDOR

# Atualizar lista de pacotes e o sistema
sudo apt update && sudo apt upgrade -y
```

### 1.2. Instalação de Pacotes Essenciais

Instale pacotes básicos que serão úteis durante o processo.

```bash
sudo apt install -y git curl unzip wget software-properties-common
```

---

## 📦 Passo 2: Instalação do Stack LAMP

### 2.1. Instalação do Apache

Instale o servidor web Apache.

```bash
sudo apt install -y apache2
```

Após a instalação, habilite o `mod_rewrite` para que as URLs amigáveis do CodeIgniter funcionem.

```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### 2.2. Instalação do MySQL

Instale o servidor de banco de dados MySQL.

```bash
sudo apt install -y mysql-server
```

Após a instalação, execute o script de segurança para definir a senha do usuário `root` e remover configurações inseguras.

```bash
sudo mysql_secure_installation
```

> **IMPORTANTE**: Durante o `mysql_secure_installation`:
> - **VALIDATE PASSWORD component?** -> Responda **No (N)** para evitar senhas excessivamente complexas.
> - **Defina uma senha forte** para o usuário `root` do MySQL e anote-a.
> - Responda **Yes (Y)** para todas as outras perguntas.

### 2.3. Instalação do PHP 8.1

Ubuntu 22.04/24.04 já vem com PHP 8.1+, mas vamos garantir que todas as extensões necessárias para o Academy LMS sejam instaladas.

```bash
sudo apt install -y php8.1 php8.1-cli php8.1-mysql php8.1-gd php8.1-zip php8.1-curl php8.1-xml
```

---

## ⚙️ Passo 3: Configuração do Ambiente

### 3.1. Criação do Banco de Dados

Faça login no MySQL com o usuário `root` e crie o banco de dados e um usuário dedicado para a aplicação.

```bash
# Fazer login no MySQL
sudo mysql -u root -p
```

> Digite a senha do `root` do MySQL que você definiu anteriormente.

Agora, execute os seguintes comandos SQL:

```sql
-- Crie o banco de dados
CREATE DATABASE academy_lms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Crie um usuário dedicado (substitua 'sua_senha_forte' por uma senha segura)
CREATE USER 'academy_user'@'localhost' IDENTIFIED BY 'sua_senha_forte';

-- Dê todas as permissões ao usuário no banco de dados
GRANT ALL PRIVILEGES ON academy_lms.* TO 'academy_user'@'localhost';

-- Aplique as alterações
FLUSH PRIVILEGES;

-- Saia do MySQL
EXIT;
```

**Anote as credenciais do banco de dados**: `academy_lms`, `academy_user`, `sua_senha_forte`.

### 3.2. Configuração do PHP para Produção

Para suportar uploads de vídeos grandes e otimizar a performance, vamos criar um arquivo de configuração customizado para o PHP.

```bash
# Navegue até o diretório de configuração do PHP para Apache
cd /etc/php/8.1/apache2/conf.d/

# Crie um arquivo de configuração para o Academy LMS
sudo nano 99-academy.ini
```

Cole o seguinte conteúdo no arquivo `99-academy.ini`:

```ini
; Configurações de Produção para Academy LMS

; Uploads e Execução (suporte para 2GB)
upload_max_filesize = 2048M
post_max_size = 2148M
max_execution_time = 1800
max_input_time = 1800
memory_limit = 512M

; Performance (OPcache)
opcache.enable = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 20000
opcache.revalidate_freq = 60
opcache.validate_timestamps = 0 ; Desabilitado para máxima performance
opcache.fast_shutdown = 1

; Segurança
display_errors = Off
log_errors = On
expose_php = Off

; Timezone
date.timezone = America/Sao_Paulo
```

> Pressione `Ctrl+X`, depois `Y` e `Enter` para salvar e fechar o `nano`.

### 3.3. Configuração do Virtual Host do Apache

Crie um arquivo de configuração de Virtual Host para o seu domínio.

```bash
# Crie o arquivo de configuração (substitua com seu domínio)
sudo nano /etc/apache2/sites-available/ead.qualityautomacao.com.br.conf
```

Cole o seguinte conteúdo, **substituindo `ead.qualityautomacao.com.br` pelo seu domínio real**:

```apache
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName ead.qualityautomacao.com.br
    DocumentRoot /var/www/academy_lms

    <Directory /var/www/academy_lms>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Agora, habilite o novo site e desabilite o site padrão do Apache.

```bash
sudo a2ensite ead.qualityautomacao.com.br.conf
sudo a2dissite 000-default.conf

# Teste a configuração do Apache
sudo apache2ctl configtest

# Reinicie o Apache para aplicar as alterações
sudo systemctl restart apache2
```

---

## 📥 Passo 4: Instalação da Aplicação

### 4.1. Clonar o Repositório

Clone o código-fonte do Academy LMS para o diretório configurado no Apache.

```bash
# Crie o diretório e clone o repositório
sudo git clone https://github.com/BrusCode/webeduca.git /var/www/academy_lms
```

### 4.2. Configurar Conexão com Banco de Dados

Edite o arquivo `database.php` para usar as credenciais que você criou.

```bash
sudo nano /var/www/academy_lms/application/config/database.php
```

Localize o array `$db['default']` e altere para usar as credenciais do seu banco de dados. **Como já modificamos este arquivo no repositório para usar `getenv()`, vamos reverter para a configuração manual para este tutorial**.

Substitua o bloco `$db['default']` por este, preenchendo com suas credenciais:

```php
$db['default'] = array(
    'dsn'   => '',
    'hostname' => 'localhost',
    'username' => 'academy_user',
    'password' => 'sua_senha_forte', // Substitua aqui
    'database' => 'academy_lms',
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

### 4.3. Importar o Banco de Dados Inicial

O repositório contém o arquivo SQL inicial. Importe-o para o banco de dados.

```bash
mysql -u academy_user -p academy_lms < /var/www/academy_lms/uploads/install.sql
```

> Digite a senha `sua_senha_forte` quando solicitado.

### 4.4. Ajustar Permissões

O Apache precisa de permissão para escrever nos diretórios `uploads` e `backups`.

```bash
sudo chown -R www-data:www-data /var/www/academy_lms/
sudo chmod -R 755 /var/www/academy_lms/
sudo chmod -R 777 /var/www/academy_lms/uploads/
sudo chmod -R 777 /var/www/academy_lms/backups/
```

---

## 🔒 Passo 5: Instalação do Certificado SSL (HTTPS)

Para um ambiente de produção, é essencial usar HTTPS. Vamos usar o Let's Encrypt.

### 5.1. Instalar o Certbot

```bash
sudo apt install -y certbot python3-certbot-apache
```

### 5.2. Gerar o Certificado

Execute o Certbot para obter e instalar o certificado SSL para o seu domínio.

```bash
# Substitua pelo seu domínio real
sudo certbot --apache -d ead.qualityautomacao.com.br
```

> Siga as instruções na tela. O Certbot irá configurar o HTTPS e o redirecionamento automático para você.

Após a conclusão, o Apache será reiniciado e seu site estará acessível via `https://ead.qualityautomacao.com.br`.

---

## 🎉 Passo 6: Acesso e Configuração Final

### 6.1. Acessar a Aplicação

Abra seu navegador e acesse `https://ead.qualityautomacao.com.br`.

Você deverá ver a página inicial do Academy LMS.

### 6.2. Criar Conta de Administrador

1. Clique em **"Sign Up"** ou **"Cadastre-se"**.
2. Crie a sua conta. O primeiro usuário registrado se torna o super-administrador.

### 6.3. Configurar o Sistema

Faça login e navegue até **"Settings"** ou **"Configurações"** para:
- Configurar o nome do site.
- Personalizar o tema e logotipo.
- Configurar métodos de pagamento.
- Configurar SMTP para envio de emails.

---

## 🛠️ Troubleshooting

### Erro 500 (Internal Server Error)
- **Causa**: Problema de permissão no `.htaccess` ou erro de PHP.
- **Solução**: Verifique os logs do Apache (`/var/log/apache2/error.log`) para detalhes.

### Página em Branco
- **Causa**: Erro fatal de PHP.
- **Solução**: Habilite `display_errors = On` temporariamente no `99-academy.ini` e reinicie o Apache para ver o erro na tela.

### Erro de Conexão com Banco de Dados
- **Causa**: Credenciais incorretas no `database.php`.
- **Solução**: Verifique `hostname`, `username`, `password` e `database`.

### Upload de Arquivos Falha
- **Causa**: Limites do PHP muito baixos ou permissões incorretas.
- **Solução**: Verifique o arquivo `99-academy.ini` e as permissões do diretório `uploads/`.

---

## 🚀 Instalação Concluída!

Seu Academy LMS está instalado e pronto para produção em um servidor Ubuntu otimizado. Lembre-se de configurar rotinas de backup para o diretório `/var/www/academy_lms` e para o banco de dados `academy_lms`.

