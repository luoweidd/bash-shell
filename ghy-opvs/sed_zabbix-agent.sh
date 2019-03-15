#!/bin/bash

sed 's/Server=127.0.0.1/Server=118.31.10.78/g' /etc/zabbix/zabbix_agentd.conf
sed 's/ServerActive=127.0.0.1/ServerActive=118.31.10.78:10051/g' /etc/zabbix/zabbix_agentd.conf
