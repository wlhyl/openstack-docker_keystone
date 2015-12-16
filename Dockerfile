# image name lzh/keystone:kilo
FROM 10.64.0.50:5000/lzh/openstackbase:kilo

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-07-01
ENV OPENSTACK_VERSION kilo


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install keystone apache2 libapache2-mod-wsgi python-memcache curl -y
RUN apt-get clean

RUN env --unset=DEBIAN_FRONTEND

RUN cp -rp /etc/keystone/ /keystone
RUN rm -rf /etc/keystone/*
RUN rm -rf /var/log/keystone/*

VOLUME ["/etc/keystone"]
VOLUME ["/var/log/keystone"]

RUN sed -i s/Listen/#Listen/g /etc/apache2/ports.conf

RUN rm -rf /etc/apache2/sites-enabled/*
ADD wsgi-keystone.conf  /etc/apache2/sites-available/wsgi-keystone.conf
RUN ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

RUN mkdir -p /var/www/cgi-bin/keystone

RUN curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo \
  | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin

RUN chown -R keystone:keystone /var/www/cgi-bin/keystone
RUN chmod 755 /var/www/cgi-bin/keystone/*

ADD apache2.conf /etc/supervisor/conf.d/apache2.conf

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 5000 35357

ENTRYPOINT ["/usr/bin/entrypoint.sh"]