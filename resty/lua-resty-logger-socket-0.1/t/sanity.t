# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (blocks() * 4 + 4);
our $HtmlDir = html_dir;

our $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
    lua_package_cpath "/usr/local/openresty-debug/lualib/?.so;/usr/local/openresty/lualib/?.so;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';
$ENV{TEST_NGINX_HTML_DIR} = $HtmlDir;

no_long_string();

log_level('debug');

run_tests();

__DATA__

=== TEST 1: small flush_limit, instant flush
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            collectgarbage()  -- to help leak testing

            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1,
                    pool_size = 5,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: /t?a=1&b=2
--- tcp_query_len: 10
--- response_body
foo



=== TEST 2: small flush_limit, instant flush, unix domain socket
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            collectgarbage()  -- to help leak testing

            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    flush_limit = 1,
                    path = "$TEST_NGINX_HTML_DIR/logger_test.sock",
                    retry_interval = 1,
                    timeout = 100,
                }
                if not ok then
                    ngx.log(ngx.ERR, err)
                    return
                end
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen eval: "$ENV{TEST_NGINX_HTML_DIR}/logger_test.sock"
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: /t?a=1&b=2
--- tcp_query_len: 10
--- response_body
foo



=== TEST 3: small flush_limit, instant flush, write a number to remote
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            collectgarbage()  -- to help leak testing

            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log(10)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: 10
--- tcp_query_len: 2
--- response_body
foo



=== TEST 4: buffer log messages, no flush
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            collectgarbage()  -- to help leak testing

            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 500,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
lua tcp socket connect
--- response_body
foo



=== TEST 5: not initted()
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- error_log
not initialized
--- response_body
foo



=== TEST 6: log subrequests
--- http_config eval: $::HttpConfig
--- config
    log_subrequest on;
    location /t {
        content_by_lua '
            collectgarbage()  -- to help leak testing

            local res = ngx.location.capture("/main?c=1&d=2")
            if res.status ~= 200 then
                ngx.log(ngx.ERR, "capture /main failed")
            end
            ngx.print(res.body)
        ';
    }

    location /main {
        content_by_lua '
            ngx.say("foo")
        ';

        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 6,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log("in subrequest")
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }

--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: in subrequest
--- tcp_query_len: 13
--- response_body
foo



=== TEST 7: log subrequests, small flush_limit, flush twice
--- http_config eval: $::HttpConfig
--- config
    log_subrequest on;
    location /t {
        content_by_lua '
            collectgarbage()  -- to help leak testing

            local res = ngx.location.capture("/main?c=1&d=2")
            if res.status ~= 200 then
                ngx.log(ngx.ERR, "capture /main failed")
            end
            ngx.print(res.body)
        ';
    }

    location /main {
        content_by_lua '
        ngx.say("foo")';
    }

    log_by_lua '
        local logger = require "resty.logger.socket"
        if not logger.initted() then
            local ok, err = logger.init{
                host = "127.0.0.1",
                port = 29999,
                flush_limit = 1,
                retry_interval = 1,
                timeout = 1000,
            }
        end

        local bytes, err = logger.log(ngx.var.uri)
        if err then
            ngx.log(ngx.ERR, err)
        end
    ';
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: /main/t
--- tcp_query_len: 7
--- response_body
foo



=== TEST 8: do not log subrequests
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local res = ngx.location.capture("/main?c=1&d=2")
            if res.status ~= 200 then
                ngx.log(ngx.ERR, "capture /main failed")
            end
            ngx.print(res.body)
        ';
    }

    location /main {
        content_by_lua '
            ngx.say("foo")
        ';
        log_by_lua '
            ngx.log(ngx.NOTICE, "enter log_by_lua")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1,
                    log_subrequest = false,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }

--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
lua tcp socket connect
--- response_body
foo



=== TEST 9: bad user config
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init("hello")
                if not ok then
                    ngx.log(ngx.ERR, err)
                    return
                end

            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- error_log
user_config must be a table
--- response_body
foo



=== TEST 10: bad user config: no host/port or path
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    flush_limit = 1,
                    drop_limit = 2,
                    retry_interval = 1,
                    timeout = 100,
                }
                if not ok then
                    ngx.log(ngx.ERR, err)
                    return
                end
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- error_log
no logging server configured. "host"/"port" or "path" is required.
--- response_body
foo



