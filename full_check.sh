#!/bin/bash
echo "=== ПОЛНАЯ ПРОВЕРКА ТОКЕНОВ И КЛЮЧЕЙ ==="
echo "Время: $(date)"
echo ""

echo "1. Поиск GitHub токенов (ghp_):"
grep -r "ghp_" . --exclude-dir=.git --exclude-dir=.terraform 2>/dev/null | head -5
if [ $? -eq 0 ]; then echo "❌ Найдены GitHub токены!"; else echo "✅ Не найдено"; fi

echo ""
echo "2. Поиск Yandex токенов (y0_, t1.):"
grep -r -E "y0_|t1\." . --exclude-dir=.git --exclude-dir=.terraform 2>/dev/null | head -5
if [ $? -eq 0 ]; then echo "❌ Найдены Yandex токены!"; else echo "✅ Не найдено"; fi

echo ""
echo "3. Поиск SSH приватных ключей (-----BEGIN):"
grep -r "-----BEGIN" . --exclude-dir=.git --exclude-dir=.terraform 2>/dev/null | head -3
if [ $? -eq 0 ]; then echo "❌ Найдены приватные ключи!"; else echo "✅ Не найдено"; fi

echo ""
echo "4. Поиск паролей в открытом виде (password=, passwd=):"
grep -r -i "password=\|passwd=\|secret=" . --exclude-dir=.git --exclude-dir=.terraform 2>/dev/null | head -3
if [ $? -eq 0 ]; then echo "❌ Найдены пароли!"; else echo "✅ Не найдено"; fi

echo ""
echo "5. Проверка .gitignore:"
echo "   Защищённые паттерны:"
grep -E "tfvars|tfstate|\.terraform|token|secret|password" .gitignore | head -5

echo ""
echo "=== ИТОГ ==="
echo "✅ Проверка завершена"
