OPENRESTY_PREFIX=/usr/local/openresty

PREFIX ?=          /usr/local/vanilla
VANILLA_LIB_DIR ?= $(PREFIX)/
INSTALL ?= install
MKDIR ?= mkdir -p
DEV_ROCKS = busted luacov luacov-coveralls luacheck lrexlib-pcre

.PHONY: all test install dev

all: ;

install: all
	# $(INSTALL) -d $(DESTDIR)/$(VANILLA_LIB_DIR)/vanilla/resty/
	# $(INSTALL) ./bin $(DESTDIR)/$(VANILLA_LIB_DIR)/bin
	$(MKDIR) $(DESTDIR)/$(VANILLA_LIB_DIR)/vanilla
	$(INSTALL) ./resty $(DESTDIR)/$(VANILLA_LIB_DIR)/vanilla
	$(INSTALL) ./v $(DESTDIR)/$(VANILLA_LIB_DIR)/vanilla
	$(INSTALL) ./sys $(DESTDIR)/$(VANILLA_LIB_DIR)/vanilla
	$(INSTALL) ./vanilla-$(VANILLA_VERSION) $(VANILLA_BIN_PATH)/vanilla-$(VANILLA_VERSION)
	$(INSTALL) ./v-console-$(VANILLA_VERSION) $(VANILLA_BIN_PATH)/v-console-$(VANILLA_VERSION)

test: all
	PATH=$(OPENRESTY_PREFIX)/nginx/sbin:$$PATH prove -I../test-nginx/lib -r t

dev: install
	@for rock in $(DEV_ROCKS) ; do \
		if ! command -v $$rock &> /dev/null ; then \
      echo $$rock not found, installing via luarocks... ; \
      luarocks install $$rock ; \
    else \
      echo $$rock already installed, skipping ; \
    fi \
	done;
