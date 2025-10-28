#!/bin/bash

################################################################################
# Script de Instalação do Academy LMS - Versão Web Installer
# Versão: 3.0 (Com Instalador Web)
# Autor: Manus AI
# Data: 28 de Outubro de 2025
# 
# Este script prepara o ambiente e deixa o INSTALADOR WEB fazer:
# - Criação do banco de dados
# - Importação das tabelas
# - Criação do usuário administrador
# 
# Diferenças da versão anterior:
# ✅ NÃO cria banco de dados
# ✅ NÃO importa SQL
# ✅ NÃO cria usuário do banco
# ✅ Deixa o instalador web fazer tudo
################################################################################

set -e  # Sair se houver erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_step() {
    echo -e "${BLUE}[PASSO $1]${NC} $2"
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    print_error "Este script deve ser executado como root (use sudo)"
    exit 1
fi

print_info "=== Instalação do Academy LMS com Instalador Web ==="
echo ""

# Solicitar informações do usuário
read -p "Digite o domínio do seu site (ex: ead.seusite.com.br): " DOMAIN
read -p "Digite a senha do root do MySQL: " -s MYSQL_ROOT_PASSWORD
echo ""
read -p "Digite seu email para o certificado SSL: " SSL_EMAIL
echo ""

# Confirmação
print_warning "Configurações:"
echo "  Domínio: $DOMAIN"
echo "  Email SSL: $SSL_EMAIL"
echo ""
print_warning "IMPORTANTE: O banco de dados será criado pelo INSTALADOR WEB"
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
print_step "1/9" "Atualizando o sistema..."
apt update && apt upgrade -y

# 2. Instalar pacotes essenciais
print_step "2/9" "Instalando pacotes essenciais..."
apt install -y git curl unzip wget software-properties-common lsb-release

# 3. Instalar Apache
print_step "3/9" "Instalando Apache..."
apt install -y apache2
a2enmod rewrite
a2enmod headers
a2enmod ssl
systemctl restart apache2

# 4. Instalar MySQL
print_step "4/9" "Instalando MySQL..."
apt install -y mysql-server

# Configurar senha do root do MySQL
print_info "Configurando MySQL..."
sudo mysql <<MYSQL_ROOT_SETUP
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
MYSQL_ROOT_SETUP

print_warning "NOTA: O banco de dados 'academy_lms' será criado pelo instalador web"

# 5. Instalar PHP e extensões
print_step "5/9" "Instalando PHP $PHP_VERSION e extensões..."
if [[ "$PHP_VERSION" == "8.3" ]]; then
    # Ubuntu 24.04 - PHP 8.3 (padrão)
    apt install -y php php-cli php-mysql php-gd php-zip php-curl php-xml php-mbstring libapache2-mod-php
else
    # Ubuntu 22.04 - PHP 8.1
    apt install -y php8.1 php8.1-cli php8.1-mysql php8.1-gd php8.1-zip php8.1-curl php8.1-xml php8.1-mbstring libapache2-mod-php8.1
fi

# 6. Configurar PHP
print_step "6/9" "Configurando PHP para produção..."
cat > /etc/php/$PHP_VERSION/apache2/conf.d/99-academy.ini <<EOF
; Configurações de Produção para Academy LMS
upload_max_filesize = 2048M
post_max_size = 2148M
max_execution_time = 3600
max_input_time = 3600
memory_limit = 1024M

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

# 7. Clonar repositório
print_step "7/9" "Clonando repositório do Academy LMS..."
if [ -d "/var/www/academy_lms" ]; then
    print_warning "Diretório /var/www/academy_lms já existe. Removendo..."
    rm -rf /var/www/academy_lms
fi

git clone https://github.com/BrusCode/webeduca.git /var/www/academy_lms

# Baixar e instalar config.php
print_info "Baixando arquivo config.php..."
wget -q https://raw.githubusercontent.com/BrusCode/webeduca/main/config.php -O /tmp/config.php

# Substituir base_url no config.php
sed -i "s|https://ead.qualityautomacao.com.br/|https://$DOMAIN/|g" /tmp/config.php

# Copiar config.php para o local correto
cp /tmp/config.php /var/www/academy_lms/application/config/config.php

# Criar pastas necessárias
print_info "Criando pastas necessárias..."
mkdir -p /var/www/academy_lms/uploads
mkdir -p /var/www/academy_lms/backups
mkdir -p /var/www/academy_lms/application/logs
mkdir -p /var/www/academy_lms/application/cache

# Ajustar permissões
print_info "Ajustando permissões..."
chown -R www-data:www-data /var/www/academy_lms/
chmod -R 755 /var/www/academy_lms/
chmod -R 777 /var/www/academy_lms/uploads/
chmod -R 777 /var/www/academy_lms/backups/
chmod -R 777 /var/www/academy_lms/application/logs/
chmod -R 777 /var/www/academy_lms/application/cache/

# 8. Configurar Virtual Host
print_step "8/9" "Configurando Virtual Host do Apache..."
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
a2dissite 000-default.conf 2>/dev/null || true
apache2ctl configtest
systemctl restart apache2

# 9. Instalar certificado SSL
print_step "9/9" "Instalando certificado SSL com Let's Encrypt..."
apt install -y certbot python3-certbot-apache
certbot --apache -d ${DOMAIN} --non-interactive --agree-tos -m ${SSL_EMAIL} --redirect || print_warning "Erro ao instalar SSL. Você pode tentar manualmente depois."

# Reiniciar Apache final
systemctl restart apache2

print_info ""
print_info "=== Instalação Concluída com Sucesso! ==="
print_info ""
print_info "🌐 Acesse o INSTALADOR WEB: https://${DOMAIN}/install/step0"
print_info ""
print_info "📋 O instalador web irá solicitar:"
print_info "  1. Credenciais do MySQL root"
print_info "     - Host: localhost"
print_info "     - User: root"
print_info "     - Password: [a senha que você definiu]"
print_info ""
print_info "  2. Nome do banco de dados a ser criado"
print_info "     - Sugestão: academy_lms"
print_info ""
print_info "  3. Dados do administrador do sistema"
print_info "     - Nome, email e senha"
print_info ""
print_warning "IMPORTANTE:"
print_warning "- O instalador web criará o banco de dados automaticamente"
print_warning "- O instalador web importará todas as tabelas"
print_warning "- O instalador web criará seu usuário administrador"
print_warning "- Guarde suas credenciais em local seguro!"
print_info ""
print_info "Documentação completa: https://github.com/BrusCode/webeduca"

