#!/bin/bash

# Script de Configuração Inicial do Banco de Dados para Academy LMS
# Este script deve ser executado após o primeiro deploy no EasyPanel

set -e

echo "==================================="
echo "Academy LMS - Setup do Banco de Dados"
echo "==================================="
echo ""

# Verificar se as variáveis de ambiente estão definidas
if [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
    echo "❌ ERRO: Variáveis de ambiente não configuradas!"
    echo "Certifique-se de que DB_HOST, DB_NAME, DB_USER e DB_PASS estão definidas."
    exit 1
fi

echo "📋 Configurações detectadas:"
echo "   Host: $DB_HOST"
echo "   Banco: $DB_NAME"
echo "   Usuário: $DB_USER"
echo ""

# Verificar se o arquivo install.sql existe
if [ ! -f "uploads/install.sql" ]; then
    echo "❌ ERRO: Arquivo uploads/install.sql não encontrado!"
    exit 1
fi

echo "🔄 Aguardando banco de dados ficar disponível..."
until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" &> /dev/null; do
    echo "   Aguardando conexão com o banco de dados..."
    sleep 3
done

echo "✅ Conexão com banco de dados estabelecida!"
echo ""

# Verificar se o banco já foi inicializado
TABLE_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME'")

if [ "$TABLE_COUNT" -gt 0 ]; then
    echo "⚠️  AVISO: O banco de dados já contém $TABLE_COUNT tabelas."
    echo "   Deseja sobrescrever? (isso irá APAGAR todos os dados existentes)"
    read -p "   Digite 'SIM' para confirmar: " CONFIRM
    
    if [ "$CONFIRM" != "SIM" ]; then
        echo "❌ Operação cancelada pelo usuário."
        exit 0
    fi
    
    echo "🗑️  Limpando banco de dados existente..."
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SET FOREIGN_KEY_CHECKS = 0; $(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "SELECT CONCAT('DROP TABLE IF EXISTS \`', table_name, '\`;') FROM information_schema.tables WHERE table_schema = '$DB_NAME'") SET FOREIGN_KEY_CHECKS = 1;"
fi

echo "📥 Importando estrutura do banco de dados..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < uploads/install.sql

if [ $? -eq 0 ]; then
    echo "✅ Banco de dados configurado com sucesso!"
    echo ""
    echo "🎉 Próximos passos:"
    echo "   1. Acesse a aplicação através do navegador"
    echo "   2. Crie sua conta de administrador"
    echo "   3. Configure as informações da escola/instituição"
    echo ""
else
    echo "❌ ERRO: Falha ao importar o banco de dados!"
    exit 1
fi

