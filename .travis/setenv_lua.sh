export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/luarocks/bin
export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/openresty/nginx/sbin
export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/openresty/bin
bash .travis/setup_lua.sh
if [ "$SERVER" == "openresty" ]; then
	bash .travis/setup_servers.sh
fi

eval `$HOME/.lua/luarocks path`
