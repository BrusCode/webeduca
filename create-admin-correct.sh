#!/bin/bash

################################################################################
# Script para Criar Usuário Administrador no Academy LMS
# Versão: 1.0 (Corrigida com estrutura real da tabela)
################################################################################

echo "=== Criação de Usuário Administrador ==="
echo ""

# Solicitar dados
read -p "Email do admin: " ADMIN_EMAIL
read -p "Primeiro nome: " FIRST_NAME
read -p "Último nome: " LAST_NAME
read -sp "Senha: " ADMIN_PASSWORD
echo ""

# Gerar hash da senha
HASH=$(php -r "echo password_hash('$ADMIN_PASSWORD', PASSWORD_BCRYPT);")

echo ""
echo "Hash gerado: $HASH"
echo ""
echo "Criando usuário no banco de dados..."

# Inserir no banco com estrutura correta
mysql -u academy_user -p academy_lms <<SQL_INSERT
INSERT INTO users (
    first_name,
    last_name,
    email,
    password,
    role_id,
    status,
    date_added,
    last_modified,
    is_instructor,
    skills,
    payment_keys,
    sessions
) VALUES (
    '$FIRST_NAME',
    '$LAST_NAME',
    '$ADMIN_EMAIL',
    '$HASH',
    1,
    1,
    UNIX_TIMESTAMP(),
    UNIX_TIMESTAMP(),
    1,
    '[]',
    '[]',
    '[]'
);

-- Verificar se foi criado
SELECT id, first_name, last_name, email, role_id, status FROM users WHERE email = '$ADMIN_EMAIL';
SQL_INSERT

echo ""
echo "✅ Usuário administrador criado com sucesso!"
echo ""
echo "🌐 Acesse: https://ead.qualityautomacao.com.br/login"
echo "📧 Email: $ADMIN_EMAIL"
echo "🔑 Senha: [a senha que você definiu]"
echo ""
echo "Detalhes do usuário:"
echo "  - Role ID: 1 (Administrador)"
echo "  - Status: 1 (Ativo)"
echo "  - Is Instructor: 1 (Sim)"

