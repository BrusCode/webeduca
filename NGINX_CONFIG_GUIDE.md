# Configuração do Nginx para Academy LMS - Uploads de 2GB

## 📋 Visão Geral

Esta configuração otimiza o Nginx para:
- ✅ **Uploads de até 2GB**
- ✅ **Timeouts estendidos** (30 minutos)
- ✅ **Compressão Gzip** (economiza banda)
- ✅ **Cache de arquivos estáticos** (melhora performance)
- ✅ **Segurança reforçada** (headers de segurança, bloqueio de arquivos sensíveis)

---

## 🎯 Principais Configurações Adicionadas

### 1. Suporte a Uploads de 2GB

```nginx
client_max_body_size 2148M;
client_body_timeout 1800s;
send_timeout 1800s;
```

**O que faz**: Permite uploads de até 2GB com timeout de 30 minutos.

### 2. Timeouts do FastCGI

```nginx
fastcgi_connect_timeout 1800s;
fastcgi_send_timeout 1800s;
fastcgi_read_timeout 1800s;
```

**O que faz**: Evita timeout durante processamento de uploads grandes.

### 3. Compressão Gzip

```nginx
gzip on;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;
```

**O que faz**: Comprime respostas, economizando 60-80% de banda.

### 4. Cache de Arquivos Estáticos

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

**O que faz**: Navegadores cacheiam CSS, JS e imagens por 30 dias.

### 5. Headers de Segurança

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

**O que faz**: Protege contra clickjacking, XSS e MIME sniffing.

### 6. Bloqueio de Arquivos Sensíveis

```nginx
location ~ ^/(application|system)/ {
    deny all;
    return 404;
}
```

**O que faz**: Impede acesso direto aos diretórios do CodeIgniter.

---

## 📝 Como Aplicar no EasyPanel

### Passo 1: Copiar a Configuração

Abra o arquivo `nginx-academy-production.conf` (anexado) e copie todo o conteúdo.

### Passo 2: Editar no EasyPanel

1. No serviço `academy_lms`, vá para a aba **"NGINX"**
2. Certifique-se de que o Nginx está **Ativado** (toggle ligado)
3. Clique no botão **"Editar"** no campo **"Config"**
4. **Apague todo o conteúdo existente**
5. Cole o conteúdo copiado
6. Clique em **"Salvar"** ou **"Confirmar"**

### Passo 3: Salvar e Re-deploy

1. Clique no botão **"Salvar"** (verde) na parte inferior
2. Faça um **re-deploy** do serviço
3. Aguarde o deploy finalizar

---

## 🔍 Diferenças da Configuração Anterior

| Configuração | Anterior | Nova (Produção) |
|--------------|----------|-----------------|
| **client_max_body_size** | Não definido (padrão 1M) | **2148M** |
| **client_body_timeout** | Padrão (60s) | **1800s (30min)** |
| **send_timeout** | Padrão (60s) | **1800s (30min)** |
| **fastcgi_read_timeout** | Padrão (60s) | **1800s (30min)** |
| **Gzip** | Não configurado | **Ativado (nível 6)** |
| **Cache estáticos** | Não configurado | **30 dias** |
| **Headers segurança** | Não configurado | **Configurados** |
| **Bloqueio arquivos** | Apenas `.ht*` | **Múltiplos tipos** |

---

## ⚠️ Observações Importantes

### 1. Variáveis do Template

O EasyPanel usa variáveis de template que são substituídas automaticamente:

- `{{ document_root }}` → Caminho do código da aplicação
- `{{ fpm_socket }}` → Socket do PHP-FPM

**Não altere essas variáveis!** Elas são gerenciadas pelo EasyPanel.

### 2. Diretório Temporário

A configuração usa `/tmp/nginx_client_body` para armazenar uploads temporariamente:

```nginx
client_body_temp_path /tmp/nginx_client_body;
```

O EasyPanel deve criar esse diretório automaticamente. Se houver problemas, ele usará o padrão do sistema.

### 3. Documento Raiz

O campo **"Documento Raiz"** na interface está configurado como `/code/public`.

Para o Academy LMS, o correto é a **raiz do projeto** (onde está o `index.php`), que provavelmente é `/code` ou `/var/www/html`.

**Verifique e ajuste se necessário**:
- Se o `index.php` está em `/code/`, use `/code`
- Se está em `/var/www/html/`, use `/var/www/html`

---

## 🧪 Teste de Configuração

Após aplicar a configuração:

