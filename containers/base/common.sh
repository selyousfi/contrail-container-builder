#!/bin/bash

source /functions.sh

DEFAULT_IFACE=`ip -4 route list 0/0 | awk '{ print $5; exit }'`
DEFAULT_LOCAL_IP=`ip addr | grep $DEFAULT_IFACE | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1`

CONTROLLER_NODES=${CONTROLLER_NODES:-${DEFAULT_LOCAL_IP}}
CONFIG_NODES=${CONFIG_NODES:-${CONTROLLER_NODES}}
RABBITMQ_NODES=${RABBITMQ_NODES:-${CONFIG_NODES}}
CONFIGDB_NODES=${CONFIGDB_NODES:-${CONFIG_NODES}}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONFIG_NODES}}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
REDIS_NODES=${REDIS_NODES:-${ANALYTICS_NODES}}
ANALYTICSDB_NODES=${ANALYTICSDB_NODES:-${ANALYTICS_NODES}}
KAFKA_NODES=${KAFKA_NODES:-${ANALYTICSDB_NODES}}

CONTROL_INTROSPECT_PORT=${CONTROL_INTROSPECT_PORT:-8083}
BGP_PORT=${BGP_PORT:-179}
XMPP_SERVER_PORT=${XMPP_SERVER_PORT:-5269}
DNS_SERVER_PORT=${DNS_SERVER_PORT:-53}
DNS_INTROSPECT_PORT=${DNS_INTROSPECT_PORT:-8092}
CONFIG_API_PORT=${CONFIG_API_PORT:-8082}
CONFIG_API_INTROSPECT_PORT=${CONFIG_API_INTROSPECT_PORT:-8084}
RABBITMQ_PORT=${RABBITMQ_PORT:-5672}
CONFIGDB_PORT=${CONFIGDB_PORT:-9161}
CONFIGDB_CQL_PORT=${CONFIGDB_CQL_PORT:-9041}
ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
WEBUI_JOB_SERVER_PORT=${WEBUI_JOB_SERVER_PORT:-3000}
KUE_UI_PORT=${KUE_UI_PORT:-3002}
WEBUI_HTTP_LISTEN_PORT=${WEBUI_HTTP_LISTEN_PORT:-8180}
WEBUI_HTTPS_LISTEN_PORT=${WEBUI_HTTPS_LISTEN_PORT:-8143}
ANALYTICS_API_PORT=${ANALYTCS_API_PORT:-8081}
ANALYTICS_API_INTROSPECT_PORT=${ANALYTICS_API_INTROSPECT_PORT:-8090}
COLLECTOR_PORT=${COLLECTOR_PORT:-8086}
COLLECTOR_INTROSPECT_PORT=${COLLECTOR_INTROSPECT_PORT:-8089}
COLLECTOR_SYSLOG_PORT=${COLLECTOR_SYSLOG_PORT:-514}
COLLECTOR_SFLOW_PORT=${COLLECTOR_SFLOW_PORT:-6343}
COLLECTOR_IPFIX_PORT=${COLLECTOR_IPFIX_PORT:-4739}
COLLECTOR_PROTOBUF_PORT=${COLLECTOR_PROTOBUF_PORT:-3333}
COLLECTOR_STRUCTURED_SYSLOG_PORT=${COLLECTOR_STRUCTURED_SYSLOG_PORT:-3514}
ALARMGEN_INTROSPECT_PORT=${ALARMGEN_INTROSPECT_PORT:-5995}
QUERYENGINE_INTROSPECT_PORT=${QUERYENGINE_INTROSPECT_PORT:-8091}
SNMPCOLLECTOR_INTROSPECT_PORT=${SNMPCOLLECTOR_INTROSPECT_PORT:-5920}
TOPOLOGY_INTROSPECT_PORT=${TOPOLOGY_INTROSPECT_PORT:-5921}
REDIS_SERVER_PORT=${REDIS_SERVER_PORT:-6379}
ANALYTICSDB_PORT=${ANALYTICSDB_PORT:-9160}
ANALYTICSDB_CQL_PORT=${ANALYTICSDB_CQL_PORT:-9042}
KAFKA_PORT=${KAFKA_PORT:-9092}

