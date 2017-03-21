-- dep
local sgsub = string.gsub
local pairs = pairs
local os_execute = os.execute
local io_open = io.open
local print = print
local ansicolors = require 'vanilla.v.libs.ansicolors'

-- vanilla
local va_conf = require 'vanilla.sys.config'
local utils = require 'vanilla.v.libs.utils'

local gitignore = [[
# Vanilla
client_body_temp
fastcgi_temp
logs
proxy_temp
tmp
uwsgi_temp

# Compiled Lua sources
luac.out

# luarocks build files
*.src.rock
*.zip
*.tar.gz

# Object files
*.o
*.os
*.ko
*.obj
*.elf

# Precompiled Headers
*.gch
*.pch

# Libraries
*.lib
*.a
*.la
*.lo
*.def
*.exp

# Shared objects (inc. Windows DLLs)
*.dll
*.so
*.so.*
*.dylib

# Executables
*.exe
*.out
*.app
*.i*86
*.x86_64
*.hex
]]


local base_controller = [[
local BaseController = Class('controllers.base')

function BaseController:__construct()
    print_r('----------------BaseController:init----------------')
    local get = self:getRequest():getParams()
    self.d = '----------------base----------------' .. get.act
end

function BaseController:fff()
    self.aaa = 'dddddd'
end

return BaseController
]]


local index_controller = [[
-- local IndexController = Class('controllers.index', LoadApplication('controllers.base'))
-- local IndexController = Class('controllers.index')
local IndexController = {}
local user_service = LoadApplication('models.service.user')
local aa = LoadLibrary('aa')

-- function IndexController:__construct()
-- -- self.parent:__construct()
--     print_r('===============IndexController:init===============')
-- -- --     -- self.aa = aa({info='ppppp'})
-- -- --     -- self.parent:__construct()
--     local get = self:getRequest():getParams()
--     self.d = '===============index===============' .. get.act
-- end

function IndexController:index()
  return 'hello vanilla.'
end

function IndexController:indext()
    -- self.parent:fff()
    -- do return user_service:get() 
    --           .. sprint_r(aa:idevzDobb()) 
    --           .. sprint_r(Registry['v_sysconf']['db.client.read']['port']) 
    --           -- .. sprint_r(self.aa:idevzDobb()) 
    --           -- .. sprint_r(self.parent.aaa) 
    --           .. Registry['APP_NAME']
    --           -- .. self.d
    -- end
    local view = self:getView()
    local p = {}
    p['vanilla'] = 'Welcome To Vanilla...' .. user_service:get()
    p['zhoujing'] = 'Power by Openresty'
    view:assign(p)
    return view:display()
end

function IndexController:buested()
  return 'hello buested.'
end

-- curl http://localhost:9110/get?ok=yes
function IndexController:get()
    local get = self:getRequest():getParams()
    print_r(get)
    do return 'get' end
end

-- curl -X POST http://localhost:9110/post -d '{"ok"="yes"}'
function IndexController:post()
    local _, post = self:getRequest():getParams()
    print_r(post)
    do return 'post' end
end

-- curl -H 'accept: application/vnd.YOUR_APP_NAME.v1.json' http://localhost:9110/api?ok=yes
function IndexController:api_get()
    local api_get = self:getRequest():getParams()
    print_r(api_get)
    do return 'api_get' end
end

return IndexController
]]


local idevz_controller = [[
local IdevzController = {}
local user_service = LoadApplication 'models.service.user'
local bb = LoadLibrary 'bb'

function IdevzController:index()
    -- do return user_service:get() .. sprint_r(bb:idevzDo()) end
    local view = self:getView()
    local p = {}
    p['vanilla'] = 'Welcome To Vanilla...' .. user_service:get()
    p['zhoujing'] = 'Power by Openresty'
    -- view:assign(p)
    do return view:render('index/index.html', p) end
    return view:display()
end

-- curl http://localhost:9110/get?ok=yes
function IdevzController:get()
    local get = self:getRequest():getParams()
    print_r(get)
    do return 'get' end
end

-- curl -X POST http://localhost:9110/post -d '{"ok"="yes"}'
function IdevzController:post()
    local _, post = self:getRequest():getParams()
    print_r(post)
    do return 'post' end
end

-- curl -H 'accept: application/vnd.YOUR_APP_NAME.v1.json' http://localhost:9110/api?ok=yes
function IdevzController:api_get()
    local api_get = self:getRequest():getParams()
    print_r(api_get)
    do return 'api_get' end
end

return IdevzController
]]


local index_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <img src="http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/120d7329960e19cf073f264751e8d959_2043_2241.png">
  <h1><a href = 'https://github.com/idevz/vanilla'>{{vanilla}}</a></h1><h5>{{zhoujing}}</h5>
