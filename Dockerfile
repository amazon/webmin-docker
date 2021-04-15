ARG UBUNTU_RELEASE=20.04
FROM ubuntu:${UBUNTU_RELEASE}

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

ADD https://download.webmin.com/jcameron-key.asc /tmp
RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list \
    && rm /etc/apt/apt.conf.d/docker-gzip-indexes \
    && apt-get -o Acquire::GzipIndexes=false update \
    && apt-get upgrade -y \
    && apt-get install -y \
    python3-pip \
    curl \
    gnupg \
    iproute2 \
    apt-show-versions \
    apt-utils \
    systemd \
    systemd-sysv \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
             /etc/systemd/system/*.wants/* \
             /lib/systemd/system/local-fs.target.wants/* \
             /lib/systemd/system/sockets.target.wants/*udev* \
             /lib/systemd/system/sockets.target.wants/*initctl* \
             /lib/systemd/system/basic.target.wants/* \
             /lib/systemd/system/anaconda.target.wants/* \
             /lib/systemd/system/plymouth* \
             /lib/systemd/system/systemd-update-utmp* \
    && cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
    &&  mkdir -p /etc/webmin \
    && apt-key add /tmp/jcameron-key.asc \
    && echo "deb http://download.webmin.com/download/repository sarge contrib" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
    apache2 \
    apache2-suexec-custom \
    libapache2-mod-php \
    php-gd \
    php-mbstring \
    php-mysql \
    php-fpm \
    php-cgi \
    phpunit \
    composer \
    bind9 \
    postfix \
    proftpd \
    mysql-server \
    dovecot-imapd \
    webmin \
    webalizer \
    logrotate \
    procmail \
    inotify-tools \
    tzdata \
    less \
    vim \
    && a2enmod ssl \
    && a2enmod proxy_fcgi setenvif \
    && a2enmod suexec \
    && a2enmod rewrite \
    && ( which php7.4 && a2enconf php7.4-fpm || a2enconf php7.2-fpm ) \
    && a2enmod cgi \
    && a2enmod actions \
    && curl -O https://download.webmin.com/download/virtualmin/webmin-virtual-server_6.16.gpl_all.deb \
    && touch /etc/network/interfaces \
    && apt install -y ./webmin-virtual-server_6.16.gpl_all.deb \
    && rm -f webmin-virtual-server_6.16.gpl_all.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
RUN  echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && echo "/home\npublic_html" >>/etc/apache2/suexec/www-data \
#   && service mysql start || mysqld --datadir=/var/lib/mysql --user=mysql \
    && find /var/lib/mysql/mysql -exec touch -c -a {} +  && service mysql start \
    && echo "defip=$(ip addr|grep eth0|grep -o -E 'inet ([0-9]+\.){3}[0-9]+'|sed 's/^inet //')" >>/etc/webmin/virtual-server/config \
    && echo "iface=eth0" >>/etc/webmin/virtual-server/config \
    && echo "virtual_alias_maps = hash:/etc/postfix/virtual" >>/etc/postfix/main.cf \
    && echo "mailbox_command = /usr/bin/procmail" >>/etc/postfix/main.cf \
    && echo "wizard_run=1" >>/etc/webmin/virtual-server/config \
    && chown root:root /usr/bin/procmail \
    && chmod 6755 /usr/bin/procmail \
    && echo /bin/false >>/etc/shells \
    && groupadd -g 14 ftp \
    && service webmin start \
    && cd /usr/share/webmin && /usr/share/webmin/changepass.pl /etc/webmin root 123456 \
#   && virtualmin check-config \
    && virtualmin set-global-feature --disable-feature dns --disable-feature mail --disable-feature spam --disable-feature virus \
    && virtualmin set-global-feature --enable-feature ftp --enable-feature mysql \
#   && service mysql stop || killall mysqld || true \
    && service mysql stop \
    && service webmin stop \
    && rm -f /etc/apache2/sites-enabled/000-default.conf \
    && rm -f /etc/apache2/sites-enabled/localhost.conf \
    && echo "setup complete"

EXPOSE 80/tcp
EXPOSE 443/tcp
EXPOSE 10000/tcp

ENTRYPOINT ["/lib/systemd/systemd"]
