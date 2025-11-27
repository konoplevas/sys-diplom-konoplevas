#!/bin/bash
echo "=== ДИПЛОМНЫЙ ПРОЕКТ - ФИНАЛЬНАЯ ПРОВЕРКА ==="

echo -e "\n=== 1. ИНФРАСТРУКТУРА ==="
echo "ВМ:"
yc compute instance list

echo -e "\n=== 2. САЙТ И БАЛАНСИРОВЩИК ==="
echo "Балансировщик:"
ALB_IP=$(yc alb load-balancer list --format json | jq -r '.[0].listeners[0].endpoints[0].addresses[0].external_ipv4_address.address')
echo "ALB IP: $ALB_IP"
curl -s http://$ALB_IP | grep -A2 "Добро пожаловать"

echo -e "\n=== 3. МОНИТОРИНГ ZABBIX ==="
echo "Zabbix сервер:"
yc compute instance get zabbix --format json | jq '.network_interfaces[0].primary_v4_address.address'
echo "Zabbix agents:"
ssh web1-diploma "systemctl status zabbix-agent --no-pager | grep Active"
ssh web2-diploma "systemctl status zabbix-agent --no-pager | grep Active"

echo -e "\n=== 4. ЛОГИ ELASTICSEARCH + KIBANA ==="
echo "Elasticsearch:"
ssh elastic-diploma "curl -s http://localhost:9200 | jq '.version.number'"
echo "Kibana:"
ssh kibana-diploma "docker ps | grep kibana"

echo -e "\n=== 5. РЕЗЕРВНОЕ КОПИРОВАНИЕ ==="
echo "Snapshot schedule:"
yc compute snapshot-schedule list
echo "Последние снапшоты:"
yc compute snapshot list --limit 3

echo -e "\n=== 6. СБОР ЛОГОВ ==="
echo "Скрипты сбора логов:"
ssh web1-diploma "ps aux | grep send-nginx-logs | grep -v grep"
ssh web2-diploma "ps aux | grep send-nginx-logs | grep -v grep"

echo -e "\n=== ПРОВЕРКА ЗАВЕРШЕНА ==="
