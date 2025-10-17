# Academy LMS no EasyPanel - Guia Rápido de Referência

## Informações Essenciais

| Item | Descrição |
|------|-----------|
| **Repositório GitHub** | `BrusCode/webeduca` |
| **Framework** | PHP CodeIgniter 3.x |
| **Servidor Web** | Apache com mod_rewrite |
| **Banco de Dados** | MySQL 5.6+ ou MariaDB 10.0+ |
| **Versão PHP Recomendada** | 8.1 |

---

## Variáveis de Ambiente Obrigatórias

Configure estas variáveis no EasyPanel:

```env
DB_HOST=academy-db
DB_NAME=academy_lms
DB_USER=seu_usuario
DB_PASS=sua_senha_segura
```

---

## Estrutura de Diretórios Importantes

```
Academy-LMS/
├── application/          # Código da aplicação (MVC)
│   ├── config/          # Arquivos de configuração
│   │   ├── database.php # ⚠️ Modificar para usar env vars
│   │   └── config.php   # Configurações gerais
│   ├── controllers/     # Controladores
│   ├── models/          # Modelos
│   └── views/           # Views (Backend/Frontend)
├── uploads/             # 📁 Volume persistente necessário
│   └── install.sql      # Script SQL inicial
├── backups/             # 📁 Volume persistente necessário
├── assets/              # CSS, JS, imagens
├── system/              # Core do CodeIgniter
└── index.php            # Ponto de entrada
```

---

## Comandos Úteis

### Importar Banco de Dados Inicial

```bash
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < uploads/install.sql
```

### Backup do Banco de Dados

```bash
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME > backup_$(date +%Y%m%d).sql
```

### Verificar Permissões

```bash
ls -la uploads/
ls -la backups/
```

### Limpar Cache do CodeIgniter

```bash
rm -rf application/cache/*
```

---

## Volumes Persistentes no EasyPanel

Configure estes volumes para evitar perda de dados:

| Diretório Local | Volume | Descrição |
|-----------------|--------|-----------|
| `/var/www/html/uploads` | `academy_uploads` | Arquivos enviados (imagens, vídeos) |
| `/var/www/html/backups` | `academy_backups` | Backups automáticos |

---

## Portas e Serviços

| Serviço | Porta Interna | Porta Externa (EasyPanel) |
|---------|---------------|---------------------------|
| Apache/PHP | 80 | Gerenciado pelo Traefik |
| MySQL | 3306 | Apenas interno (não expor) |

---

## Checklist de Deploy

- [ ] Banco de dados MySQL criado no EasyPanel
- [ ] Variáveis de ambiente configuradas (DB_HOST, DB_NAME, DB_USER, DB_PASS)
- [ ] Arquivo `application/config/database.php` modificado para usar `getenv()`
- [ ] Código commitado e enviado para o GitHub
- [ ] Projeto criado no EasyPanel apontando para o repositório
- [ ] Volumes persistentes configurados para `uploads/` e `backups/`
- [ ] Primeiro deploy realizado
- [ ] Banco de dados importado com `uploads/install.sql`
- [ ] Re-deploy após importação do banco
- [ ] Acesso à aplicação via navegador testado
- [ ] Conta de administrador criada
- [ ] SSL/HTTPS configurado e funcionando

---

## Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| **Erro 500** | Verificar logs do contêiner; conferir credenciais do banco |
| **Página em branco** | Verificar logs de erro do PHP; conferir permissões |
| **Erro de conexão DB** | Verificar se variáveis de ambiente estão corretas; testar conexão com `mysql -h $DB_HOST -u $DB_USER -p` |
| **Upload falha** | Aumentar `upload_max_filesize` e `post_max_size` no php.ini |
| **Permissão negada** | Executar `chmod -R 777 uploads/ backups/` no contêiner |

---

## Links Úteis

- **Documentação CodeIgniter 3**: https://codeigniter.com/userguide3/
- **EasyPanel Docs**: https://easypanel.io/docs
- **PHP Docker Official**: https://hub.docker.com/_/php

---

## Suporte

Para questões relacionadas ao Academy LMS, consulte:
- **Documentação incluída**: `AdministratorUsageGuide.pdf`, `DeveloperManual.pdf`
- **Suporte Oficial**: Creativeitem Support Center

Para questões do EasyPanel:
- **Documentação**: https://easypanel.io/docs
- **Comunidade**: Discord do EasyPanel

