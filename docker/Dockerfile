FROM centos:latest
MAINTAINER zhoujing_k49@163.com zhoujing00k@gmail.com https://hub.docker.com/u/zhoujing/
WORKDIR /tmp
RUN yum localinstall http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm -y && yum -y install supervisor && \
    yum install -y automake autoconf libtool make gcc wget lua-devel git unzip readline-devel pcre-devel openssl-devel && \
    wget https://github.com/keplerproject/luarocks/archive/v2.2.2.tar.gz && wget https://openresty.org/download/ngx_openresty-1.9.3.1.tar.gz && \
    tar zxf v2.2.2.tar.gz && cd luarocks-2.2.2 && ./configure && make build && make install && cd .. && \
    luarocks install vanilla && \
    tar zxf ngx_openresty-1.9.3.1.tar.gz && cd ngx_openresty-1.9.3.1 && ./configure && gmake && gmake install && cd .. && \
    ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/bin/nginx 
ADD ./supervisord.conf /etc/
EXPOSE 9110
CMD ["/usr/bin/supervisord"]
