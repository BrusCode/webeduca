#!/bin/bash

################################################################################
# Script de Instalação Automática do Academy LMS no Ubuntu 22.04/24.04
# Autor: Manus AI
# Data: 24 de Outubro de 2025
################################################################################

set -e  # Sair se houver erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    print_error "Este script deve ser executado como root (use sudo)"
    exit 1
fi

print_info "=== Instalação do Academy LMS no Ubuntu ==="
echo ""

# Solicitar informações do usuário
read -p "Digite o domínio do seu site (ex: ead.seusite.com.br): " DOMAIN
read -p "Digite a senha do root do MySQL: " -s MYSQL_ROOT_PASSWORD
echo ""
read -p "Digite a senha para o usuário 'academy_user' do banco de dados: " -s DB_PASSWORD
echo ""
read -p "Digite seu email para o certificado SSL: " SSL_EMAIL
echo ""

# Confirmação
print_warning "Configurações:"
echo "  Domínio: $DOMAIN"
echo "  Email SSL: $SSL_EMAIL"
echo "  Banco de dados: academy_lms"
echo "  Usuário DB: academy_user"
echo ""
read -p "Confirma as configurações acima? (s/n): " CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
    print_error "Instalação cancelada pelo usuário."
    exit 1
fi

print_info "Iniciando instalação..."
echo ""

# Detectar versão do Ubuntu e definir versão do PHP
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" == "24.04" ]]; then
    PHP_VERSION="8.3"
    print_info "Ubuntu 24.04 detectado. Usando PHP 8.3"
else
    PHP_VERSION="8.1"
    print_info "Ubuntu 22.04 detectado. Usando PHP 8.1"
fi

# 1. Atualizar sistema
print_info "Passo 1/10: Atualizando o sistema..."
apt update && apt upgrade -y

# 2. Instalar pacotes essenciais
print_info "Passo 2/10: Instalando pacotes essenciais..."
apt install -y git curl unzip wget software-properties-common

# 3. Instalar Apache
print_info "Passo 3/10: Instalando Apache..."
apt install -y apache2
a2enmod rewrite
systemctl restart apache2

# 4. Instalar MySQL
print_info "Passo 4/10: Instalando MySQL..."
apt install -y mysql-server

# Configurar senha do root do MySQL
print_info "Configurando MySQL..."
# No Ubuntu 24.04, o MySQL usa auth_socket por padrão para root
sudo mysql <<MYSQL_ROOT_SETUP
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
MYSQL_ROOT_SETUP

# 5. Instalar PHP e extensões
print_info "Passo 5/10: Instalando PHP $PHP_VERSION e extensões..."
if [[ "$PHP_VERSION" == "8.3" ]]; then
    # Ubuntu 24.04 - PHP 8.3 (padrão)
    apt install -y php php-cli php-mysql php-gd php-zip php-curl php-xml php-mbstring libapache2-mod-php
else
    # Ubuntu 22.04 - PHP 8.1
    apt install -y php8.1 php8.1-cli php8.1-mysql php8.1-gd php8.1-zip php8.1-curl php8.1-xml php8.1-mbstring libapache2-mod-php8.1
fi

# 6. Criar banco de dados
print_info "Passo 6/10: Criando banco de dados..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
CREATE DATABASE academy_lms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'academy_user'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON academy_lms.* TO 'academy_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# 7. Configurar PHP
print_info "Passo 7/10: Configurando PHP para produção..."
cat > /etc/php/$PHP_VERSION/apache2/conf.d/99-academy.ini <<EOF
; Configurações de Produção para Academy LMS
upload_max_filesize = 2048M
post_max_size = 2148M
max_execution_time = 1800
max_input_time = 1800
memory_limit = 512M

opcache.enable = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 20000
opcache.revalidate_freq = 60
opcache.validate_timestamps = 0
opcache.fast_shutdown = 1

display_errors = Off
log_errors = On
expose_php = Off

date.timezone = America/Sao_Paulo
EOF

# 8. Clonar repositório
print_info "Passo 8/10: Clonando repositório do Academy LMS..."
if [ -d "/var/www/academy_lms" ]; then
    print_warning "Diretório /var/www/academy_lms já existe. Removendo..."
    rm -rf /var/www/academy_lms
fi

git clone https://github.com/BrusCode/webeduca.git /var/www/academy_lms

# 9. Configurar banco de dados na aplicação
print_info "Passo 9/10: Configurando conexão com banco de dados..."
sed -i "s/'hostname' => getenv('DB_HOST') ?: 'localhost'/'hostname' => 'localhost'/g" /var/www/academy_lms/application/config/database.php
sed -i "s/'username' => getenv('DB_USER') ?: 'root'/'username' => 'academy_user'/g" /var/www/academy_lms/application/config/database.php
sed -i "s/'password' => getenv('DB_PASS') ?: ''/'password' => '$DB_PASSWORD'/g" /var/www/academy_lms/application/config/database.php
sed -i "s/'database' => getenv('DB_NAME') ?: 'academy_lms'/'database' => 'academy_lms'/g" /var/www/academy_lms/application/config/database.php

# Importar banco de dados
print_info "Importando estrutura do banco de dados..."
if [ -f "/var/www/academy_lms/uploads/install.sql" ]; then
    mysql -u academy_user -p"$DB_PASSWORD" academy_lms < /var/www/academy_lms/uploads/install.sql
else
    print_warning "Arquivo install.sql não encontrado. Você precisará importar manualmente."
fi

# Ajustar permissões
print_info "Ajustando permissões..."

# Criar pastas necessárias se não existirem
mkdir -p /var/www/academy_lms/uploads
mkdir -p /var/www/academy_lms/backups

chown -R www-data:www-data /var/www/academy_lms/
chmod -R 755 /var/www/academy_lms/
chmod -R 777 /var/www/academy_lms/uploads/
chmod -R 777 /var/www/academy_lms/backups/

# 10. Configurar Virtual Host
print_info "Passo 10/10: Configurando Virtual Host do Apache..."
cat > /etc/apache2/sites-available/${DOMAIN}.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName ${DOMAIN}
    DocumentRoot /var/www/academy_lms

    <Directory /var/www/academy_lms>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2ensite ${DOMAIN}.conf
a2dissite 000-default.conf
apache2ctl configtest
systemctl restart apache2

# 11. Instalar certificado SSL
print_info "Instalando certificado SSL com Let's Encrypt..."
apt install -y certbot python3-certbot-apache
certbot --apache -d ${DOMAIN} --non-interactive --agree-tos -m ${SSL_EMAIL} --redirect

print_info ""
print_info "=== Instalação Concluída com Sucesso! ==="
print_info ""
print_info "Acesse: https://${DOMAIN}"
print_info ""
print_info "Credenciais do Banco de Dados:"
print_info "  Host: localhost"
print_info "  Database: academy_lms"
print_info "  User: academy_user"
print_info "  Password: [a senha que você definiu]"
print_info ""
print_info "Próximos passos:"
print_info "1. Acesse o site e crie sua conta de administrador"
print_info "2. Configure as informações da instituição"
print_info "3. Personalize o tema e logotipo"
print_info ""
print_warning "IMPORTANTE: Guarde suas credenciais em local seguro!"