</body>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-71947507-1', 'auto');
  ga('send', 'pageview');

</script>
</html>
]]


local error_controller = [[
local ErrorController = {}
local ngx_log = ngx.log
local ngx_redirect = ngx.redirect
local os_getenv = os.getenv


function ErrorController:error()
    local env = os_getenv('VA_ENV') or 'development'
    if env == 'development' then
        local view = self:getView()
        view:assign(self.err)
        return view:display()
    else
        local helpers = require 'vanilla.v.libs.utils'
        ngx_log(ngx.ERR, helpers.sprint_r(self.err))
        -- return ngx_redirect("http://sina.cn?vt=4", ngx.HTTP_MOVED_TEMPORARILY)
        return helpers.sprint_r(self.err)
    end
end

return ErrorController
]]


local error_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <h1>{{status}}</h1>
  {% for k, v in pairs(body) do %}
      {% if k == 'message' then %}
      <h4><pre>{{k}}  =>  {{v}}</pre></h4>
      {% else %}
      <h5><pre>{{k}}  :  {{v}}</pre></h5>
      {% end %}
  {% end %}
</body>
</html>
]]


local lib_aa = [[
local LibAa = Class("aa", LoadLibrary('bb'))

function LibAa:idevzDo(params)
    local params = params or { lib_aa = 'idevzDo LibAa'}
    return params
end

function LibAa:__construct( data )
 print_r('===============init==aaa=======' .. data.info)
 -- self.parent:init()
 self.lib = 'LibAa----------------------------aaaa'
end

return LibAa
]]


local lib_bb = [[
local LibBb = Class("bb")

function LibBb:idevzDo(params)
    local params = params or { lib_bb = 'idevzDo LibBb'}
    return params
end

function LibBb:__construct( data )
    print_r('===============init bbb=========')
    self.lib = 'LibBb---------------xxx' .. data.info
    -- self.a = 'ppp'
end

function LibBb:idevzDobb(params)
    local params = params or { lib_bb = 'idevzDo idevzDobb'}
    return params
end

return LibBb
]]


local dao = [[
local TableDao = {}

function TableDao:set(key, value)
    self.__cache[key] = value
    return true
end

function TableDao:new()
    local instance = {
        set = self.set,
        __cache = {}
    }
    setmetatable(instance, TableDao)
    return instance
end

function TableDao:__index(key)
    local out = rawget(rawget(self, '__cache'), key)
    if out then return out else return false end
end
return TableDao
]]


local service = [[
local table_dao = LoadApplication('models.dao.table'):new()
local UserService = {}

function UserService:get()
    table_dao:set('zhou', 'UserService res')
    return table_dao.zhou
end

return UserService
]]


local admin_plugin_tpl = [[
local AdminPlugin = LoadV('vanilla.v.plugin'):new()

function AdminPlugin:routerStartup(request, response)
    print_r('<pre>')
    if request.method == 'GET' then
        print_r('-----------' .. sprint_r(request.headers) .. '----------')
    else
        print_r(request.headers)
    end
end

function AdminPlugin:routerShutdown(request, response)
end

function AdminPlugin:dispatchLoopStartup(request, response)
end

function AdminPlugin:preDispatch(request, response)
end

function AdminPlugin:postDispatch(request, response)
end

function AdminPlugin:dispatchLoopShutdown(request, response)
end

return AdminPlugin
]]


local bootstrap = [[
local simple = LoadV 'vanilla.v.routes.simple'
local restful = LoadV 'vanilla.v.routes.restful'

local Bootstrap = Class('application.bootstrap')

function Bootstrap:initWaf()
    LoadV('vanilla.sys.waf.acc'):check()
end

function Bootstrap:initErrorHandle()
    self.dispatcher:setErrorHandler({controller = 'error', action = 'error'})
end

function Bootstrap:initRoute()
    local router = self.dispatcher:getRouter()
    local simple_route = simple:new(self.dispatcher:getRequest())
    local restful_route = restful:new(self.dispatcher:getRequest())
    router:addRoute(restful_route, true)
    router:addRoute(simple_route)
    -- print_r(router:getRoutes())
end

function Bootstrap:initView()
end

function Bootstrap:initPlugin()
    local admin_plugin = LoadPlugin('admin'):new()
    self.dispatcher:registerPlugin(admin_plugin);
end

function Bootstrap:boot_list()
    return {
        -- Bootstrap.initWaf,
        -- Bootstrap.initErrorHandle,
        -- Bootstrap.initRoute,
        -- Bootstrap.initView,
        -- Bootstrap.initPlugin,
    }
end

function Bootstrap:__construct(dispatcher)
    self.dispatcher = dispatcher
end

return Bootstrap
]]


