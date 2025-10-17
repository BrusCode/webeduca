# Configurações Avançadas do Academy LMS no EasyPanel

## Introdução

Este documento complementa o tutorial básico de instalação, fornecendo configurações avançadas para otimizar a performance, segurança e escalabilidade do Academy LMS no EasyPanel.

---

## 1. Configuração com Dockerfile Personalizado

Para ter maior controle sobre o ambiente de execução, você pode usar um Dockerfile personalizado no EasyPanel.

### 1.1. Adicionar Dockerfile ao Repositório

Crie um arquivo chamado `Dockerfile` na raiz do seu repositório com o seguinte conteúdo:

```dockerfile
FROM php:8.1-apache

# Instalar extensões PHP necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli pdo pdo_mysql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar código da aplicação
COPY . /var/www/html/

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/uploads \
    && chmod -R 777 /var/www/html/backups

# Configurar Apache para permitir .htaccess
RUN echo '<Directory /var/www/html>' > /etc/apache2/conf-available/academy.conf \
    && echo '    Options Indexes FollowSymLinks' >> /etc/apache2/conf-available/academy.conf \
    && echo '    AllowOverride All' >> /etc/apache2/conf-available/academy.conf \
    && echo '    Require all granted' >> /etc/apache2/conf-available/academy.conf \
    && echo '</Directory>' >> /etc/apache2/conf-available/academy.conf \
    && a2enconf academy

EXPOSE 80

CMD ["apache2-foreground"]
```

### 1.2. Configurar EasyPanel para Usar o Dockerfile

1. No EasyPanel, vá para as configurações do seu projeto.
2. Na seção de **Build**, certifique-se de que o EasyPanel está configurado para usar o Dockerfile do repositório.
3. Faça o deploy novamente.

---

## 2. Configuração de PHP e Performance

### 2.1. Ajustar Limites de Upload

O Academy LMS lida com uploads de vídeos e documentos. É importante ajustar os limites do PHP.

Crie um arquivo `php.ini` customizado ou adicione as seguintes linhas ao seu Dockerfile:

```dockerfile
RUN echo "upload_max_filesize = 512M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_time = 600" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini
```

### 2.2. Habilitar OPcache

Para melhorar a performance, habilite o OPcache do PHP:

```dockerfile
RUN docker-php-ext-install opcache \
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/opcache.ini
```

---

## 3. Configuração de SSL/TLS

O EasyPanel geralmente gerencia certificados SSL automaticamente através do Traefik. Certifique-se de:

1. **Configurar um domínio personalizado** nas configurações do projeto.
2. **Habilitar HTTPS** nas configurações de domínio.
3. O EasyPanel irá provisionar automaticamente um certificado Let's Encrypt.

### 3.1. Forçar HTTPS

Para garantir que todo o tráfego use HTTPS, adicione as seguintes regras ao arquivo `.htaccess` na raiz do projeto:

```apache
# Forçar HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

---

## 4. Backup Automatizado

### 4.1. Backup do Banco de Dados

Configure um job de backup periódico no EasyPanel:

1. Crie um script de backup `backup.sh`:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/www/html/backups"
DB_NAME="academy_lms"
DB_USER="academy_user"
DB_PASS="academy_pass"
DB_HOST="academy-db"

mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql
gzip $BACKUP_DIR/db_backup_$DATE.sql

# Manter apenas os últimos 7 backups
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +7 -delete
```

2. Configure um **cron job** no EasyPanel para executar este script diariamente.

### 4.2. Backup de Arquivos

Os volumes persistentes do EasyPanel já protegem seus arquivos, mas considere sincronizar periodicamente o diretório `uploads/` para um serviço de armazenamento externo como AWS S3 ou Backblaze B2.

---

## 5. Monitoramento e Logs

### 5.1. Acessar Logs da Aplicação

No EasyPanel, você pode visualizar os logs do contêiner em tempo real:

1. Vá para o seu projeto.
2. Clique em **"Logs"** ou **"Console"**.
3. Monitore erros e avisos do PHP e Apache.

### 5.2. Configurar Alertas

Configure alertas no EasyPanel para ser notificado quando:

*   O contêiner reiniciar inesperadamente.
*   O uso de CPU ou memória ultrapassar um limite.
*   O banco de dados ficar inacessível.

---

## 6. Escalabilidade

### 6.1. Escalonamento Horizontal

Para lidar com maior tráfego, você pode escalar horizontalmente adicionando mais instâncias do contêiner da aplicação:

1. No EasyPanel, vá para as configurações do projeto.
2. Aumente o número de **réplicas** ou **instâncias**.
3. O EasyPanel irá balancear a carga automaticamente através do Traefik.

**Importante**: Certifique-se de que o diretório `uploads/` está em um volume compartilhado ou use um serviço de armazenamento de objetos (S3) para que todas as instâncias tenham acesso aos mesmos arquivos.

### 6.2. Usar CDN para Assets

Configure um CDN (como Cloudflare ou AWS CloudFront) para servir os assets estáticos (CSS, JS, imagens) e reduzir a carga no servidor da aplicação.

---

## 7. Segurança

### 7.1. Variáveis de Ambiente Sensíveis

Nunca commite senhas ou chaves de API no repositório. Use sempre as variáveis de ambiente do EasyPanel para armazenar informações sensíveis.

### 7.2. Atualizar Dependências

Mantenha o PHP, Apache e as extensões PHP atualizadas. Reconstrua a imagem Docker periodicamente para incorporar patches de segurança.

### 7.3. Restringir Acesso ao Painel Administrativo

Configure middlewares do Traefik no EasyPanel para restringir o acesso ao painel administrativo por IP, se necessário.

---

## 8. Migração de Dados

Se você já possui uma instalação do Academy LMS e deseja migrar para o EasyPanel:

1. **Exportar o banco de dados** da instalação antiga:
   ```bash
   mysqldump -u usuario -p nome_do_banco > academy_backup.sql
   ```

2. **Copiar o diretório `uploads/`** da instalação antiga.

3. **Importar o banco de dados** no novo ambiente:
   ```bash
   mysql -h academy-db -u academy_user -p academy_lms < academy_backup.sql
   ```

4. **Copiar os arquivos de `uploads/`** para o volume persistente do EasyPanel.

---

## Conclusão

Com estas configurações avançadas, você terá um ambiente robusto, seguro e escalável para o Academy LMS no EasyPanel. Lembre-se de testar cada mudança em um ambiente de staging antes de aplicar em produção.

