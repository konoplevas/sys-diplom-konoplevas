## Дипломная работа по профессии «Системный администратор»-Коноплёв александр SYS-46

## Задача

Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в Yandex Cloud и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте инструкцию.

Перед началом работы над дипломным заданием изучите Инструкция по экономии облачных ресурсов.

## Инфраструктура

Для развёртывания инфраструктуры используем Terraform, для установки ПО используем Ansibl. После успешного запуска и установки мы имеем 6 ВМ, 2 Web сервера без публичного IP расположенные в разных зонах, Elastic также без публичного IP, Kibana, Zabbix, Bastion с публичными IP. После установки проверяем наличие всех необходимых ВМ. После чего переходим к установке ПО при помощи Ansible.

Проверяем созданные ВМ и  соответствие IP адресов.

Разворачиваем Terraform (скриншот 1)

<img width="493" height="222" alt="Разворачиваем терраформ" src="https://github.com/user-attachments/assets/423e21fa-3830-4f4d-b4ac-50fb8f734fcb" />

Структура проекта после успешной установки (скриншот 2-3)

<img width="1793" height="565" alt="Структура проекта" src="https://github.com/user-attachments/assets/a2fb4708-aa9f-441b-a125-f2c14f4007c9" />

<img width="1020" height="567" alt="Группа безопасностис" src="https://github.com/user-attachments/assets/287b4a81-6d58-4f6e-a170-78493a1cfab8" />

## Сайт

Поле этого создаём сайт, настраиваем балансировщик и проверяем работоспособность.

Создаём сайт (скриншот 4)

<img width="797" height="227" alt="Сайт создание" src="https://github.com/user-attachments/assets/c4da184b-fb88-4079-b981-ceec6bfc1f8b" />

Устанавливаем балансировщик (скриншот 5)

<img width="726" height="142" alt="устанавливаем балансировщик" src="https://github.com/user-attachments/assets/1ce19fbb-877e-4925-8d6e-4f78818269c0" />

Проверка работоспособности балансировщика (скриншот 6-8)

<img width="1919" height="829" alt="Сайт балансировщик 1" src="https://github.com/user-attachments/assets/922f0d6a-f7c8-4a3b-9b37-fba9c7550726" />

<img width="1890" height="802" alt="Сайт балансировщик 2" src="https://github.com/user-attachments/assets/e8eb2037-72ea-421b-a2a3-6464742f756d" />

<img width="866" height="271" alt="Балансировщик распределение нагрузки" src="https://github.com/user-attachments/assets/ce7a54cb-141d-45a3-adb0-446f9c940c9c" />

Сайт доступен по адресу: http://130.193.56.231/

## Мониторинг

На созданной ВМ, разворачиваем Zabbix. На каждый Web сервер устанавливаем  Zabbix Agent, настраиваем агенты на отправление метрик в Zabbix.

Настраиваем дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. 

Установка Zabbix (скриншот 9)

<img width="1314" height="222" alt="Ансибал установка заббикс" src="https://github.com/user-attachments/assets/b3a6d863-701d-4eb6-b7eb-cb9fb5fab1f5" />

Установка Zabbix agent на сервера (скриншот 10)

<img width="1325" height="775" alt="Установка заббикс агентов на сервера" src="https://github.com/user-attachments/assets/98a5dff5-69c2-42ab-9dd1-6da6e89f5f8f" />

Дашборды мониторинга Zabbix в вебинтерфейсе (скриншот 11-13)

<img width="1918" height="842" alt="Мониторинг заббикс" src="https://github.com/user-attachments/assets/331f15e0-6ddb-47f0-a59e-eb814b8578a1" />

<img width="1896" height="445" alt="Мониторинг заббикс 2" src="https://github.com/user-attachments/assets/17be7d75-3e3c-488d-9a51-2f11d5ab182f" />

<img width="1916" height="823" alt="Мониторинг Zabbix" src="https://github.com/user-attachments/assets/ceb4c3b8-422d-4ef0-ac58-cfd96471109c" />

Zabbix доступен по ссылке http://158.160.107.7:8080/zabbix.php?action=dashboard.view

Login: Admin
Password: zabbix

## Логи

на 2 ВМ, разворачиваем Elasticsearch и Kibana. Используем bastion host как jump server. Конфигурируем соединение с Elasticsearch. Так как установить filebeat и другие аналогичные программы установить не удалось, изз-за блокировки на территории РФ, на ВМ к веб-серверам был установлен скрипт для отправки access.log, error.log nginx в Elasticsearch.

Установка Elasticsearch (скриншот 14)

<img width="599" height="414" alt="Установка Еластик" src="https://github.com/user-attachments/assets/584ee9cb-53f0-4e86-80ad-190ec1927b30" />

Проверка доступности Elasticsearch (скриншот 15)

<img width="930" height="444" alt="Эластик веб" src="https://github.com/user-attachments/assets/f12bc3bc-e965-4d80-8a9c-41846b20b343" />

Установка Kibana (скриншот 15)

<img width="1092" height="133" alt="установка кибана" src="https://github.com/user-attachments/assets/f1c62022-7d7d-4cf2-ad14-236c4e01c372" />

Проверка сбора логов (скриншот 16)

<img width="1326" height="229" alt="Эластик сбор логов работает" src="https://github.com/user-attachments/assets/dfd20931-63c9-4ae2-9636-4b9699f5d2d6" />

Мониторинг Kibana (скриншот 17-18)

<img width="1707" height="803" alt="Кибана мониторинг" src="https://github.com/user-attachments/assets/bae506c1-359f-43d9-acfb-066dfe699a22" />

<img width="1916" height="805" alt="Кибана логи" src="https://github.com/user-attachments/assets/a7dbae48-e39c-472c-9e23-00673c22ea41" />

Elastic доступен в вебинтерфейсе: http://localhost:9200/

Kibana выход в веб интерфейс осуществляется при помощи проброса порта, доступна по адресу: http://158.160.34.63:5601/

## Резервное копирование

Приступаем к настройке резервного капирования, snapshot дисков всех ВМ. Ограничеваем время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование в 2 часа ночи.

Снапшоты установка (скриншот 19)

<img width="920" height="362" alt="Снапшоты установка и работа" src="https://github.com/user-attachments/assets/9cc84854-5c17-4cfc-b5ec-597d9bca4820" />

Расписание снапшотов (скриншот 20)
 <img width="791" height="257" alt="Расписание снапшотов" src="https://github.com/user-attachments/assets/8606c149-1333-4fab-8418-3e1885499765" />
 Проверка работоспособности снапшотов (скриншот 21)
<img width="1881" height="789" alt="Снапшоты резервное копирование" src="https://github.com/user-attachments/assets/92b1ebe0-8fc7-4db2-afae-b82e6db1f777" />


## Этот проект создан в рамках образовательной программы Нетология.



