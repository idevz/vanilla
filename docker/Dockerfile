FROM centos:latest
MAINTAINER zhoujing_k49@163.com zhoujing00k@gmail.com https://hub.docker.com/u/zhoujing/
RUN yum localinstall http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm -y && yum -y install supervisor
RUN yum install -y automake autoconf libtool make gcc wget lua-devel git unzip readline-devel pcre-devel openssl-devel
RUN cd /tmp && wget https://github.com/keplerproject/luarocks/archive/v2.2.2.tar.gz && wget https://openresty.org/download/ngx_openresty-1.9.3.1.tar.gz
RUN cd /tmp && tar zxf v2.2.2.tar.gz && cd luarocks-2.2.2 && ./configure && make build && make install
RUN luarocks install vanilla
RUN cd /tmp && tar zxf ngx_openresty-1.9.3.1.tar.gz && cd ngx_openresty-1.9.3.1 && ./configure && gmake && gmake install && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/bin/nginx
ADD ./supervisord.conf /etc/
RUN cd /tmp && vanilla new vdemo
EXPOSE 9110
RUN cd /tmp/vdemo/ && vanilla start
CMD ["/usr/bin/supervisord"]
