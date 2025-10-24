# Configuração do PHP no EasyPanel para Academy LMS

## 📋 Visão Geral

O EasyPanel oferece uma interface visual para configurar o PHP, facilitando a otimização do Academy LMS sem necessidade de editar o Dockerfile.

---

## 🎯 Configurações Recomendadas

Com base na interface mostrada, configure os seguintes valores:

### 1. **Versão do PHP**
- **Valor**: `8.3` (já configurado)
- **Motivo**: Versão mais recente e estável, com melhor performance

### 2. **Tamanho Máximo de Upload**
- **Campo**: Tamanho Máximo de Upload
- **Valor**: `512M`
- **Motivo**: Academy LMS precisa fazer upload de vídeos de aulas e documentos grandes

### 3. **Tempo Máximo de Execução**
- **Campo**: Tempo Máximo de Execução
- **Valor**: `600` (segundos = 10 minutos)
- **Motivo**: Processamento de vídeos e importação de dados pode demorar

### 4. **OPcache**
- **Campo**: Opcache
- **Valor**: ✅ **Ativado** (toggle ligado)
- **Motivo**: Melhora significativamente a performance do PHP ao cachear bytecode compilado

### 5. **Ioncube**
- **Campo**: Ioncube
- **Valor**: ❌ **Desativado** (não necessário)
- **Motivo**: Academy LMS não usa código criptografado com Ioncube

### 6. **Sqlsrv**
- **Campo**: Sqlsrv
- **Valor**: ❌ **Desativado** (não necessário)
- **Motivo**: Academy LMS usa MySQL/MySQLi, não SQL Server

---

## 📝 Arquivo PHP.INI Completo

Clique no botão **"Editar"** no campo **"PHP INI"** e cole o seguinte conteúdo:

```ini
; ========================================
; PHP.INI Otimizado para Academy LMS
; ========================================

; CONFIGURAÇÕES DE UPLOAD
upload_max_filesize = 512M
post_max_size = 512M
max_file_uploads = 20

; CONFIGURAÇÕES DE EXECUÇÃO
max_execution_time = 600
max_input_time = 600
max_input_vars = 5000

; CONFIGURAÇÕES DE MEMÓRIA
memory_limit = 256M

; CONFIGURAÇÕES DE SESSÃO
session.gc_maxlifetime = 86400
session.gc_probability = 1
session.gc_divisor = 100

; CONFIGURAÇÕES DE ERRO E LOG
display_errors = Off
display_startup_errors = Off
log_errors = On
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; CONFIGURAÇÕES DE PERFORMANCE (OPCACHE)
opcache.enable = 1
opcache.enable_cli = 0
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
opcache.revalidate_freq = 2
opcache.validate_timestamps = 1
opcache.save_comments = 1

; CONFIGURAÇÕES DE SEGURANÇA
disable_functions = exec,passthru,shell_exec,system,proc_open,popen
expose_php = Off
session.cookie_httponly = 1
session.cookie_secure = 0
session.cookie_samesite = Lax

; CONFIGURAÇÕES DE TIMEZONE
date.timezone = America/Sao_Paulo

; CONFIGURAÇÕES DE OUTPUT
output_buffering = 4096
zlib.output_compression = Off

; CONFIGURAÇÕES DE REALPATH CACHE
realpath_cache_size = 4096K
realpath_cache_ttl = 600
```

---

## 🔧 Passo a Passo para Configurar

### 1. Acesse a Aba PHP

No seu serviço `academy_lms` no EasyPanel, clique na aba **"PHP"** (como mostrado na imagem).

### 2. Configure os Campos Visuais

- **Versão do PHP**: `8.3` ✅
- **Tamanho Máximo de Upload**: `512M` ✅
- **Tempo Máximo de Execução**: `600` ✅
- **Opcache**: ✅ Ativado
- **Ioncube**: ❌ Desativado
- **Sqlsrv**: ❌ Desativado

### 3. Edite o PHP INI

1. Clique no botão **"Editar"** no campo **"PHP INI"**
2. Cole o conteúdo do arquivo `php.ini` fornecido acima
3. Clique em **"Salvar"** ou **"Confirmar"**

### 4. Salve as Configurações

Clique no botão **"Salvar"** na parte inferior da página.

### 5. Re-deploy

Após salvar, faça um **re-deploy** do serviço para aplicar as alterações:

1. Vá para a aba principal do serviço
2. Clique em **"Deploy"** ou **"Restart"**

---

## 📊 Impacto das Configurações

| Configuração | Antes (Padrão) | Depois (Otimizado) | Impacto |
|--------------|----------------|-------------------|---------|
| **Upload Max** | 2M | 512M | ✅ Permite upload de vídeos grandes |
| **Execution Time** | 30s | 600s | ✅ Evita timeout em operações longas |
| **Memory Limit** | 128M | 256M | ✅ Mais memória para processamento |
| **OPcache** | Desativado | Ativado | ✅ 30-50% mais rápido |
| **Session Lifetime** | 1440s | 86400s | ✅ Usuários não deslogam rapidamente |

---

## ⚠️ Observações Importantes

### Timezone

O arquivo `php.ini` usa `America/Sao_Paulo` como timezone padrão. Se sua aplicação estiver em outra região, ajuste para:

- **Brasília/São Paulo**: `America/Sao_Paulo`
- **Rio de Janeiro**: `America/Sao_Paulo`
- **Manaus**: `America/Manaus`
- **Fortaleza**: `America/Fortaleza`
- **Lisboa**: `Europe/Lisbon`

### Funções Desabilitadas

Por segurança, as seguintes funções foram desabilitadas:

```
exec, passthru, shell_exec, system, proc_open, popen
```

Se o Academy LMS precisar de alguma dessas funções (improvável), você pode removê-las da linha `disable_functions`.

### OPcache em Desenvolvimento

Se você estiver em ambiente de desenvolvimento e quiser ver mudanças no código imediatamente, ajuste:

```ini
opcache.validate_timestamps = 1
opcache.revalidate_freq = 0
```

Em **produção**, para máxima performance:

```ini
opcache.validate_timestamps = 0
opcache.revalidate_freq = 60
```

---

## 🚀 Verificação

Após aplicar as configurações e fazer re-deploy:

1. Acesse a aplicação
2. Crie um arquivo `phpinfo.php` temporário:

```php
<?php
phpinfo();
```

3. Acesse `https://seu-dominio.com/phpinfo.php`
4. Verifique se as configurações foram aplicadas:
   - Procure por `upload_max_filesize` → deve mostrar `512M`
   - Procure por `max_execution_time` → deve mostrar `600`
   - Procure por `opcache.enable` → deve mostrar `On`

5. **IMPORTANTE**: Delete o arquivo `phpinfo.php` após a verificação por segurança!

---

## ✅ Checklist

- [ ] Versão do PHP configurada para 8.3
- [ ] Tamanho Máximo de Upload: 512M
- [ ] Tempo Máximo de Execução: 600
- [ ] OPcache ativado
- [ ] PHP INI customizado colado e salvo
- [ ] Re-deploy realizado
- [ ] Configurações verificadas (opcional)

---

## 📞 Suporte

Se encontrar problemas após aplicar as configurações:

1. Verifique os **logs do container** no EasyPanel
2. Confirme que o re-deploy foi bem-sucedido
3. Teste fazer upload de um arquivo pequeno primeiro
4. Aumente gradualmente o tamanho dos arquivos de teste

