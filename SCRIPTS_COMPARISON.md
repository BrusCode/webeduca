# Comparação dos Scripts de Instalação do Academy LMS

## 📋 Visão Geral

Foram criados **dois scripts de instalação** com abordagens diferentes:

1. **install-academy-web-installer.sh** - Usa o instalador web oficial
2. **install-academy-automated.sh** - Instalação 100% automatizada

---

## 🔍 Análise do Problema Original

### O Que Aconteceu

O script original (`install-academy-ubuntu.sh`) estava:
1. ✅ Criando o banco de dados
2. ✅ Importando o SQL
3. ❌ **Mas o usuário ainda acessava o instalador web**

### Por Que Deu Erro

O instalador web tentou:
- Criar tabelas que **já existiam** (importadas pelo script)
- Resultado: `ERROR: Table 'addons' already exists`

### Conclusão Correta do Usuário

> "Creio que na aba install ele deve criar todo o banco e usuário. Como instalamos o banco antes, deu erro. Creio que a solução para correção anterior não tinha a ver com o banco e sim com o config.php."

**100% correto!** O problema era a **ordem das operações**, não a falta do `config.php`.

---

## 📊 Comparação Detalhada

| Aspecto | Script A (Web Installer) | Script B (Automated) |
|---------|--------------------------|----------------------|
| **Nome do Arquivo** | `install-academy-web-installer.sh` | `install-academy-automated.sh` |
| **Cria banco de dados?** | ❌ Não | ✅ Sim |
| **Importa SQL?** | ❌ Não | ✅ Sim |
| **Cria usuário admin?** | ❌ Não | ✅ Sim |
| **Usa instalador web?** | ✅ Sim | ❌ Não |
| **Interação do usuário** | ⚠️ Média (instalador web) | ✅ Mínima (só no início) |
| **Tempo de instalação** | ~15-20 min | ~10-15 min |
| **Passos totais** | 9 passos + instalador | 12 passos |
| **URL final** | `/install/step0` | `/login` |
| **Recomendado para** | Produção, primeira instalação | Testes, reinstalações, automação |

---

## 📝 Script A: install-academy-web-installer.sh

### Características

✅ **Prepara o ambiente** (Apache, MySQL, PHP)  
✅ **Baixa o código-fonte**  
✅ **Instala config.php**  
✅ **Configura permissões**  
❌ **NÃO cria banco de dados**  
❌ **NÃO importa SQL**  
❌ **NÃO cria admin**  

### Fluxo de Instalação

```
1. Executar script
   ↓
2. Script prepara ambiente
   ↓
3. Acessar https://seudominio.com/install/step0
   ↓
4. Instalador web solicita:
   - Credenciais MySQL root
   - Nome do banco a criar
   ↓
5. Instalador cria banco e importa SQL
   ↓
6. Instalador solicita dados do admin
   ↓
7. Sistema pronto!
```

### Quando Usar

- ✅ **Primeira instalação em produção**
- ✅ **Quando quer seguir o fluxo oficial**
- ✅ **Quando precisa de controle sobre cada etapa**
- ✅ **Quando o cliente vai fazer a instalação**

### Vantagens

- Segue o fluxo oficial do Academy LMS
- Permite verificar cada etapa
- Mais "profissional" (usa o instalador oficial)
- Melhor para documentação/tutoriais

### Desvantagens

- Requer interação manual no instalador web
- Mais demorado
- Pode dar erro se o instalador web tiver bugs

---

## 📝 Script B: install-academy-automated.sh

### Características

✅ **Prepara o ambiente** (Apache, MySQL, PHP)  
✅ **Baixa o código-fonte**  
✅ **Instala config.php**  
✅ **Configura permissões**  
✅ **Cria banco de dados**  
✅ **Importa SQL**  
✅ **Cria usuário admin**  

### Fluxo de Instalação

```
1. Executar script
   ↓
2. Informar dados (domínio, senhas, admin)
   ↓
3. Script faz TUDO automaticamente
   ↓
4. Acessar https://seudominio.com/login
   ↓
5. Fazer login com credenciais informadas
   ↓
6. Sistema pronto!
```

### Quando Usar

- ✅ **Ambientes de teste**
- ✅ **Reinstalações rápidas**
- ✅ **Automação/CI-CD**
- ✅ **Quando quer velocidade**
- ✅ **Quando já conhece o sistema**

### Vantagens

- 100% automatizado
- Mais rápido
- Menos chance de erro humano
- Ideal para testes e desenvolvimento

### Desvantagens

- Pula o instalador oficial
- Menos "didático"
- Requer todas as informações no início

---

## 🎯 Recomendações

### Para Produção (Cliente Final)

**Use o Script A** (`install-academy-web-installer.sh`)

```bash
wget https://raw.githubusercontent.com/BrusCode/webeduca/main/install-academy-web-installer.sh
chmod +x install-academy-web-installer.sh
sudo ./install-academy-web-installer.sh
```

**Por quê?**
- Segue o fluxo oficial
- Cliente vê o instalador profissional
- Melhor para documentação
- Mais confiável (usa o instalador oficial)

---

### Para Testes/Desenvolvimento

**Use o Script B** (`install-academy-automated.sh`)

