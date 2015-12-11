.PHONY: all install clean

all:
	cd /Users/zj-git/vanilla/build/luafilesystem-1.6.3 && $(MAKE) DESTDIR=$(DESTDIR) LUA_INC=/usr/local/nginx_x/luajit/include/luajit-2.1 LUA_LIBDIR=/usr/local/zhoujing/vanilla/lualib LUA_CMODULE_DIR=/usr/local/zhoujing/vanilla/lualib LUA_MODULE_DIR=/usr/local/zhoujing/vanilla/lualib LIB_OPTION='-bundle -undefined dynamic_lookup' CC=cc

install: all
	cd /Users/zj-git/vanilla/build/luafilesystem-1.6.3 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_INC=/usr/local/nginx_x/luajit/include/luajit-2.1 LUA_LIBDIR=/usr/local/zhoujing/vanilla/lualib LUA_CMODULE_DIR=/usr/local/zhoujing/vanilla/lualib LUA_MODULE_DIR=/usr/local/zhoujing/vanilla/lualib LIB_OPTION='-bundle -undefined dynamic_lookup' CC=cc
	cd /Users/zj-git/vanilla/build/lua-resty-cookie-0.1.0 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/zhoujing/vanilla INSTALL=/Users/zj-git/vanilla/build/install
	cd /Users/zj-git/vanilla/build/lua-resty-http-0.06 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/zhoujing/vanilla INSTALL=/Users/zj-git/vanilla/build/install
	cd /Users/zj-git/vanilla/build/lua-resty-logger-socket-0.1 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/zhoujing/vanilla INSTALL=/Users/zj-git/vanilla/build/install
	cd /Users/zj-git/vanilla/build/lua-resty-session-2.3 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/zhoujing/vanilla INSTALL=/Users/zj-git/vanilla/build/install
	cd /Users/zj-git/vanilla/build/lua-resty-shcache-0.1.0 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/zhoujing/vanilla INSTALL=/Users/zj-git/vanilla/build/install
	cd /Users/zj-git/vanilla/build/lua-resty-template-1.5 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/zhoujing/vanilla INSTALL=/Users/zj-git/vanilla/build/install
	cd /Users/zj-git/vanilla/build/vanilla && $(MAKE) install DESTDIR=$(DESTDIR) VANILLA_LIB_DIR=/usr/local/zhoujing/vanilla INSTALL=/Users/zj-git/vanilla/build/install

clean:
	rm -rf build
