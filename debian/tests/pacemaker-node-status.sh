#!/bin/sh

set -ex

DAEMON_TIMEOUT=60
CRM_TIMEOUT=5
NODE=$(hostname)

#
# daemons start
#

service corosync start
service pacemaker start
sleep $DAEMON_TIMEOUT

#
# online
#

crm status | grep "^Online:.*$NODE"

#
# standby
#

crm node standby
sleep $CRM_TIMEOUT
crm status | grep "^Node $NODE: standby"

crm node online
sleep $CRM_TIMEOUT
crm status | grep "^Online:.*$NODE"

#
# maintenance
#

crm node maintenance
sleep $CRM_TIMEOUT
crm status | grep "^Node $NODE: maintenance"

crm node ready
sleep $CRM_TIMEOUT
crm status | grep "^Online:.*$NODE"

#
# attributes
#

crm node attribute $NODE set memory_size 1024
crm node attribute $NODE show memory_size | grep 1024
crm node utilization $NODE set memory 2048
crm node utilization $NODE show memory | grep 2048
crm node server
crm node show
crm node status

: INFO all tests OK
exit 0
