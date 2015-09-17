#!/bin/bash
#set -e表示一旦脚本中有命令的返回值为非0，则脚本立即退出，后续命令不再执行;
#set -o pipefail表示在管道连接的命令序列中，只要有任何一个命令返回非0值，则整个管道返回非0值，即使最后一个命令返回0.

if [ -z "$KEYSTONE_DBPASS" ];then
  echo "error: KEYSTONE_DBPASS not set"
  exit 1
fi

if [ -z "$KEYSTONE_DB" ];then
  echo "error: KEYSTONE_DB not set"
  exit 1
fi

if [ -z "$MEMCACHE_SERVER" ];then
  echo "error: MEMCACHE_SERVER not set"
  exit 1
fi

CRUDINI='/usr/bin/crudini'

ADMIN_TOKEN=${ADMIN_TOKEN:=`openssl rand -hex 10`}
CONNECTION=mysql://keystone:${KEYSTONE_DBPASS}@${KEYSTONE_DB}/keystone

if [ ! -f /etc/keystone/.complete ];then
    cp -rp /keystone/* /etc/keystone
    touch /var/log/keystone/keystone.log
    chown keystone:keystone /var/log/keystone/keystone.log
    
    $CRUDINI --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
    $CRUDINI --set /etc/keystone/keystone.conf DEFAULT verbose True
    $CRUDINI --set /etc/keystone/keystone.conf database connection $CONNECTION
    $CRUDINI --set /etc/keystone/keystone.conf memcache servers ${MEMCACHE_SERVER}:11211
    $CRUDINI --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
    $CRUDINI --set /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.memcache.Token
    $CRUDINI --set /etc/keystone/keystone.conf revoke driver keystone.contrib.revoke.backends.sql.Revoke
    
    touch /etc/keystone/.complete
fi

chown -R keystone:keystone /var/log/keystone/

# 同步数据库
echo 'select * from user limit 1;' | mysql -h$KEYSTONE_DB  -ukeystone -p$KEYSTONE_DBPASS keystone
if [ $? != 0 ];then
    su -s /bin/sh -c "keystone-manage db_sync" keystone
fi

/usr/bin/supervisord -n