=== TEST 11: bad user config: flush_limit > drop_limit
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    flush_limit = 2,
                    drop_limit = 1,
                    path = "$TEST_NGINX_HTML_DIR/logger_test.sock",
                    retry_interval = 1,
                    timeout = 100,
                }
                if not ok then
                    ngx.log(ngx.ERR, err)
                    return
                end
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- error_log
"flush_limit" should be < "drop_limit"
--- response_body
foo



=== TEST 12: drop log test
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    path = "$TEST_NGINX_HTML_DIR/logger_test.sock",
                    drop_limit = 6,
                    flush_limit = 4,
                    retry_interval = 1,
                    timeout = 1,
                }
            end

            local bytes, err = logger.log("000")
            if err then
                ngx.log(ngx.ERR, err)
            end

            local bytes, err = logger.log("aaaaa")
            if err then
                ngx.log(ngx.ERR, err)
            end

            local bytes, err = logger.log("bbb")
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen eval: "$ENV{TEST_NGINX_HTML_DIR}/logger_test.sock"
--- tcp_query: 000bbb
--- tcp_query_len: 6
--- tcp_reply:
--- error_log
logger buffer is full, this log message will be dropped
--- response_body
foo



=== TEST 13: logger response
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            collectgarbage()  -- to help leak testing

            ngx.say("foo")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1,
                    pool_size = 5,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
            ngx.say("wrote bytes: ", bytes)
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: /t?a=1&b=2
--- tcp_query_len: 10
--- response_body
foo
wrote bytes: 10



=== TEST 14: logger response
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            ngx.say("foo")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 10,
                    drop_limit = 11,
                    pool_size = 5,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, err)
            end
            -- byte1 should be 0
            local bytes1, err1 = logger.log(ngx.var.request_uri)
            if err1 then
                ngx.log(ngx.ERR, err1)
            end
            ngx.say("wrote bytes: ", bytes + bytes1)
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: /t?a=1&b=2
--- tcp_query_len: 10
--- response_body
foo
wrote bytes: 10



=== TEST 15: max reuse
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            ngx.say("foo")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1,
                    drop_limit = 10000,
                    pool_size = 5,
                    retry_interval = 1,
                    timeout = 50,
                    max_buffer_reuse = 1,
                }
            end

            local bytes, err
            local total_bytes = 0
            for i = 1, 5 do
                bytes, err = logger.log(i .. i .. i)
                if err then
                    ngx.log(ngx.ERR, err)
                end
                total_bytes = total_bytes + bytes
                ngx.sleep(0.05)
            end
            ngx.say("wrote bytes: ", total_bytes)
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- error_log
log buffer reuse limit (1) reached, create a new "log_buffer_data"
--- tcp_query: 111222333444555
--- tcp_query_len: 15
--- response_body
foo
wrote bytes: 15



=== TEST 16: flush periodically
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            ngx.say("foo")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1000,
                    drop_limit = 10000,
                    retry_interval = 1,
                    timeout = 50,
                    max_buffer_reuse = 100,
                    periodic_flush = 0.03, -- 0.03s
                }
            end

            local bytes, err
            bytes, err = logger.log("foo")
            if err then
                ngx.log(ngx.ERR, err)
            end
            ngx.say("wrote bytes: ", bytes)

            ngx.sleep(0.05)

            bytes, err = logger.log("bar")
            if err then
                ngx.log(ngx.ERR, err)
            end
            ngx.say("wrote bytes: ", bytes)
            ngx.sleep(0.05)
        ';
    }
--- request
GET /t
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- tcp_query: foobar
--- tcp_query_len: 6
--- response_body
foo
wrote bytes: 3
wrote bytes: 3



