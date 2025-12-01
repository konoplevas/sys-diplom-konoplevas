#!/bin/bash
echo "=== БЕЗОПАСНАЯ ПРОВЕРКА ТОКЕНОВ ==="
echo "Исключаем скрипты проверки из поиска"
echo ""

# Файлы которые МОГУТ содержать тестовые строки
EXCLUDE="--exclude=*.sh --exclude=check-tokens.sh --exclude=full_check.sh --exclude=safe_check.sh"

echo "1. GitHub токены (ghp_):"
if grep -r "ghp_" . --exclude-dir=.git --exclude-dir=.terraform $EXCLUDE 2>/dev/null; then
    echo "❌ НАЙДЕНЫ GitHub ТОКЕНЫ!"
else
    echo "✅ Не найдено"
fi

echo ""
echo "2. Yandex токены (y0_, t1.):"
if grep -r -E "y0_|t1\." . --exclude-dir=.git --exclude-dir=.terraform $EXCLUDE 2>/dev/null; then
    echo "❌ НАЙДЕНЫ Yandex ТОКЕНЫ!"
else
    echo "✅ Не найдено"
fi

echo ""
echo "3. SSH приватные ключи:"
if grep -r "-----BEGIN" . --exclude-dir=.git --exclude-dir=.terraform $EXCLUDE 2>/dev/null; then
    echo "⚠️  Возможны приватные ключи (проверь файлы):"
    grep -r -l "-----BEGIN" . --exclude-dir=.git --exclude-dir=.terraform $EXCLUDE 2>/dev/null
else
    echo "✅ Не найдено"
fi

echo ""
echo "4. Пароли в Ansible (это нормально для шаблонов):"
grep -r -i "POSTGRES_PASSWORD\|MYSQL_PASSWORD" ansible/ 2>/dev/null | head -3
echo "   (пароли в шаблонах заменяются при деплое)"

echo ""
echo "=== РЕАЛЬНЫЕ ПРОБЛЕМЫ: ==="
echo "Проверь эти файлы если есть вывод выше:"
grep -r -l "ghp_\|y0_\|t1\." . --exclude-dir=.git --exclude-dir=.terraform --exclude=*.sh 2>/dev/null
