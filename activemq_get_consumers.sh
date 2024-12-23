#!/bin/bash

# Set ActiveMQ broker details and credentials
AMQ_BROKER_NAME="localhost"
AMQ_USERNAME="zabbix"
AMQ_PASSWORD="password"

# Fetch the queue data from ActiveMQ using curl
queues_json=$(curl -s -u "$AMQ_USERNAME:$AMQ_PASSWORD" -H "Origin: http://localhost" "http://localhost:8161/api/jolokia/read/org.apache.activemq:type=Broker,brokerName=$AMQ_BROKER_NAME,destinationType=Queue,*")

# Extract the consumers for the specified queue from the arguments
consumers=$(echo "$queues_json" | jq -r --arg QUEUE_NAME "$1" '.value | to_entries[] | select(.value.Name == $QUEUE_NAME) | .value.ConsumerCount')

# Output the consumers (numeric value)
echo "$consumers"