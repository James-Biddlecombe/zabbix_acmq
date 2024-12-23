#!/bin/bash

# Set ActiveMQ broker details and credentials
AMQ_BROKER_NAME="localhost"
AMQ_USERNAME="zabbix"
AMQ_PASSWORD="password"

# Fetch the queue data from ActiveMQ using curl
queues_json=$(curl -s -u "$AMQ_USERNAME:$AMQ_PASSWORD" -H "Origin: http://localhost" "http://localhost:8161/api/jolokia/read/org.apache.activemq:type=Broker,brokerName=$AMQ_BROKER_NAME,destinationType=Queue,*")

# Format JSON output for Zabbix LLD
discovery_data=$(echo "$queues_json" | jq -r '
{
    "data": [
        .value | to_entries[] | select(.value.Name != null) |
        {
            "name": .value.Name
        }
    ]
}')

# Output JSON discovery data for Zabbix
echo "$discovery_data"
