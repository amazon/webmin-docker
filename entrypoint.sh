#!/bin/sh

#echo "command line: $*"
#
#echo "iface=$(ip link|grep -o -E 'eth0@[a-z0-9]+')" >>/etc/webmin/virtual-server/config
#echo "defip=$(ip addr|grep eth0|grep -o -E 'inet ([0-9]+\.){3}[0-9]+'|sed 's/^inet //')" >>/etc/webmin/virtual-server/config
#sed -i  "s#^dns_ip=.*#dns_ip=#" /etc/webmin/virtual-server/config || echo "dns_ip=" >> /etc/webmin/virtual-server/config
#
#. /conf/db.env
#if [ -n "${TZ}" ]; then
#  ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && \
#    dpkg-reconfigure --frontend noninteractive tzdata
#fi
#
#if [ "$1" = "import" ]; then
#  echo "begin import"
#  . /conf/import.sh
## . /conf/configure.sh
#  echo "import complete"
#  exit 0
#else
#  echo "execute systemd"
#  exec /lib/systemd/systemd
#fi
exec /lib/systemd/systemd

## rest of this script will never be executed ##