CONFIG_SERVERS=${CONFIG_SERVERS:-`get_server_list CONFIG ":$CONFIG_API_PORT "`}
CONFIGDB_SERVERS=${CONFIGDB_SERVERS:-`get_server_list CONFIGDB ":$CONFIGDB_PORT "`}
CONFIGDB_CQL_SERVERS=${CONFIGDB_CQL_SERVERS:-`get_server_list CONFIGDB ":$CONFIGDB_CQL_PORT "`}
ZOOKEEPER_SERVERS=${ZOOKEEPER_SERVERS:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT,"`}
RABBITMQ_SERVERS=${RABBITMQ_SERVERS:-`get_server_list RABBITMQ ":$RABBITMQ_PORT,"`}
ANALYTICS_SERVERS=${ANALYTICS_SERVERS:-`get_server_list ANALYTICS ":$ANALYTICS_API_PORT "`}
COLLECTOR_SERVERS=${COLLECTOR_SERVERS:-`get_server_list ANALYTICS ":$COLLECTOR_PORT "`}
REDIS_SERVERS=${REDIS_SERVERS:-`get_server_list REDIS ":$REDIS_SERVER_PORT "`}
ANALYTICSDB_SERVERS=${ANALYTICSDB_SERVERS:-`get_server_list ANALYTICSDB ":$ANALYTICSDB_PORT "`}
ANALYTICSDB_CQL_SERVERS=${ANALYTICSDB_CQL_SERVERS:-`get_server_list ANALYTICSDB ":$ANALYTICSDB_CQL_PORT "`}
KAFKA_SERVERS=${KAFKA_SERVERS:-`get_server_list KAFKA ":$KAFKA_PORT "`}

RABBITMQ_VHOST=${RABBITMQ_VHOST:-/}
RABBITMQ_USER=${RABBITMQ_USER:-guest}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-guest}
RABBITMQ_USE_SSL=${RABBITMQ_USE_SSL:-False}

REDIS_SERVER_IP=${REDIS_SERVER_IP:-127.0.0.1}
REDIS_SERVER_PASSWORD=${REDIS_SERVER_PASSWORD:-""}

LOG_DIR=${LOG_DIR:-"/var/log/contrail"}
LOG_LEVEL=${LOG_LEVEL:-SYS_NOTICE}
LOG_LOCAL=${LOG_LOCAL:-1}

BGP_ASN=64512

CONFIG_API_AUTH=${CONFIG_API_AUTH:-noauth}
ADMIN_TENANT=${ADMIN_TENANT:-admin}
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-contrail123}
AUTH_PROJECT_DOMAIN_NAME=${AUTH_PROJECT_DOMAIN_NAME:-Default}
AUTH_USER_DOMAIN_NAME=${AUTH_USER_DOMAIN_NAME:-Default}
AUTH_URL_VERSION=${AUTH_URL_VERSION:-'/v2.0'}
AUTH_URL_TOKENS=${AUTH_URL_TOKENS:-'/v2.0/tokens'}


RNDC_KEY="xvysmOR8lnUQRBcunkC6vg=="

read -r -d '' sandesh_client_config << EOM
[SANDESH]
sandesh_ssl_enable=${SANDESH_SSL_ENABLE:-False}
introspect_ssl_enable=${INTROSPECT_SSL_ENABLE:-False}
sandesh_keyfile=${SANDESH_KEYFILE:-/etc/contrail/ssl/private/server-privkey.pem}
sandesh_certfile=${SANDESH_CERTFILE:-/etc/contrail/ssl/certs/server.pem}
sandesh_ca_cert=${SANDESH_CA_CERT:-/etc/contrail/ssl/certs/ca-cert.pem}
EOM


function set_third_party_auth_config(){
  if [[ $CONFIG_API_AUTH == "keystone" ]]; then
    cat > /etc/contrail/contrail-keystone-auth.conf << EOM
[KEYSTONE]
#memcache_servers=127.0.0.1:11211
admin_password = $ADMIN_PASSWORD
admin_tenant_name = $ADMIN_TENANT
admin_user = $ADMIN_USER
auth_host = $CONFIG_AUTHN_SERVER
auth_port = 35357
auth_protocol = http
insecure = false
auth_url = http://${CONFIG_AUTHN_SERVER}:35357${AUTH_URL_VERSION}
auth_type = password
EOM
    if [[ "$AUTH_URL_VERSION" == '/v3' ]] ; then
      cat >> /etc/contrail/contrail-keystone-auth.conf << EOM
user_domain_name = $AUTH_USER_DOMAIN_NAME
project_domain_name = $AUTH_PROJECT_DOMAIN_NAME
EOM
    fi
  fi
}

function set_vnc_api_lib_ini(){
# TODO: set WEB_SERVER to VIP
  cat > /etc/contrail/vnc_api_lib.ini << EOM
[global]
;WEB_SERVER = 127.0.0.1
;WEB_PORT = 9696  ; connection through quantum plugin

WEB_SERVER = $CONFIG_NODES
WEB_PORT = ${CONFIG_API_PORT:-8082}
BASE_URL = /
;BASE_URL = /tenants/infra ; common-prefix for all URLs
EOM

  if [[ $CONFIG_API_AUTH == "keystone" ]]; then
    cat >> /etc/contrail/vnc_api_lib.ini << EOM

; Authentication settings (optional)
[auth]
AUTHN_TYPE = keystone
AUTHN_PROTOCOL = http
AUTHN_SERVER = $CONFIG_AUTHN_SERVER
AUTHN_PORT = 35357
AUTHN_URL = $AUTH_URL_TOKENS
AUTHN_DOMAIN = $AUTH_PROJECT_DOMAIN_NAME
;AUTHN_TOKEN_URL = http://127.0.0.1:35357/v2.0/tokens
EOM
  else
    cat >> /etc/contrail/vnc_api_lib.ini << EOM
[auth]
AUTHN_TYPE = noauth
EOM
  fi
}