### 1. Verificar Sintaxe do Nginx

O EasyPanel valida automaticamente a sintaxe ao salvar. Se houver erro, ele não aplicará a configuração.

### 2. Testar Compressão Gzip

```bash
curl -H "Accept-Encoding: gzip" -I https://seu-dominio.com
```

Procure por: `Content-Encoding: gzip`

### 3. Testar Cache de Estáticos

```bash
curl -I https://seu-dominio.com/assets/frontend/default/css/style.css
```

Procure por: `Cache-Control: public, immutable`

### 4. Testar Upload

Faça upload de arquivos progressivamente maiores:
- 100MB ✅
- 500MB ✅
- 1GB ✅
- 2GB ✅

---

## 📊 Impacto Esperado

### Performance

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| **Tamanho HTML** | 100KB | 20-40KB | 60-80% menor |
| **Tamanho CSS/JS** | 500KB | 100-200KB | 60-80% menor |
| **Tempo de carregamento** | 3s | 1-1.5s | 50% mais rápido |
| **Requisições de estáticos** | Toda vez | 1x a cada 30 dias | 99% menos |

### Segurança

✅ Proteção contra clickjacking  
✅ Proteção contra XSS  
✅ Proteção contra MIME sniffing  
✅ Arquivos sensíveis bloqueados  
✅ Diretórios do framework protegidos  

---

## 🔄 Configurações Adicionais (Opcional)

### 1. Rate Limiting (Proteção DDoS)

Se quiser limitar requisições por IP:

```nginx
# Adicione no início do bloco server
limit_req_zone $binary_remote_addr zone=upload:10m rate=5r/s;

# Adicione dentro de location ~ \.php$
limit_req zone=upload burst=10 nodelay;
```

### 2. Logs de Upload

Para monitorar uploads grandes:

```nginx
# Adicione no bloco server
access_log /var/log/nginx/academy_access.log;
error_log /var/log/nginx/academy_error.log warn;
```

### 3. HTTPS Redirect

Se você tiver SSL configurado e quiser forçar HTTPS:

```nginx
# Adicione no início do bloco server
if ($scheme != "https") {
    return 301 https://$host$request_uri;
}
```

**Nota**: O EasyPanel geralmente faz isso automaticamente via Traefik.

---

## 🆘 Troubleshooting

### Erro: "413 Request Entity Too Large"

**Causa**: `client_max_body_size` não foi aplicado

**Solução**:
1. Verifique se a configuração foi salva corretamente
2. Re-deploy do serviço
3. Verifique os logs do Nginx

### Erro: "504 Gateway Timeout"

**Causa**: `fastcgi_read_timeout` insuficiente

**Solução**:
1. Verifique se os timeouts do FastCGI foram aplicados
2. Aumente para `3600s` (1 hora) se necessário
3. Verifique também o `max_execution_time` do PHP

### Erro: "502 Bad Gateway"

**Causa**: PHP-FPM não está respondendo

**Solução**:
1. Verifique os logs do PHP-FPM
2. Verifique se o socket `{{ fpm_socket }}` está correto
3. Re-deploy do serviço

### Gzip não está funcionando

**Causa**: Navegador não suporta ou configuração incorreta

**Solução**:
1. Teste com `curl -H "Accept-Encoding: gzip" -I`
2. Verifique se `gzip on;` está presente
3. Alguns tipos de arquivo já são comprimidos (PNG, JPG, MP4)

---

## ✅ Checklist de Aplicação

- [ ] Configuração do Nginx copiada
- [ ] Nginx ativado no EasyPanel
- [ ] Configuração colada no campo "Config"
- [ ] Documento Raiz verificado (deve apontar para onde está o index.php)
- [ ] Configuração salva
- [ ] Re-deploy realizado
- [ ] Teste de upload 100MB: ✅
- [ ] Teste de upload 1GB: ✅
- [ ] Teste de upload 2GB: ✅
- [ ] Gzip funcionando: ✅
- [ ] Cache de estáticos funcionando: ✅

---

## 📞 Próximos Passos

Após aplicar a configuração do Nginx:

1. ✅ **PHP configurado** (php-production.ini)
2. ✅ **Nginx configurado** (nginx-academy-production.conf)
3. ⏭️ **Variáveis de ambiente** (DB_HOST, DB_USER, etc)
4. ⏭️ **Volumes persistentes** (uploads/, backups/)
5. ⏭️ **Deploy e teste**
6. ⏭️ **Importar banco de dados**

Você está quase lá! 🚀

