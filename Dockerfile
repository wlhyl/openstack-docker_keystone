# image name lzh/keystone:liberty
FROM 10.64.0.50:5000/lzh/openstackbase:liberty

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-01-07
ENV OPENSTACK_VERSION liberty
ENV BUID_VERSION 2015-01-07

RUN yum update -y && \
         yum install -y openstack-keystone httpd mod_wsgi python-memcached && \
         rm -rf /var/cache/yum/*

RUN cp -rp /etc/keystone/ /keystone && \
         rm -rf /etc/keystone/* && \
         rm -rf /var/log/keystone/*

VOLUME ["/etc/keystone"]
VOLUME ["/var/log/keystone"]
VOLUME ["/var/log/httpd"]

RUN sed -i s/^Listen/#Listen/g /etc/httpd/conf/httpd.conf

ADD wsgi-keystone.conf  /etc/httpd/conf.d/wsgi-keystone.conf


ADD httpd.ini /etc/supervisord.d/httpd.ini

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 5000 35357

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
