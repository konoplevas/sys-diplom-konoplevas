#!/bin/bash

echo "🔍 Начинаем проверку на наличие токенов в репозитории..."
echo "========================================================"

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOKEN_FOUND=0
CHECKED_FILES=0

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; TOKEN_FOUND=1; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# 1. Проверка основных файлов
echo ""
echo "1. Проверяем основные файлы:"
echo "------------------------------"

check_file() {
    local file="$1"
    if [ -f "$file" ]; then
        CHECKED_FILES=$((CHECKED_FILES + 1))
        echo -n "Проверяем $file... "
        
        if grep -q -E "(t1\.|y0_|YC_TOKEN=|yc_token|token.*=)" "$file" 2>/dev/null; then
            print_error "Найден токен!"
            echo "Содержимое:"
            grep -n -E "(t1\.|y0_|YC_TOKEN=|yc_token|token.*=)" "$file"
            echo ""
        else
            print_success "OK"
        fi
    fi
}

check_file "terraform.tfvars"
check_file "variables.tf"
check_file "provider.tf"
check_file "main.tf"

# Проверяем все .auto.tfvars
for file in *.auto.tfvars; do
    check_file "$file"
done

# 2. Проверка Ansible файлов
echo ""
echo "2. Проверяем Ansible файлы:"
echo "----------------------------"

check_file "ansible/group_vars/all.yml"
check_file "ansible/host_vars/"*.yml 2>/dev/null
check_file "ansible/vars/"*.yml 2>/dev/null

# 3. Проверка всех файлов в проекте
echo ""
echo "3. Проверяем все файлы в проекте:"
echo "----------------------------------"

SEARCH_RESULT=$(grep -r -E "(t1\.|y0_)" . \
    --exclude-dir=.git \
    --exclude-dir=.terraform \
    --exclude=*.png \
    --exclude=*.jpg \
    --exclude=check-tokens.sh \
    2>/dev/null)

if [ -n "$SEARCH_RESULT" ]; then
    print_error "Найдены токены в других файлах:"
    echo "$SEARCH_RESULT"
else
    print_success "Токенов не найдено в других файлах"
fi

# 4. Проверка истории Git
echo ""
echo "4. Проверяем историю Git:"
echo "--------------------------"

if command -v git &> /dev/null; then
    GIT_HISTORY=$(git log --all --full-history -p 2>/dev/null | grep -B1 -A1 -E "(t1\.|y0_)" | head -20)
    
    if [ -n "$GIT_HISTORY" ]; then
        print_warning "Возможно токены есть в истории Git (первые 20 строк):"
        echo "$GIT_HISTORY"
        echo ""
        print_warning "Для полной очистки истории выполните:"
        echo "  git filter-branch --force --index-filter \"git rm --cached --ignore-unmatch terraform.tfvars\" --prune-empty --tag-name-filter cat -- --all"
    else
        print_success "История Git чистая"
    fi
else
    print_warning "Git не установлен, пропускаем проверку истории"
fi

# 5. Итог
echo ""
echo "========================================================"
echo "📊 ИТОГИ ПРОВЕРКИ:"
echo "   Проверено файлов: $CHECKED_FILES"

if [ $TOKEN_FOUND -eq 0 ]; then
    print_success "Поздравляю! Токенов не найдено!"
    echo ""
    echo "Рекомендации для безопасности:"
    echo "1. Храните токен в переменных окружения:"
    echo "   export YC_TOKEN='t1.xxx'"
    echo "2. Используйте .env файл (добавьте в .gitignore!)"
    echo "3. В Terraform используйте: token = var.yc_token"
else
    print_error "Найдены токены! Необходимо их удалить."
    echo ""
    echo "🚨 СРОЧНЫЕ ДЕЙСТВИЯ:"
    echo "1. Смените токен в Yandex Cloud"
    echo "2. Удалите файлы с токенами из репозитория"
    echo "3. Если токен был в истории, смените его И очистите историю"
fi

echo ""
echo "Для применения Terraform используйте:"
echo "terraform apply -var='yc_token=\$YC_TOKEN'"

exit $TOKEN_FOUND
