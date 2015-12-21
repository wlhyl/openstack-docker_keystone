# image name lzh/keystone:kilo
FROM 10.64.0.50:5000/lzh/openstackbase:liberty

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-12-16
ENV OPENSTACK_VERSION liberty

RUN yum update -y
RUN yum install -y openstack-keystone httpd mod_wsgi python-memcached
RUN yum clean all

RUN cp -rp /etc/keystone/ /keystone
RUN rm -rf /etc/keystone/*
RUN rm -rf /var/log/keystone/*

VOLUME ["/etc/keystone"]
VOLUME ["/var/log/keystone"]
VOLUME ["/var/log/httpd"]

RUN sed -i s/^Listen/#Listen/g /etc/httpd/conf/httpd.conf

ADD wsgi-keystone.conf  /etc/httpd/conf.d/wsgi-keystone.conf


ADD httpd.conf /etc/supervisord.d/httpd.conf

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 5000 35357

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