```bash
wget https://raw.githubusercontent.com/BrusCode/webeduca/main/install-academy-automated.sh
chmod +x install-academy-automated.sh
sudo ./install-academy-automated.sh
```

**Por quê?**
- Muito mais rápido
- Totalmente automatizado
- Ideal para reinstalações
- Perfeito para ambientes de teste

---

## 🔧 Correções Aplicadas em Ambos

Ambos os scripts incluem **todas as correções** anteriores:

1. ✅ Detecção automática Ubuntu 22.04/24.04
2. ✅ PHP correto (8.1 ou 8.3)
3. ✅ MySQL auth_socket fix para Ubuntu 24.04
4. ✅ Criação automática de pastas (uploads, backups, logs, cache)
5. ✅ Download e instalação do config.php
6. ✅ Substituição automática da base_url
7. ✅ Tratamento de erros melhorado
8. ✅ Mensagens coloridas e informativas
9. ✅ Configurações de produção (2GB uploads, OPcache)
10. ✅ Instalação de SSL automática

---

## 📦 Estrutura dos Arquivos

### Script A (Web Installer)

```
Passos:
1. Atualizar sistema
2. Instalar pacotes essenciais
3. Instalar Apache
4. Instalar MySQL (só configura root)
5. Instalar PHP
6. Configurar PHP
7. Clonar repositório
8. Configurar Virtual Host
9. Instalar SSL

Resultado: https://seudominio.com/install/step0
```

### Script B (Automated)

```
Passos:
1. Atualizar sistema
2. Instalar pacotes essenciais
3. Instalar Apache
4. Instalar MySQL
5. Instalar PHP
6. Criar banco de dados ← DIFERENÇA
7. Configurar PHP
8. Clonar repositório
9. Configurar database.php ← DIFERENÇA
10. Importar SQL ← DIFERENÇA
11. Criar admin ← DIFERENÇA
12. Configurar Virtual Host
13. Instalar SSL

Resultado: https://seudominio.com/login
```

---

## 🧪 Testes Recomendados

### Teste 1: Script A (Web Installer)

```bash
# Em uma VPS limpa Ubuntu 24.04
wget https://raw.githubusercontent.com/BrusCode/webeduca/main/install-academy-web-installer.sh
chmod +x install-academy-web-installer.sh
sudo ./install-academy-web-installer.sh

# Informar:
# - Domínio: test-a.seudominio.com
# - Senha MySQL root: TestRoot123!
# - Email SSL: seu@email.com

# Depois acessar:
# https://test-a.seudominio.com/install/step0

# Seguir instalador web
```

### Teste 2: Script B (Automated)

```bash
# Em uma VPS limpa Ubuntu 24.04
wget https://raw.githubusercontent.com/BrusCode/webeduca/main/install-academy-automated.sh
chmod +x install-academy-automated.sh
sudo ./install-academy-automated.sh

# Informar:
# - Domínio: test-b.seudominio.com
# - Senha MySQL root: TestRoot123!
# - Senha DB: TestDB123!
# - Email SSL: seu@email.com
# - Nome admin: Admin
# - Sobrenome: Sistema
# - Email admin: admin@test.com
# - Senha admin: Admin@123

# Depois acessar:
# https://test-b.seudominio.com/login
```

---

## ✅ Checklist de Validação

Após executar cada script, verificar:

### Funcionalidades Básicas

- [ ] Site acessível via HTTPS
- [ ] Login funciona
- [ ] Dashboard carrega
- [ ] Pode criar curso
- [ ] Pode fazer upload de imagem
- [ ] Pode fazer upload de vídeo (teste com arquivo pequeno)

### Configurações

- [ ] PHP: `php -v` mostra versão correta
- [ ] MySQL: Banco `academy_lms` existe
- [ ] Tabelas: 41 tabelas criadas
- [ ] Admin: Usuário admin existe e funciona
- [ ] SSL: Certificado válido
- [ ] Logs: Sem erros em `/var/log/apache2/error.log`

---

## 📚 Documentação

Ambos os scripts estão documentados em:

- **README.md**: Documentação principal
- **UBUNTU_NATIVE_INSTALLATION.md**: Tutorial manual
- **INSTALLATION_FIXES_SUMMARY.md**: Histórico de correções
- **SCRIPTS_COMPARISON.md**: Este documento

---

## 🎯 Decisão Final

### Para o Repositório GitHub

**Recomendo manter o Script A como padrão** (`install-academy-ubuntu.sh`)

**Motivo**:
- Segue o fluxo oficial do Academy LMS
- Mais adequado para produção
- Melhor experiência para usuários finais
- Permite que o instalador web faça seu trabalho

**Script B** pode ser disponibilizado como alternativa:
- `install-academy-automated.sh` (para quem quer automação total)

---

## 📝 Resumo

| Critério | Vencedor |
|----------|----------|
| **Velocidade** | Script B |
| **Facilidade** | Script B |
| **Profissionalismo** | Script A |
| **Produção** | Script A |
| **Testes** | Script B |
| **Automação** | Script B |
| **Confiabilidade** | Script A |
| **Documentação** | Script A |

**Conclusão**: Use **Script A para produção** e **Script B para testes/desenvolvimento**.