=== TEST 17: SSL logging
--- http_config eval
"
    lua_package_path '$::pwd/lib/?.lua;;';
    server {
        listen unix:$::HtmlDir/ssl.sock ssl;
        server_name test.com;
        ssl_certificate $::pwd/t/cert/test.crt;
        ssl_certificate_key $::pwd/t/cert/test.key;

        location /test {
            lua_need_request_body on;
            default_type 'text/plain';
            # 204 No content
            content_by_lua '
                ngx.log(ngx.WARN, \"Message received: \", ngx.var.http_message)
                ngx.log(ngx.WARN, \"SNI Host: \", ngx.var.ssl_server_name)
                ngx.exit(204)
            ';
        }
    }
"
--- config
    location /t {
        content_by_lua '
            ngx.say("foo")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    path = "$TEST_NGINX_HTML_DIR/ssl.sock",
                    flush_limit = 1,
                    drop_limit = 10000,
                    retry_interval = 1,
                    timeout = 50,
                    ssl = true,
                    ssl_verify = false,
                    sni_host = "test.com",
                }
            end

            local bytes, err
            bytes, err = logger.log("GET /test HTTP/1.0\\r\\nHost: test.com\\r\\nConnection: close\\r\\nMessage: Hello SSL\\r\\n\\r\\n")
            if err then
                ngx.log(ngx.ERR, err)
            end
            ngx.say("wrote bytes: ", bytes)

            ngx.sleep(0.05)
        ';
    }
--- request
GET /t
--- wait: 0.1
--- response_body
foo
wrote bytes: 77
--- error_log
Message received: Hello SSL
SNI Host: test.com



=== TEST 18: SSL logging - Verify
--- http_config eval
"
    lua_package_path '$::pwd/lib/?.lua;;';
    server {
        listen unix:$::HtmlDir/ssl.sock ssl;
        server_name test.com;
        ssl_certificate $::pwd/t/cert/test.crt;
        ssl_certificate_key $::pwd/t/cert/test.key;

        location /test {
            lua_need_request_body on;
            default_type 'text/plain';
            # 204 No content
            content_by_lua 'ngx.log(ngx.WARN, \"Message received: \", ngx.var.http_message) ngx.exit(204)';
        }
    }
"
--- config
    location /t {
        content_by_lua '
            ngx.say("foo")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    path = "$TEST_NGINX_HTML_DIR/ssl.sock",
                    flush_limit = 1,
                    drop_limit = 10000,
                    retry_interval = 1,
                    timeout = 50,
                    ssl = true,
                    ssl_verify = true,
                    sni_host = "test.com",
                }
            end

            local bytes, err
            bytes, err = logger.log("GET /test HTTP/1.0\\r\\nHost: test.com\\r\\nConnection: close\\r\\nMessage: Hello SSL\\r\\n\\r\\n")
            if err then
                ngx.log(ngx.ERR, err)
            end
            ngx.say("wrote bytes: ", bytes)

            ngx.sleep(0.05)
        ';
    }
--- request
GET /t
--- wait: 0.1
--- response_body
foo
wrote bytes: 77
--- error_log
lua ssl certificate verify error



=== TEST 19: SSL logging - No SNI
--- http_config eval
"
    lua_package_path '$::pwd/lib/?.lua;;';
    server {
        listen unix:$::HtmlDir/ssl.sock ssl;
        server_name test.com;
        ssl_certificate $::pwd/t/cert/test.crt;
        ssl_certificate_key $::pwd/t/cert/test.key;

        location /test {
            lua_need_request_body on;
            default_type 'text/plain';
            # 204 No content
            content_by_lua '
                ngx.log(ngx.WARN, \"Message received: \", ngx.var.http_message)
                ngx.log(ngx.WARN, \"SNI Host: \", ngx.var.ssl_server_name)
                ngx.exit(204)
            ';
        }
    }
"
--- config
    location /t {
        content_by_lua '
            ngx.say("foo")
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    path = "$TEST_NGINX_HTML_DIR/ssl.sock",
                    flush_limit = 1,
                    drop_limit = 10000,
                    retry_interval = 1,
                    timeout = 50,
                    ssl = true,
                    ssl_verify = false,
                }
            end

            local bytes, err
            bytes, err = logger.log("GET /test HTTP/1.0\\r\\nHost: test.com\\r\\nConnection: close\\r\\nMessage: Hello SSL\\r\\n\\r\\n")
            if err then
                ngx.log(ngx.ERR, err)
            end
            ngx.say("wrote bytes: ", bytes)

            ngx.sleep(0.05)
        ';
    }
--- request
GET /t
--- wait: 0.1
--- response_body
foo
wrote bytes: 77
--- error_log
Message received: Hello SSL
SNI Host: nil
