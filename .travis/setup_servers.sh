#! /bin/bash

# A script for setting up environment for travis-ci testing.
# Sets up openresty.
OPENRESTY_VERSION="1.9.3.1"
VANILLA_VERSION="0_1_0_rc5"
OPENRESTY_DIR=$TRAVIS_BUILD_DIR/install/openresty
VANILLA_ROOT=$TRAVIS_BUILD_DIR/install/vanilla

#if [ "$LUA" == "lua5.1" ]; then
#	luarocks install LuaBitOp
#fi

wget https://openresty.org/download/ngx_openresty-$OPENRESTY_VERSION.tar.gz
tar xzvf ngx_openresty-$OPENRESTY_VERSION.tar.gz
cd ngx_openresty-$OPENRESTY_VERSION/

./configure --prefix="$OPENRESTY_DIR" --with-luajit

make
make install

ln -s $OPENRESTY_DIR/bin/resty $HOME/.lua/resty
ln -s $OPENRESTY_DIR/nginx/sbin/nginx $HOME/.lua/nginx

export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/openresty/nginx/sbin
export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/openresty/bin

nginx -v 
resty -V 

cd ../
rm -rf ngx_openresty-$OPENRESTY_VERSION
cd $TRAVIS_BUILD_DIR

./configure --prefix=$VANILLA_ROOT --openresty-path=$OPENRESTY_DIR --vanilla-bin-path=$HOME/.lua/

make install

ln -s $VANILLA_ROOT/$VANILLA_VERSION/vanilla/resty ./vanilla/resty
