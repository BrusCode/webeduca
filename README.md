# Academy LMS - Sistema de Gerenciamento de Aprendizagem

## Sobre o Projeto

Academy LMS é um sistema completo de gerenciamento de aprendizagem baseado em cursos, desenvolvido com PHP CodeIgniter seguindo o padrão MVC.

## Requisitos do Sistema

### Servidor
- **PHP**: 7.2 ou superior
- **Servidor Web**: Apache ou Nginx
- **Banco de Dados**: MySQL 5.6+ ou MariaDB 10.0+

### Extensões PHP Necessárias
- cURL (obrigatório)
- MySQLi ou PDO
- GD Library
- mbstring
- OpenSSL

## Estrutura do Projeto

```
Academy-LMS/
├── application/        # Código da aplicação (MVC)
│   ├── controllers/   # Controladores
│   ├── models/        # Modelos
│   ├── views/         # Views (Backend, Frontend, Install)
│   └── config/        # Configurações
├── assets/            # CSS, JS e plugins
│   ├── backend/       # Assets do painel admin
│   ├── frontend/      # Assets do site público
│   └── payment/       # Assets de pagamento
├── uploads/           # Arquivos enviados (imagens, thumbnails)
├── system/            # Core do CodeIgniter
├── themes/            # Temas personalizados
├── languages/         # Arquivos de idioma
└── index.php          # Ponto de entrada
```

## Instalação

Este repositório oferece **três métodos de instalação** para atender diferentes necessidades e níveis de experiência:

### Método 1: Instalação via EasyPanel (Recomendado para Produção)

Ideal para equipes que buscam agilidade e facilidade de gerenciamento. O EasyPanel automatiza o deploy, configuração de SSL e escalabilidade.

📘 **[Tutorial Completo: EASYPANEL_INSTALLATION.md](EASYPANEL_INSTALLATION.md)**

📗 **[Configurações Avançadas: EASYPANEL_ADVANCED.md](EASYPANEL_ADVANCED.md)**

### Método 2: Instalação em VPS Ubuntu Dedicada

Para administradores experientes que desejam controle total sobre o ambiente. Configuração manual do stack LAMP (Linux, Apache, MySQL, PHP).

📕 **[Tutorial Completo: VPS_INSTALLATION.md](VPS_INSTALLATION.md)**

### Método 3: Instalação Web (Padrão do Produto)

1. Faça upload dos arquivos para seu servidor
2. Crie um banco de dados MySQL
3. Acesse via navegador (ex: `https://seudominio.com/academy`)
4. Siga o assistente de instalação web
5. Insira as credenciais do banco de dados
6. Configure o administrador do sistema

---

## Comparação entre Métodos de Instalação

Não sabe qual método escolher? Consulte nosso relatório comparativo detalhado:

📊 **[Relatório Comparativo: COMPARISON_REPORT.md](COMPARISON_REPORT.md)**

O relatório analisa vantagens, desvantagens, escalabilidade e desempenho de cada abordagem.

---

## Guia Rápido de Referência

Para comandos úteis, troubleshooting e checklist de deploy:

📙 **[Guia Rápido: QUICK_REFERENCE.md](QUICK_REFERENCE.md)**

---

## Configuração

### Banco de Dados

Edite o arquivo `application/config/database.php`:

```php
$db['default'] = array(
    'hostname' => 'localhost',
    'username' => 'seu_usuario',
    'password' => 'sua_senha',
    'database' => 'seu_banco',
    'dbdriver' => 'mysqli',
    // ...
);
```

### URL Base

Edite o arquivo `application/config/config.php`:

```php
$config['base_url'] = 'https://seudominio.com/';
```

## Permissões de Arquivo

Os seguintes arquivos/diretórios precisam de permissão de escrita:

- `application/config/database.php`
- `application/config/routes.php`
- `uploads/` (recursivo)
- `backups/` (recursivo)

## Credenciais Padrão

Após a instalação, as credenciais são definidas durante o processo de setup inicial.

## Suporte

Para suporte oficial, visite: [Creativeitem Support Center](https://support.creativeitem.com/)

## Licença

Este produto é licenciado via CodeCanyon. Consulte os termos de licença do CodeCanyon para mais informações.

## Copyright

Copyright © 2018-2024 Creativeitem. Todos os direitos reservados.

