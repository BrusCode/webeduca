# Configuração de Produção para Academy LMS - Vídeos até 2GB

## 🎯 Visão Geral

Esta configuração foi otimizada para:
- ✅ **Vídeos de até 2GB** por upload
- ✅ **Máxima performance** em produção
- ✅ **Segurança reforçada**
- ✅ **OPcache otimizado** para não revalidar arquivos

---

## 📊 Comparação: Desenvolvimento vs Produção

| Configuração | Desenvolvimento | Produção (2GB) |
|--------------|-----------------|----------------|
| **Upload Max** | 512M | **2048M (2GB)** |
| **Post Max** | 512M | **2148M** |
| **Execution Time** | 600s (10min) | **1800s (30min)** |
| **Memory Limit** | 256M | **512M** |
| **OPcache Memory** | 128M | **256M** |
| **OPcache Revalidate** | 2s | **60s** |
| **OPcache Validate Timestamps** | On | **Off (máxima performance)** |
| **Display Errors** | Off | **Off** |
| **Session Cookie Secure** | Off | **On (HTTPS only)** |
| **Zlib Compression** | Off | **On (economiza banda)** |

---

## 🔧 Configuração no EasyPanel

### 1. Configurações Visuais (Interface)

| Campo | Valor para Produção |
|-------|---------------------|
| **Versão do PHP** | `8.3` |
| **Tamanho Máximo de Upload** | `2048M` |
| **Tempo Máximo de Execução** | `1800` |
| **Opcache** | ✅ **Ativado** |
| **Ioncube** | ❌ Desativado |
| **Sqlsrv** | ❌ Desativado |

### 2. PHP INI Customizado

Clique em **"Editar"** no campo **"PHP INI"** e cole o conteúdo do arquivo `php-production.ini` fornecido.

---

## ⚠️ Configurações Críticas para Vídeos de 2GB

### 1. Nginx/Apache Timeout

O EasyPanel usa **Nginx** como proxy reverso. É importante também configurar timeouts no Nginx:

**Se você tiver acesso às configurações do Nginx**, adicione:

```nginx
client_max_body_size 2048M;
client_body_timeout 1800s;
proxy_read_timeout 1800s;
proxy_connect_timeout 1800s;
proxy_send_timeout 1800s;
```

**No EasyPanel**, isso pode estar na aba **"NGINX"** ou pode ser gerenciado automaticamente.

### 2. Variáveis de Ambiente Adicionais

Adicione estas variáveis de ambiente no EasyPanel para garantir compatibilidade:

```env
PHP_UPLOAD_MAX_FILESIZE=2048M
PHP_POST_MAX_SIZE=2148M
PHP_MAX_EXECUTION_TIME=1800
PHP_MEMORY_LIMIT=512M
```

---

## 🚀 Otimizações de Produção Aplicadas

### 1. OPcache - Máxima Performance

```ini
opcache.validate_timestamps = 0
```

**O que isso faz**: PHP **nunca** verifica se os arquivos mudaram. O código em cache é usado sempre.

**Importante**: Após fazer deploy de código novo, você **DEVE reiniciar o PHP-FPM** ou fazer um **re-deploy completo** no EasyPanel.

**Benefício**: 40-60% mais rápido que com validação ativada.

### 2. Compressão Zlib Ativada

```ini
zlib.output_compression = On
zlib.output_compression_level = 6
```

**O que isso faz**: Comprime automaticamente a saída HTML/JSON/CSS antes de enviar ao navegador.

**Benefício**: Reduz banda em 60-80%, páginas carregam mais rápido.

### 3. Segurança Reforçada

```ini
session.cookie_secure = 1
session.cookie_samesite = Strict
disable_functions = exec,passthru,shell_exec,system,proc_open,popen
```

**O que isso faz**:
- Cookies só funcionam em HTTPS
- Proteção contra CSRF
- Funções perigosas desabilitadas

### 4. Realpath Cache Aumentado

```ini
realpath_cache_size = 8192K
realpath_cache_ttl = 7200
```

**O que isso faz**: Cacheia caminhos de arquivos por 2 horas, reduzindo I/O de disco.

**Benefício**: 10-20% mais rápido em aplicações com muitos includes.

---

## 📝 Passo a Passo Completo

### Passo 1: Backup das Configurações Atuais

Antes de aplicar, tire um print das configurações atuais do PHP no EasyPanel.

### Passo 2: Aplicar Configurações Visuais

1. Vá para a aba **"PHP"** do serviço `academy_lms`
2. Configure:
   - **Tamanho Máximo de Upload**: `2048M`
   - **Tempo Máximo de Execução**: `1800`
   - **Opcache**: ✅ Ativado

### Passo 3: Aplicar PHP INI

1. Clique em **"Editar"** no campo **"PHP INI"**
2. **Apague todo o conteúdo existente**
3. Cole o conteúdo do arquivo `php-production.ini`
4. Clique em **"Salvar"** ou **"Confirmar"**

### Passo 4: Verificar Configurações do Nginx (se disponível)

Se houver uma aba **"NGINX"**, verifique se `client_max_body_size` está configurado para pelo menos `2048M`.

### Passo 5: Salvar e Re-deploy