local application_conf = [[
local APP_ROOT = Registry['APP_ROOT']
local Appconf={}
Appconf.sysconf = {
    'v_resource',
    'cache'
}
Appconf.page_cache = {}
Appconf.page_cache.cache_on = true
-- Appconf.page_cache.cache_handle = 'lru'
Appconf.page_cache.no_cache_cookie = 'va-no-cache'
Appconf.page_cache.no_cache_uris = {
    'uris'
}
Appconf.page_cache.build_cache_key_without_args = {'rd'}
Appconf.vanilla_root = '{{VANILLA_ROOT}}'
Appconf.vanilla_version = '{{VANILLA_VERSION_DIR_STR}}'
Appconf.name = '{{APP_NAME}}'

Appconf.route='vanilla.v.routes.simple'
Appconf.bootstrap='application.bootstrap'

Appconf.app={}
Appconf.app.root=APP_ROOT

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. '/application/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. '/application/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf
]]


local errors_conf = [[
-------------------------------------------------------------------------------------------------------------------
-- Define all of your application errors in here. They should have the format:
--
-- local Errors = {
--     [1000] = { status = 500, message = "Controller Err." },
-- }
--
-- where:
--     '1000'                is the error number that can be raised from controllers with `self:raise_error(1000)
--     'status'  (required)  is the http status code
--     'message' (required)  is the error description
-------------------------------------------------------------------------------------------------------------------

local Errors = {}

return Errors
]]


local waf_conf = [[
local waf_conf = {}
waf_conf.ipBlocklist={"1.0.0.1"}
-- waf_conf.html="<!DOCTYPE html><html><body><h1>Fu*k U...</h1><h4>=======</h4><h5>--K--</h5></body></html>"
return waf_conf
]]


local waf_conf_regs_args = [[
\.\./
\:\$
\$\{
select.+(from|limit)
(?:(union(.*?)select))
having|rongjitest
sleep\((\s*)(\d*)(\s*)\)
benchmark\((.*)\,(.*)\)
base64_decode\(
(?:from\W+information_schema\W)
(?:(?:current_)user|database|schema|connection_id)\s*\(
(?:etc\/\W*passwd)
into(\s+)+(?:dump|out)file\s*
group\s+by.+\(
xwork.MethodAccessor
(?:define|eval|file_get_contents|include|require|require_once|shell_exec|phpinfo|system|passthru|preg_\w+|execute|echo|print|print_r|var_dump|(fp)open|alert|showmodaldialog)\(
xwork\.MethodAccessor
(gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data)\:\/
java\.lang
\$_(GET|post|cookie|files|session|env|phplib|GLOBALS|SERVER)\[
\<(iframe|script|body|img|layer|div|meta|style|base|object|input)
(onmouseover|onerror|onload)\=
]]


local waf_conf_regs_cookie = [[
\.\./
\:\$
\$\{
select.+(from|limit)
(?:(union(.*?)select))
having|rongjitest
sleep\((\s*)(\d*)(\s*)\)
benchmark\((.*)\,(.*)\)
base64_decode\(
(?:from\W+information_schema\W)
(?:(?:current_)user|database|schema|connection_id)\s*\(
(?:etc\/\W*passwd)
into(\s+)+(?:dump|out)file\s*
group\s+by.+\(
xwork.MethodAccessor
(?:define|eval|file_get_contents|include|require|require_once|shell_exec|phpinfo|system|passthru|preg_\w+|execute|echo|print|print_r|var_dump|(fp)open|alert|showmodaldialog)\(
xwork\.MethodAccessor
(gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data)\:\/
java\.lang
\$_(GET|post|cookie|files|session|env|phplib|GLOBALS|SERVER)\[
]]


local waf_conf_regs_post = [[
select.+(from|limit)
(?:(union(.*?)select))
having|rongjitest
sleep\((\s*)(\d*)(\s*)\)
benchmark\((.*)\,(.*)\)
base64_decode\(
(?:from\W+information_schema\W)
(?:(?:current_)user|database|schema|connection_id)\s*\(
(?:etc\/\W*passwd)
into(\s+)+(?:dump|out)file\s*
group\s+by.+\(
xwork.MethodAccessor
(?:define|eval|file_get_contents|include|require|require_once|shell_exec|phpinfo|system|passthru|preg_\w+|execute|echo|print|print_r|var_dump|(fp)open|alert|showmodaldialog)\(
xwork\.MethodAccessor
(gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data)\:\/
java\.lang
\$_(GET|post|cookie|files|session|env|phplib|GLOBALS|SERVER)\[
\<(iframe|script|body|img|layer|div|meta|style|base|object|input)
(onmouseover|onerror|onload)\=
]]


local waf_conf_regs_url = [[
\.(svn|htaccess|bash_history)
\.(bak|inc|old|mdb|sql|backup|java|class)$
(vhost|bbs|host|wwwroot|www|site|root|hytop|flashfxp).*\.rar
(phpmyadmin|jmx-console|jmxinvokerservlet)
java\.lang
/(attachments|upimg|images|css|uploadfiles|html|uploads|templets|static|template|data|inc|forumdata|upload|includes|cache|avatar)/(\\w+).(php|jsp)
]]


local waf_conf_regs_ua = [[
(HTTrack|harvest|audit|dirbuster|pangolin|nmap|sqln|-scan|hydra|Parser|libwww|BBBike|sqlmap|w3af|owasp|Nikto|fimap|havij|PycURL|zmeu|BabyKrokodil|netsparker|httperf|bench| SF/)
]]


local waf_conf_regs_whiteurl = [[
^/123/$
]]


local va_nginx_config_tpl = [[
#user zhoujing staff;

worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type text/html;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile           on;
    tcp_nopush         on;
    tcp_nodelay        on;

    keepalive_timeout  60;

    gzip               on;
    gzip_vary          on;

    gzip_comp_level    6;
    gzip_buffers       16 8k;

    gzip_min_length    1000;
    gzip_proxied       any;
    gzip_disable       "msie6";

    gzip_http_version  1.0;

    gzip_types         text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript image/svg+xml;

    lua_package_path "/?.lua;/?/init.lua;{{VANILLA_ROOT}}/?.lua;{{VANILLA_ROOT}}/?/init.lua;;";
    lua_package_cpath "/?.so;{{VANILLA_ROOT}}/?.so;;";
    #init_by_lua_file {{VANILLA_ROOT}}/init.lua;
    init_worker_by_lua_file {{VANILLA_ROOT}}/init.lua;
    include vhost/*.conf;
}
]]


local va_nginx_dev_config_tpl = [[
#user zhoujing staff;

worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type text/html;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile           on;
    tcp_nopush         on;
    tcp_nodelay        on;

    keepalive_timeout  60;

    gzip               on;
    gzip_vary          on;

    gzip_comp_level    6;
    gzip_buffers       16 8k;

    gzip_min_length    1000;
    gzip_proxied       any;
    gzip_disable       "msie6";

    gzip_http_version  1.0;

    gzip_types         text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript image/svg+xml;

    lua_package_path "/?.lua;/?/init.lua;{{VANILLA_ROOT}}/?.lua;{{VANILLA_ROOT}}/?/init.lua;;";
    lua_package_cpath "/?.so;{{VANILLA_ROOT}}/?.so;;";
    init_by_lua_file {{VANILLA_ROOT}}/init.lua;
    #init_worker_by_lua_file {{VANILLA_ROOT}}/init.lua;
    include dev_vhost/*.conf;
}
]]


local nginx_vhost_config_tpl = [[
lua_shared_dict idevz 20m;

server {
    server_name {{APP_NAME}}.idevz.com 127.0.0.1;
    lua_code_cache on;
    root {{APP_ROOT}};
    listen 80;
    set $APP_NAME '{{APP_NAME}}';
    set $VANILLA_VERSION '{{VANILLA_VERSION_DIR_STR}}';
    set $VANILLA_ROOT '{{VANILLA_ROOT}}';
    set $template_root '';
    set $va_cache_status '';

    location /static {
        access_log  off;
        alias {{APP_ROOT}}/pub/static;
        expires     max;
    }

    location = /favicon.ico {
        access_log  off;
        root {{APP_ROOT}}/pub/;
        expires     max;
    }

    # Access log with buffer, or disable it completetely if unneeded
    access_log logs/vanilla-access.log combined buffer=16k;
    # access_log off;

    # Error log
    error_log logs/vanilla-error.log debug;

    # Va runtime
    location / {
        content_by_lua_file $document_root/pub/index.lua;
    }
}
]]


local dev_nginx_vhost_config_tpl = [[
lua_shared_dict idevz 20m;

server {
    server_name {{APP_NAME}}.idevz.com 127.0.0.1;
    lua_code_cache off;
    root {{APP_ROOT}};
    listen 9110;
    set $APP_NAME '{{APP_NAME}}';
    set $VANILLA_VERSION '{{VANILLA_VERSION_DIR_STR}}';
    set $VANILLA_ROOT '{{VANILLA_ROOT}}';
    set $template_root '';
    set $va_cache_status '';
    set $VA_DEV on;

    location /static {
        access_log  off;
        alias {{APP_ROOT}}/pub/static;
        expires     max;
    }

    location = /favicon.ico {
        access_log  off;
        root {{APP_ROOT}}/pub/;
        expires     max;
    }

    # Access log with buffer, or disable it completetely if unneeded
    access_log logs/vanilla-access.log combined buffer=16k;
    # access_log off;

    # Error log
    error_log logs/vanilla-error.log debug;

    # Va runtime
    location / {
        content_by_lua_file $document_root/pub/index.lua;
    }
}
]]


local service_manage_sh = [[
#!/bin/sh

### BEGIN ###
# Author: idevz
# Since: 2016/03/12
# Description:       Manage a Vanilla App Service
### END ###


OPENRESTY_NGINX_ROOT={{OPENRESTY_NGINX_ROOT}}
NGINX=$OPENRESTY_NGINX_ROOT/sbin/nginx
NGINX_CONF_PATH=$OPENRESTY_NGINX_ROOT/conf
VA_APP_PATH={{VA_APP_PATH}}
VA_APP_NAME=`basename $VA_APP_PATH`
NGINX_CONF_SRC_PATH=$VA_APP_PATH/nginx_conf
TIME_MARK=`date "+%Y_%m_%d_%H_%M_%S"`
NGINX_CONF_SRC_PATH=$VA_APP_PATH/nginx_conf
DESC=va-{{APP_NAME}}-service
DESC=va-ok-service
IS_FORCE=''
PLATFORM=`uname`
ECHO_E=" -e "
[ $PLATFORM = "Darwin" ] && ECHO_E=""

ok()
{
    MSG=$1
    echo $ECHO_E"\033[35m$MSG \033[0m\n"
}

die()
{
    MSG=$1
    echo $ECHO_E"\033[31m$MSG \033[0m\n"; exit $?;
}

if [ -n "$2" -a "$2" = 'dev' ];then
    VA_ENV="development"
    IS_FORCE=$3
    NGINX_CONF=$OPENRESTY_NGINX_ROOT/conf/va-nginx-$VA_ENV.conf
    NGINX_APP_CONF=$OPENRESTY_NGINX_ROOT/conf/dev_vhost/$VA_APP_NAME.conf
    NGINX_CONF_SRC=$NGINX_CONF_SRC_PATH/va-nginx-$VA_ENV.conf
    VA_APP_CONF_SRC=$NGINX_CONF_SRC_PATH/dev_vhost/$VA_APP_NAME.conf
else
    NGINX_CONF=$OPENRESTY_NGINX_ROOT/conf/va-nginx.conf
    NGINX_APP_CONF=$OPENRESTY_NGINX_ROOT/conf/vhost/$VA_APP_NAME.conf
    NGINX_CONF_SRC=$NGINX_CONF_SRC_PATH/va-nginx.conf
    VA_APP_CONF_SRC=$NGINX_CONF_SRC_PATH/vhost/$VA_APP_NAME.conf
    IS_FORCE=$2
    VA_ENV=''
fi

if [ ! -f $NGINX ]; then
    echo $ECHO_E"Didn't Find Nginx sbin."; exit 0
fi

conf_move()
{
    NGINX_CONF_SRC=$1
    NGINX_CONF=$2
    VA_APP_CONF_SRC=$3
    NGINX_APP_CONF=$4
    IS_FORCE=$5
    NGINX_APP_CONF_DIR=`dirname $NGINX_APP_CONF`
    if [ -e "$NGINX_CONF" -a "$IS_FORCE" = "-f" ]; then
        mv -f $NGINX_CONF $NGINX_CONF".old."$TIME_MARK && cp -f $NGINX_CONF_SRC $NGINX_CONF
        echo $ECHO_E"Move And Copy \033[32m" $NGINX_CONF_SRC "\033[0m" to "\033[31m" $NGINX_CONF "\033[m";
    elif [ ! -e "$NGINX_CONF" ]; then
        cp -f $NGINX_CONF_SRC $NGINX_CONF
        echo $ECHO_E"Copy \033[32m" $NGINX_CONF_SRC "\033[0m" to "\033[31m" $NGINX_CONF "\033[m";
    else
        ok $NGINX_CONF" is already exist, Add param '-f' to Force move."
    fi
    if [ -e $NGINX_APP_CONF ]; then
        mv -f $NGINX_APP_CONF $NGINX_APP_CONF".old."$TIME_MARK && cp -f $VA_APP_CONF_SRC $NGINX_APP_CONF
    elif [ ! -d "$NGINX_APP_CONF_DIR" ]; then
        mkdir -p $NGINX_APP_CONF_DIR && cp -f $VA_APP_CONF_SRC $NGINX_APP_CONF
    else
        cp -f $VA_APP_CONF_SRC $NGINX_APP_CONF
    fi 
    echo $ECHO_E"copy \033[32m" $VA_APP_CONF_SRC "\033[0m" to "\033[31m" $NGINX_APP_CONF "\033[m";
    exit 0
}

nginx_conf_test() {
    if $NGINX -t -c $1 >/dev/null 2>&1; then
        return 0
    else
        $NGINX -t -c $1
        return $?
    fi
}

case "$1" in
    start)
        echo $ECHO_E"Starting $DESC: "
        nginx_conf_test $NGINX_CONF
        $NGINX -c $NGINX_CONF || true
        ok "Succ."
        ;;

    stop)
        echo $ECHO_E"Stopping $DESC: "
        $NGINX -c $NGINX_CONF -s stop || true
        ok "Succ."
        ;;

    restart|force-reload)
        echo $ECHO_E"Restarting $DESC: "
        $NGINX -c $NGINX_CONF -s stop || true
        sleep 1
        nginx_conf_test $NGINX_CONF
        $NGINX -c $NGINX_CONF || true
        ok "Succ."
        ;;

    reload)
        echo $ECHO_E"Reloading $DESC configuration: "
        nginx_conf_test $NGINX_CONF
        $NGINX -c $NGINX_CONF -s reload || true
        ok "Succ."
        ;;

    configtest)
        echo $ECHO_E"Testing $DESC configuration: "
        if nginx_conf_test $NGINX_CONF; then
            echo $ECHO_E"Config Test Succ."
        else
            die "Config Test Fail."
        fi
        ;;

    confinit|initconf)
        echo $ECHO_E"Initing $DESC configuration: "
        if conf_move $NGINX_CONF_SRC $NGINX_CONF $VA_APP_CONF_SRC $NGINX_APP_CONF $IS_FORCE; then
            if nginx_conf_test $NGINX_CONF; then
                tree $NGINX_CONF_PATH/vhost
                tree $NGINX_CONF_PATH/dev_vhost
                echo $ECHO_E"Config init Succ."
            fi
            die "Config Test Fail."
        fi
        ;;
    ltpl)
        echo $ECHO_E"Start using lemplate compile TT2 template ..."
        TT2_TEMPLATE_PATH=$VA_APP_PATH/application/views/
            lemplate-{{VANILLA_VERSION}} --compile $TT2_TEMPLATE_PATH/*.html > $TT2_TEMPLATE_PATH/templates.lua
        ;;
    *)
        echo $ECHO_E"Usage: ./va-ok-service {start|stop|restart|reload|force-reload|confinit[-f]|configtest} [dev]" >&2
        exit 1
        ;;
esac

exit 0
]]


local nginx_conf = [[
local ngx_conf = {}

ngx_conf.common = {
    INIT_BY_LUA = 'nginx.init',
    LUA_SHARED_DICT = 'nginx.sh_dict',
    -- LUA_PACKAGE_PATH = '',
    -- LUA_PACKAGE_CPATH = '',
    CONTENT_BY_LUA_FILE = './pub/index.lua'
}

ngx_conf.env = {}
ngx_conf.env.development = {
    LUA_CODE_CACHE = false,
    PORT = 9110
}

ngx_conf.env.test = {
    LUA_CODE_CACHE = true,
    PORT = 9111
}

ngx_conf.env.production = {
    LUA_CODE_CACHE = true,
    PORT = 80
}

return ngx_conf
]]


local restful_route_conf = [[
local restful = {
    v1={},
    v={}
}

restful.v.GET = {
    {pattern = '/get', controller = 'index', action = 'get'},
}

restful.v.POST = {
    {pattern = '/post', controller = 'index', action = 'post'},
}

restful.v1.GET = {
    {pattern = '/api', controller = 'index', action = 'api_get'},
}

return restful
]]


local nginx_init_by_lua_tpl = [[
local init_by_lua = {}
function init_by_lua:run()
    local conf = LoadApplication 'nginx.init.config'
    ngx.zhou = conf
end

return init_by_lua
]]


local nginx_init_config_tpl = [[
local config = LoadApp('config.application')
return config
]]


local vanilla_index = [[
init_vanilla()
page_cache()
--+--------------------------------------------------------------------------------+--


-- if Registry['VA_ENV'] == nil then
    local helpers = LoadV "vanilla.v.libs.utils"
    function sprint_r( ... )
        return helpers.sprint_r(...)
    end

    function lprint_r( ... )
        local rs = sprint_r(...)
        print(rs)
    end

    function print_r( ... )
        local rs = sprint_r(...)
        ngx.say(rs)
    end

    function err_log(msg)
        ngx.log(ngx.ERR, "===zjdebug" .. msg .. "===")
    end
-- end
--+--------------------------------------------------------------------------------+--


Registry['VANILLA_APPLICATION']:new(ngx, Registry['APP_CONF']):bootstrap(Registry['APP_BOOTS']):run()
]]


local vanilla_app_resource = [[
[mc]
conf=127.0.0.1:7348 127.0.0.1:11211

[redis]
conf=127.0.0.1:7348 127.0.0.1:7349

[redisq]
conf=127.0.0.1:7348 127.0.0.1:7349

[db.user.write]
host =127.0.0.1
port =3306
dbname =user.info
user =idevz
passwd =idevz

[db.user.read]
host =127.0.0.1
port =3306
dbname =user.info
user =idevz
passwd =idevz
]]


local index_controller_spec = [[
require 'spec.spec_helper'

describe("PagesController", function()

    describe("#root", function()
        it("responds with a welcome message", function()
            local response = cgi({
                method = 'GET',
                path = "/"
            })
            
            assert.are.same(200, response.status)
            assert.are.same("hello vanilla.", response.body_raw)
        end)
    end)

    describe("#buested", function()
        it("responds with a welcome message for buested", function()
            local response = cgi({
                method = 'GET',
                path = "/index/buested"
            })
            
            assert.are.same(200, response.status)
            assert.are.same("hello buested.", response.body_raw)
        end)
    end)
end)

]]


local spec_helper = [[
package.path = package.path .. ";/?.lua;/?/init.lua;{{VANILLA_ROOT}}/{{VANILLA_VERSION_DIR_STR}}/?.lua;{{VANILLA_ROOT}}/{{VANILLA_VERSION_DIR_STR}}/?/init.lua;;";
package.cpath = package.cpath .. ";/?.so;{{VANILLA_ROOT}}/{{VANILLA_VERSION_DIR_STR}}/?.so;;";

Registry={}
Registry['APP_ROOT'] = '{{APP_ROOT}}'
Registry['APP_NAME'] = '{{APP_NAME}}'

LoadV = function ( ... )
    return require(...)
end

LoadApp = function ( ... )
    return require(Registry['APP_ROOT'] .. '/' .. ...)
end

LoadV 'vanilla.spec.runner'
]]

local sys_cache = [[
[shared_dict]
dict=idevz
exptime=100

[memcached]
instances=127.0.0.1:11211 127.0.0.1:11211
exptime=60
timeout=100
poolsize=100
idletimeout=10000

[redis]
instances=127.0.0.1:6379 127.0.0.1:6379
exptime=60
timeout=100
poolsize=100
idletimeout=10000

[lrucache]
items=200
exptime=60
useffi=false
]]

local sys_v_resource = [[
[mc]
conf=127.0.0.1:7348 127.0.0.1:11211

[redis]
conf=127.0.0.1:7348 127.0.0.1:7349

[redisq]
conf=127.0.0.1:7348 127.0.0.1:7349

[db.user.write]
host =127.0.0.1
port =3306
dbname =user.info
user =idevz
passwd =idevz

[db.user.read]
host =127.0.0.1
port =3306
dbname =user.info
user =idevz
passwd =idevz
]]


local VaApplication = {}

VaApplication.files = {
    ['.gitignore'] = gitignore,
    ['application/controllers/base.lua'] = base_controller,
    ['application/controllers/index.lua'] = index_controller,
    ['application/controllers/idevz.lua'] = idevz_controller,
    ['application/controllers/error.lua'] = error_controller,
    ['application/library/aa.lua'] = lib_aa,
    ['application/library/bb.lua'] = lib_bb,
    ['application/models/dao/table.lua'] = dao,
    ['application/models/service/user.lua'] = service,
    ['application/plugins/admin.lua'] = admin_plugin_tpl,
    ['application/views/index-index.html'] = index_tpl,
    ['application/views/error-error.html'] = error_tpl,
    ['application/bootstrap.lua'] = bootstrap,
    ['application/nginx/init/init.lua'] = nginx_init_by_lua_tpl,
    ['application/nginx/init/config.lua'] = nginx_init_config_tpl,
    ['config/errors.lua'] = errors_conf,
    -- ['config/nginx.lua'] = nginx_conf,
    ['config/restful.lua'] = restful_route_conf,
    ['config/waf.lua'] = waf_conf,
    ['config/waf-regs/args'] = waf_conf_regs_args,
    ['config/waf-regs/cookie'] = waf_conf_regs_cookie,
    ['config/waf-regs/post'] = waf_conf_regs_post,
    ['config/waf-regs/url'] = waf_conf_regs_url,
    ['config/waf-regs/user-agent'] = waf_conf_regs_ua,
    ['config/waf-regs/whiteurl'] = waf_conf_regs_whiteurl,
    ['pub/index.lua'] = vanilla_index,
    ['sys/v_resource'] = vanilla_app_resource,
    ['logs/hack/.gitkeep'] = "",
    ['spec/controllers/index_controller_spec.lua'] = index_controller_spec,
    ['spec/models/.gitkeep'] = "",
    ['spec/spec_helper.lua'] = spec_helper,
    ['sys/cache'] = sys_cache,
    ['sys/v_resource'] = sys_v_resource,
}

function VaApplication.new(app_path)
    local app_name = utils.basename(app_path)
    print(ansicolors("Creating app %{blue}" .. app_name .. "%{reset}..."))

    VaApplication.files['nginx_conf/va-nginx.conf'] = sgsub(va_nginx_config_tpl, "{{VANILLA_ROOT}}", VANILLA_ROOT)
    VaApplication.files['nginx_conf/va-nginx-development.conf'] = sgsub(va_nginx_dev_config_tpl, "{{VANILLA_ROOT}}", VANILLA_ROOT)

    service_manage_sh = sgsub(service_manage_sh, "{{APP_NAME}}", app_name)
    service_manage_sh = sgsub(service_manage_sh, "{{OPENRESTY_NGINX_ROOT}}", VANILLA_NGX_PATH)
    service_manage_sh = sgsub(service_manage_sh, "{{VANILLA_VERSION}}", VANILLA_VERSION)
    VaApplication.files['va-' .. app_name .. '-service'] = sgsub(service_manage_sh, "{{VA_APP_PATH}}", app_path)

    dev_nginx_vhost_config_tpl = sgsub(dev_nginx_vhost_config_tpl, "{{APP_NAME}}", app_name)
    dev_nginx_vhost_config_tpl = sgsub(dev_nginx_vhost_config_tpl, "{{VANILLA_ROOT}}", VANILLA_ROOT)
    dev_nginx_vhost_config_tpl = sgsub(dev_nginx_vhost_config_tpl, "{{VANILLA_VERSION_DIR_STR}}", VANILLA_VERSION_DIR_STR)
    VaApplication.files['nginx_conf/dev_vhost/' .. app_name .. '.conf'] = sgsub(dev_nginx_vhost_config_tpl, "{{APP_ROOT}}", app_path)
    nginx_vhost_config_tpl = sgsub(nginx_vhost_config_tpl, "{{APP_NAME}}", app_name)
    nginx_vhost_config_tpl = sgsub(nginx_vhost_config_tpl, "{{VANILLA_ROOT}}", VANILLA_ROOT)
    nginx_vhost_config_tpl = sgsub(nginx_vhost_config_tpl, "{{VANILLA_VERSION_DIR_STR}}", VANILLA_VERSION_DIR_STR)
    VaApplication.files['nginx_conf/vhost/' .. app_name .. '.conf'] = sgsub(nginx_vhost_config_tpl, "{{APP_ROOT}}", app_path)
    
    application_conf = sgsub(application_conf, "{{APP_NAME}}", app_name)
    application_conf = sgsub(application_conf, "{{VANILLA_VERSION_DIR_STR}}", VANILLA_VERSION_DIR_STR)
    application_conf = sgsub(application_conf, "{{VANILLA_ROOT}}", VANILLA_ROOT)
    VaApplication.files['config/application.lua'] = application_conf

    spec_helper = sgsub(spec_helper, "{{VANILLA_ROOT}}", VANILLA_ROOT)
    spec_helper = sgsub(spec_helper, "{{VANILLA_VERSION_DIR_STR}}", VANILLA_VERSION_DIR_STR)
    spec_helper = sgsub(spec_helper, "{{APP_ROOT}}", app_path)
    spec_helper = sgsub(spec_helper, "{{APP_NAME}}", app_name)
    VaApplication.files['spec/spec_helper.lua'] = spec_helper

    -- vanilla_index = sgsub(vanilla_index, "{{VANILLA_VERSION_DIR_STR}}", VANILLA_VERSION_DIR_STR)
    -- vanilla_index = sgsub(vanilla_index, "{{APP_ROOT}}", app_path)
    -- VaApplication.files['pub/index.lua'] = sgsub(vanilla_index, "{{VANILLA_ROOT}}", VANILLA_ROOT)
    VaApplication.create_files(app_path)
end

function VaApplication.create_files(parent)
    for file_path, file_content in pairs(VaApplication.files) do

        local full_file_path = parent .. "/" .. file_path
        local full_file_dirname = utils.dirname(full_file_path)
        os_execute("mkdir -p " .. full_file_dirname .. " > /dev/null")

        local fw = io_open(full_file_path, "w")
        fw:write(file_content)
        fw:close()

        print(ansicolors("  %{blue}created file%{reset} " .. full_file_path))
    end
end

return VaApplication
