#!/bin/bash

cd ~/yandex-diploma/terraform

ALB_IP=$(terraform output -raw alb_external_ip)
BASTION_IP=$(terraform output -raw bastion_external_ip)
ZABBIX_IP=$(terraform output -raw zabbix_external_ip)
KIBANA_IP=$(terraform output -raw kibana_external_ip)
ELASTIC_IP=$(terraform output -raw elastic_internal_ip)
WEB1_IP=$(terraform output -raw web1_internal_ip)
WEB2_IP=$(terraform output -raw web2_internal_ip)

echo "Публичные IP:"
echo "Балансировщик: $ALB_IP"
echo "Bastion: $BASTION_IP"
echo "Zabbix: $ZABBIX_IP"
echo "Kibana: $KIBANA_IP"
echo ""
echo "Приватные IP:"
echo "Elasticsearch: $ELASTIC_IP"
echo "Web1: $WEB1_IP"
echo "Web2: $WEB2_IP"
echo ""

echo "Проверка сетевой доступности:"
ping -c 1 -W 2 $ALB_IP >/dev/null 2>&1 && echo "Балансировщик: доступен" || echo "Балансировщик: недоступен"
ping -c 1 -W 2 $BASTION_IP >/dev/null 2>&1 && echo "Bastion: доступен" || echo "Bastion: недоступен"
ping -c 1 -W 2 $ZABBIX_IP >/dev/null 2>&1 && echo "Zabbix: доступен" || echo "Zabbix: недоступен"
ping -c 1 -W 2 $KIBANA_IP >/dev/null 2>&1 && echo "Kibana: доступен" || echo "Kibana: недоступен"
echo ""

echo "Проверка веб-сервисов:"
curl -s -f http://$ALB_IP/ >/dev/null && echo "Сайт: работает" || echo "Сайт: не работает"
curl -s -f http://$ZABBIX_IP/ >/dev/null && echo "Zabbix: работает" || echo "Zabbix: не работает"
curl -s -f http://$KIBANA_IP:5601 >/dev/null && echo "Kibana: работает" || echo "Kibana: не работает"
echo ""

echo "Проверка SSH доступа:"
ssh -o ConnectTimeout=5 -o BatchMode=yes ubuntu@$BASTION_IP 'exit 0' >/dev/null 2>&1 && echo "Bastion SSH: доступен" || echo "Bastion SSH: недоступен"
ssh -o ConnectTimeout=5 -o BatchMode=yes ubuntu@$ZABBIX_IP 'exit 0' >/dev/null 2>&1 && echo "Zabbix SSH: доступен" || echo "Zabbix SSH: недоступен"
ssh -o ConnectTimeout=5 -o BatchMode=yes ubuntu@$KIBANA_IP 'exit 0' >/dev/null 2>&1 && echo "Kibana SSH: доступен" || echo "Kibana SSH: недоступен"
echo ""

echo "Проверка сервисов на ВМ:"
if ssh -o ConnectTimeout=5 ubuntu@$BASTION_IP "echo test" >/dev/null 2>&1; then
    ssh ubuntu@$BASTION_IP "ssh ubuntu@$WEB1_IP 'systemctl is-active nginx >/dev/null && echo \"Web1 Nginx: работает\" || echo \"Web1 Nginx: не работает\"'"
    ssh ubuntu@$BASTION_IP "ssh ubuntu@$WEB2_IP 'systemctl is-active nginx >/dev/null && echo \"Web2 Nginx: работает\" || echo \"Web2 Nginx: не работает\"'"
    ssh ubuntu@$BASTION_IP "ssh ubuntu@$ELASTIC_IP 'docker ps | grep -q elasticsearch && echo \"Elasticsearch: работает\" || echo \"Elasticsearch: не работает\"'"
    ssh ubuntu@$BASTION_IP "ssh ubuntu@$ZABBIX_IP 'docker ps | grep -q zabbix && echo \"Zabbix: работает\" || echo \"Zabbix: не работает\"'"
    ssh ubuntu@$BASTION_IP "ssh ubuntu@$KIBANA_IP 'docker ps | grep -q kibana && echo \"Kibana: работает\" || echo \"Kibana: не работает\"'"
else
    echo "Bastion недоступен для детальной проверки"
fi
echo ""

echo "Проверка балансировщика:"
for i in {1..3}; do
    HOST=$(curl -s http://$ALB_IP/ | grep -o "Host: [^<]*" | head -1)
    echo "Запрос $i: $HOST"
done
echo ""

echo "Ссылки для доступа:"
echo "Сайт: http://$ALB_IP/"
echo "Zabbix: http://$ZABBIX_IP/"
echo "Kibana: http://$KIBANA_IP:5601"
echo "Bastion: $BASTION_IP"
echo "Elasticsearch: http://$ELASTIC_IP:9200"