1. Clique no botão **"Salvar"** (verde)
2. Faça um **re-deploy completo** do serviço
3. Aguarde o deploy finalizar (pode levar 2-3 minutos)

### Passo 6: Verificação

Após o deploy:

1. Acesse a aplicação
2. Tente fazer upload de um arquivo de teste (ex: 100MB)
3. Verifique se o upload funciona sem timeout
4. Gradualmente teste com arquivos maiores

---

## 🧪 Teste de Upload de Vídeo Grande

Para testar se a configuração está correta:

### 1. Criar Arquivo de Teste

```bash
# Criar arquivo de 500MB para teste
dd if=/dev/zero of=test_500mb.mp4 bs=1M count=500
```

### 2. Fazer Upload

Tente fazer upload através da interface do Academy LMS.

### 3. Monitorar

Acompanhe os logs do container no EasyPanel durante o upload.

### 4. Validar

Se o upload de 500MB funcionar, teste com 1GB, depois 1.5GB, até 2GB.

---

## ⚠️ Considerações Importantes

### 1. Timeout do Navegador

Navegadores modernos têm timeout próprio (geralmente 5 minutos). Para uploads muito grandes (>1GB), considere:

- Usar **upload chunked** (dividir arquivo em partes)
- Implementar **resumable uploads** (retomar upload interrompido)
- Usar bibliotecas JavaScript como **Resumable.js** ou **Uppy**

### 2. Armazenamento

Vídeos de 2GB consomem muito espaço. Certifique-se de:

- Volume persistente `academy_uploads` tem espaço suficiente
- Monitorar uso de disco regularmente
- Considerar integração com **S3** ou **CDN** para vídeos

### 3. Processamento de Vídeo

Academy LMS pode processar/converter vídeos. Para vídeos de 2GB:

- Certifique-se de que há memória suficiente no servidor
- Considere usar **workers assíncronos** para processamento
- Monitore uso de CPU durante uploads

### 4. Backup

Com vídeos grandes:

- Backups automáticos podem demorar muito
- Considere backup incremental
- Use compressão nos backups

---

## 🔄 Após Deploy de Código Novo

Como `opcache.validate_timestamps = 0`, após fazer deploy de código novo:

### Opção 1: Re-deploy Completo (Recomendado)

No EasyPanel, faça um **re-deploy** completo. Isso reinicia o container e limpa o OPcache.

### Opção 2: Reiniciar PHP-FPM (se tiver acesso ao terminal)

```bash
# Dentro do container
kill -USR2 1
```

### Opção 3: Limpar OPcache via Script

Crie um arquivo `clear-cache.php` (protegido por senha):

```php
<?php
if (isset($_GET['secret']) && $_GET['secret'] === 'SUA_SENHA_SECRETA') {
    opcache_reset();
    echo "OPcache cleared!";
} else {
    http_response_code(403);
    echo "Forbidden";
}
```

Acesse: `https://seu-dominio.com/clear-cache.php?secret=SUA_SENHA_SECRETA`

---

## 📊 Monitoramento

### Métricas para Acompanhar

1. **Uso de Memória**: Deve ficar abaixo de 80%
2. **Uso de CPU**: Picos durante uploads são normais
3. **Uso de Disco**: Crescimento constante com vídeos
4. **OPcache Hit Rate**: Deve estar acima de 95%

### Como Verificar OPcache

Crie um arquivo `opcache-status.php`:

```php
<?php
if (function_exists('opcache_get_status')) {
    $status = opcache_get_status();
    echo "Hit Rate: " . round($status['opcache_statistics']['opcache_hit_rate'], 2) . "%\n";
    echo "Memory Used: " . round($status['memory_usage']['used_memory'] / 1024 / 1024, 2) . " MB\n";
    echo "Memory Free: " . round($status['memory_usage']['free_memory'] / 1024 / 1024, 2) . " MB\n";
} else {
    echo "OPcache not enabled";
}
```

---

## ✅ Checklist Final

- [ ] Tamanho Máximo de Upload: **2048M**
- [ ] Tempo Máximo de Execução: **1800s**
- [ ] Memory Limit: **512M**
- [ ] OPcache: **Ativado**
- [ ] PHP INI de produção: **Aplicado**
- [ ] Re-deploy: **Realizado**
- [ ] Teste de upload: **100MB funcionando**
- [ ] Teste de upload: **500MB funcionando**
- [ ] Teste de upload: **1GB funcionando**
- [ ] Teste de upload: **2GB funcionando**
- [ ] Monitoramento: **Configurado**
- [ ] Backup: **Planejado**

---

## 🆘 Troubleshooting

### Upload falha em 1GB mas funciona em 500MB

**Causa**: Timeout do Nginx ou limite de proxy

**Solução**: Verifique configurações do Nginx no EasyPanel

### Erro "413 Request Entity Too Large"

**Causa**: Nginx `client_max_body_size` muito baixo

**Solução**: Aumentar para `2048M` nas configurações do Nginx

### Erro "504 Gateway Timeout"

**Causa**: Timeout do proxy reverso

**Solução**: Aumentar `proxy_read_timeout` no Nginx para `1800s`

### Memória insuficiente durante upload

**Causa**: `memory_limit` muito baixo ou muitos uploads simultâneos

**Solução**: Aumentar `memory_limit` para `1024M` ou limitar uploads simultâneos

