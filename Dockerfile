FROM centos:latest
MAINTAINER zhoujing@docker.com
RUN yum install -y wget
RUN cd /tmp && wget http://www.lua.org/ftp/lua-5.1.5.tar.gz && wget https://github.com/keplerproject/luarocks/archive/v2.2.2.tar.gz
RUN tar zxf lua-5.1.5.tar.gz && cd lua-5.1.5 &&