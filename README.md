## Дипломная работа по профессии «Системный администратор»-Коноплёв александр SYS-46

## Задача

Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в Yandex Cloud и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте инструкцию.


## Инфраструктура

Для развёртывания инфраструктуры используем Terraform, для установки ПО используем Ansibl. После успешного запуска и установки мы имеем 6 ВМ, 2 Web сервера без публичного IP расположенные в разных зонах, Elastic также без публичного IP, Kibana, Zabbix, Bastion с публичными IP. После установки проверяем наличие всех необходимых ВМ. После чего переходим к установке ПО при помощи Ansible.

Проверяем созданные ВМ и  соответствие IP адресов.

Разворачиваем Terraform (скриншот 1)

<img width="624" height="171" alt="Терраформ скрин 1" src="https://github.com/user-attachments/assets/1689ed88-f1f6-4868-b08f-7376a2b4803d" />

Структура проекта после успешной установки (скриншот 2-4)
<img width="1793" height="565" alt="Терраформ 2" src="https://github.com/user-attachments/assets/fd7f1303-bfaa-4f10-a8a5-1f454fc49f29" />

<img width="994" height="326" alt="Терраформ 3" src="https://github.com/user-attachments/assets/06de0ef4-f646-4928-a258-2b83b3712c32" />

<img width="1057" height="354" alt="Терраформ 4" src="https://github.com/user-attachments/assets/4d9b5a75-5fe3-4e56-9829-bf8b87bedae5" />

Разворачиваем ПО при помощи Ansible (криншот 5)

<img width="960" height="776" alt="Ансибл" src="https://github.com/user-attachments/assets/82fe4694-db32-4e09-abd1-92a87ebcd54c" />


## Сайт 

Поле этого создаём сайт, настраиваем балансировщик и проверяем работоспособность.

Создаём сайт (скриншот 6-7)

<img width="743" height="600" alt="Сайт 1" src="https://github.com/user-attachments/assets/f44ef103-fc65-4e2f-aeaf-fa39e96cde9d" />

<img width="1919" height="829" alt="Сайт 2" src="https://github.com/user-attachments/assets/f8c70125-a685-40c9-9e18-654f8a198956" />

Устанавливаем балансировщик (скриншот 8)

<img width="676" height="152" alt="Сайт балансировщик" src="https://github.com/user-attachments/assets/89518f81-1971-4063-8e38-858085ee707b" />

Проверка работоспособности балансировщика с отключением попеременно web 1 и web 2 (скриншот 9)

<img width="620" height="631" alt="Проверка работы балансировщика" src="https://github.com/user-attachments/assets/d4e1f17a-eb12-484b-8c56-b73e3f6f8a64" />

Сайт доступен по адресу: http://130.193.56.231/

## Мониторинг

На созданной ВМ, разворачиваем Zabbix. На каждый Web сервер устанавливаем  Zabbix Agent, настраиваем агенты на отправление метрик в Zabbix.

Настраиваем дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. 

Установка Zabbix и Zabbix agent. Добавляем ВМ для мониторинга в Zabbix(скриншот 10-12)

<img width="1781" height="288" alt="Хосты в заббикс" src="https://github.com/user-attachments/assets/49c884ac-c969-43a1-bf39-d3629fe80034" />

<img width="950" height="428" alt="Заббикс агент 1" src="https://github.com/user-attachments/assets/17762361-2d84-4a04-a0e7-67d688d61e29" />

<img width="930" height="413" alt="Заббикс агент 2" src="https://github.com/user-attachments/assets/2e7b0254-f480-4382-b48d-54b0626c79a2" />

Создаём дашборды мониторинга Zabbix в вебинтерфейсе и настраиваем триггеры (скриншот 13-16)

<img width="1824" height="843" alt="Заббикс мониторинг" src="https://github.com/user-attachments/assets/07868fea-35e4-48de-9a5a-adb40ffce638" />

<img width="1826" height="807" alt="Забикс мониторинг 2" src="https://github.com/user-attachments/assets/5cfd7dc6-fb37-4eb0-9011-f9fa237432a7" />

<img width="1782" height="440" alt="Забикс мониторинг 3" src="https://github.com/user-attachments/assets/7030fce6-7b21-4768-8c9e-8e9a3bc9915a" />

<img width="1630" height="329" alt="Заббикс тригеры" src="https://github.com/user-attachments/assets/56a9ea03-e3b4-47cb-8d7d-565595821ef6" />

Zabbix доступен по ссылке http://158.160.107.7:8080/

Login: Admin

Password: zabbix

## Логи

на 2 ВМ, разворачиваем Elasticsearch и Kibana. Настраиваем мониторинг логов в вебинтерфейсе Kibana. Конфигурируем соединение с Elasticsearch. Устанавливаем Filebeat для отправки access.log, error.log nginx в Elasticsearch.

Установка Elasticsearch (скриншот 17)

<img width="1025" height="451" alt="Установка еластик" src="https://github.com/user-attachments/assets/860ed498-f42a-4dc6-b17d-2ac4aa6eb473" />

Проверка доступности Elasticsearch (скриншот 18-19)

<img width="581" height="456" alt="Еластик веб" src="https://github.com/user-attachments/assets/cca51319-f718-426d-9436-ce7e0947a65e" />

<img width="1236" height="652" alt="Еластик проверка" src="https://github.com/user-attachments/assets/9e6921e1-4164-4395-b68d-39b4ea95b019" />

Установка Kibana (скриншот 20)

<img width="1338" height="629" alt="Кибана проверка" src="https://github.com/user-attachments/assets/78fbbf82-6dda-4737-8dc1-41440e014682" />

Устанавливаем Filebeat для отправки логов и проверяем работоспособность( скриншот 21)

<img width="1326" height="521" alt="Логи филбит веб1" src="https://github.com/user-attachments/assets/c677b339-c739-422a-ab15-ef2052440540" />

<img width="1340" height="600" alt="ЛОГИ филбит веб2" src="https://github.com/user-attachments/assets/a7f570a2-f7ba-44b9-b96b-a230822f6818" />

Проверка сбора логов Kibana (скриншот 22-23)

<img width="1653" height="795" alt="Кибана Логи" src="https://github.com/user-attachments/assets/805462ee-d370-42b0-b301-2446725a7b07" />

<img width="1648" height="838" alt="Логи Кибана" src="https://github.com/user-attachments/assets/a602971b-14d6-410f-a147-67ee029d92ba" />

Elastic доступен по адресу: http://localhost:9200/

Kibana доступна по адресу: http://158.160.34.63:5601/

## Резервное копирование

Приступаем к настройке резервного капирования, snapshot дисков всех ВМ. Ограничеваем время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование в 2 часа ночи.

Снапшоты (скриншот 24-25)

<img width="1441" height="313" alt="Снапшоты в облаке" src="https://github.com/user-attachments/assets/783641a0-8721-430e-8576-c7fedb61884a" />

<img width="1053" height="714" alt="Снапшот диски" src="https://github.com/user-attachments/assets/bf109565-d038-4846-956c-ab95704ae60a" />

Расписание снапшотов (скриншот 26)

<img width="1266" height="447" alt="Снапшот расписание" src="https://github.com/user-attachments/assets/258e4176-6863-4124-85d0-8ed363696a9c" />



## Этот проект создан в рамках образовательной программы Нетология.



