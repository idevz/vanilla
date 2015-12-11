# vim:set ft= ts=4 sw=4 et:

# In this test, we use agentzh.org:12345 to get a connection timeout. Because
# agentzh.org:12345 was configured to drop SYN packet so that connection timeout
# happens

BEGIN {
    if (!defined $ENV{LD_PRELOAD}) {
        $ENV{LD_PRELOAD} = '';
    }

    if ($ENV{LD_PRELOAD} !~ /\bmockeagain\.so\b/) {
        $ENV{LD_PRELOAD} = "mockeagain.so $ENV{LD_PRELOAD}";
    }

    if ($ENV{MOCKEAGAIN} eq 'r') {
        $ENV{MOCKEAGAIN} = 'rw';

    } else {
        $ENV{MOCKEAGAIN} = 'w';
    }

    $ENV{TEST_NGINX_EVENT_TYPE} = 'poll';
    $ENV{MOCKEAGAIN_WRITE_TIMEOUT_PATTERN} = 'hello, world';
    $ENV{TEST_NGINX_POSTPONE_OUTPUT} = 1;
}

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);
no_shuffle();

plan tests => repeat_each() * (blocks() * 4 + 3);
our $HtmlDir = html_dir;

my $pwd = cwd();

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

=== TEST 1: connect timeout
--- http_config eval: $::HttpConfig
--- config
    resolver 8.8.8.8;
    location /t {
        content_by_lua '
            -- visit agentzh.org first to get DNS resolve done, then the
            -- following tests could use cached resolve result
            local sock = ngx.socket.tcp()
            sock:settimeout(50)
            sock:connect("agentzh.org", 80)
            sock:close()

            ngx.say("foo")
        ';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    -- timeout 1ms
                    host = "agentzh.org",
                    port = 12345,
                    flush_limit = 1,
                    timeout = 1 }
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
tcp socket connect timed out
reconnect to the log server
--- response_body
foo



=== TEST 2: send timeout
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
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

            local bytes, err = logger.log("hello, worldaaa")
            if err then
                ngx.log(ngx.ERR, "log failed")
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- error_log
lua tcp socket write timed out
resend log messages to the log server: timeout
--- response_body
foo



=== TEST 3: risk condition
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    retry_interval = 1,
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1
                }
            end

            local bytes, err = logger.log("1234567891011121314151617181920212223242526272829303132333435363738394041424344454647484950")
            local bytes, err = logger.log("1234567891011121314151617181920212223242526272829303132333435363738394041424344454647484950")
            if err then
                ngx.log(ngx.ERR, "log failed")
            end
        ';
    }
--- request
GET /t
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
[warn]
--- tcp_query: 12345678910111213141516171819202122232425262728293031323334353637383940414243444546474849501234567891011121314151617181920212223242526272829303132333435363738394041424344454647484950
--- tcp_query_len: 182
--- response_body
foo



=== TEST 4: return previous log error
--- http_config eval: $::HttpConfig
--- config
    resolver 8.8.8.8;
    log_subrequest on;
    location /main {
        content_by_lua '
            -- visit agentzh.org first to get DNS resolve done, then the
            -- following tests could use cached resolve result
            local sock = ngx.socket.tcp()
            sock:settimeout(500)
            sock:connect("agentzh.org", 80)
            sock:close()

            local res1 = ngx.location.capture("/t?a=1&b=2")
            if res1.status == 200 then
                ngx.print(res1.body)
            end

            ngx.sleep(0.05)
            ngx.say("bar")

            local res3 = ngx.location.capture("/t?a=1&b=2")
            if res3.status == 200 then
                ngx.print(res3.body)
            end
        ';
    }
    location /t {
        content_by_lua 'ngx.say("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    -- timeout 1ms
                    host = "agentzh.org",
                    port = 12345,
                    flush_limit = 1,
                    timeout = 1,
                    max_error = 2,
                    max_retry_times = 1,
                    retry_interval = 1,
                }
            end

            local bytes, err = logger.log(ngx.var.request_uri)
            if err then
                ngx.log(ngx.ERR, "log error:" .. err)
            end
        ';
    }
--- request
GET /main
--- wait: 0.2
--- error_log
lua tcp socket connect timed out
reconnect to the log server: timeout
log error:try to send log messages to the log server failed after 1 retries: try to connect to the log server failed after 1 retries: timeout
--- response_body
foo
bar
foo



=== TEST 5: flush race condition
--- http_config eval: $::HttpConfig
--- config
    resolver 8.8.8.8;
    location /t {
        content_by_lua '
            -- visit agentzh.org first to get DNS resolve done, then the
            -- following tests could use cached resolve result
            local sock = ngx.socket.tcp()
            sock:settimeout(500)
            sock:connect("agentzh.org", 80)
            sock:close()

            ngx.say("foo")
        ';
        log_by_lua '

            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    -- timeout 1ms
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 1,
                    timeout = 50,
                    max_retry_times = 2,
                    retry_interval = 100,
                }
            end

            local bytes, err = logger.log("hello, worldaaa")
            if err then
                ngx.log(ngx.ERR, err)
            end

            local bytes, err = logger.log("hello, worldbbb")
            if err then
                ngx.log(ngx.ERR, err)
            end
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 2
--- tcp_listen: 29999
--- tcp_reply:
--- error_log
previous flush not finished
--- no_error_log
tcp socket connect timed out
--- response_body
foo
--- timeout: 10
