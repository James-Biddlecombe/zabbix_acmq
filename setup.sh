# on the activemq server, create a zabbix user for the curl queries
vim /home/activemq/activemq/conf/jetty-realm.properties
    zabbix:password, admin

systemctl restart activemq

# log into the activemq as the new user to test and create some queues and messages
queue1 ...
message ... [10, 5, 100]

# copy the activemq scripts onto the server in the activemq dir and set perms
activemq_get_consumers.sh
activemq_get_queue_size.sh
activemq_just_queues.sh

chown activemq:activemq /home/activemq/activemq/activemq_*.sh
chmod +x /home/activemq/activemq/activemq_*.sh
# confirm that the hostname, user and password are correct

#install jq on the server
yum install jq -y

# test that the just queues works
/home/activemq/activemq/activemq_just_queues.sh

# add the userparameters to the zabbix conf file on activemq server for the scripts
vim /etc/zabbix/zabbix_agentd.conf
# add the bottom of the file add the below
### Custom Zabbix activemq stuffs
UserParameter=activemq.queue.size[*],/home/activemq/activemq/activemq_get_queue_size.sh "$1"
UserParameter=activemq.consumers[*],/home/activemq/activemq/activemq_get_consumers.sh "$1"
UserParameter=activemq.queue.names,/home/activemq/activemq/activemq_just_queues.sh

# give the zabbix user access to the scripts
usermod -aG activemq zabbix
chmod 755 /home/activemq/activemq
chmod 750 /home/activemq

# restart the zabbix agent service for the changes to take effect
systemctl restart zabbix-agent.service

# log into the zabbix web UI and go to the Items on the host for activemq.local.lab
# we are going to add some custom discovery rules for the scripts we created
-- Discovery Rule --

a) Discovery Rule
Name: ActiveMQ Queue Discovery
Type: Zabbix Agent
Key: activemq.queue.names
Update Interval: 1m

b) LLD macros
LLD macro: {#QUEUENAME}
JSONPath: $.name

-- Item Prototype 1 --
a) Item Prototype
Name: {#QUEUENAME}
Type: Zabbix Agent
Key: activemq.queue.size[{#QUEUENAME}]

b) Tags
Name: ActiveMQ
Value: Messages

-- Item Prototype 2 --
a) Item Prototype
Name: {#QUEUENAME}
Type: Zabbix Agent
Key: activemq.consumers[{#QUEUENAME}]

b) Tags
Name: ActiveMQ
Value: Consumers

# create the zabbix dashboard with messages and consumers using honeycomb