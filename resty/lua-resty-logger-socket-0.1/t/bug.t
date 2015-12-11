# vim:set ft= ts=4 sw=4 et:

BEGIN {
    if (!defined $ENV{LD_PRELOAD}) {
        $ENV{LD_PRELOAD} = '';
    }

    if ($ENV{LD_PRELOAD} !~ /\bmockeagain\.so\b/) {
        $ENV{LD_PRELOAD} = "mockeagain.so $ENV{LD_PRELOAD}";
    }

    $ENV{MOCKEAGAIN} = 'w';

    $ENV{MOCKEAGAIN_VERBOSE} = 1;
    $ENV{TEST_NGINX_EVENT_TYPE} = 'poll';
    $ENV{MOCKEAGAIN_WRITE_TIMEOUT_PATTERN} = 'hello';
    $ENV{TEST_NGINX_POSTPONE_OUTPUT} = 1;
}

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (blocks() * 3 + 2);
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

=== TEST 1: small flush_limit, instant flush
--- http_config eval: $::HttpConfig
--- config
    log_subrequest on;
    location /log {
        content_by_lua 'ngx.print("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 5,
                    drop_limit = 11,
                    pool_size = 5,
                    retry_interval = 1,
                    max_retry_times = 0,
                    timeout = 10,
                }
            end

            local ok, err = logger.log(ngx.var.arg_log)
        ';

    }
    location /t {
        content_by_lua '
            local res = ngx.location.capture("/log?log=helloworld")
            ngx.say(res.body)
            ngx.sleep(0.05)

            res = ngx.location.capture("/log?log=bb")
            ngx.say(res.body)
            ngx.sleep(0.05)

            res = ngx.location.capture("/log?log=bb")
            ngx.say(res.body)
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.2
--- tcp_listen: 29999
--- tcp_reply:
--- tcp_no_close
--- grep_error_log chop
resend log messages to the log server: timeout
--- response_body
foo
foo
foo
--- grep_error_log_out
resend log messages to the log server: timeout
resend log messages to the log server: timeout
resend log messages to the log server: timeout



=== TEST 2: insert new log messages to buffer in the middle of last send (it's difficult to control the time sequence here, so this is skipped now)
--- http_config eval: $::HttpConfig
--- config
    log_subrequest on;
    location /log {
        content_by_lua 'ngx.print("foo")';
        log_by_lua '
            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 6,
                    drop_limit = 1000,
                    pool_size = 5,
                    retry_interval = 1,
                    max_retry_times = 0,
                    timeout = 10,
                }
            end

            local ok, err = logger.log(ngx.var.arg_log)
        ';

    }
    location /t {
        content_by_lua '
            local res = ngx.location.capture("/log?log=123456")
            ngx.say(res.body)
            ngx.sleep(0.002)

            res = ngx.location.capture("/log?log=aaaa")
            ngx.say(res.body)
            ngx.sleep(0.001)

            res = ngx.location.capture("/log?log=bb")
            ngx.say(res.body)
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.2
--- tcp_listen: 29999
--- tcp_reply:
--- tcp_no_close
--- tcp_query: 123456aaaabb
--- tcp_query_len: 12
--- response_body
foo
foo
foo
--- SKIP



=== TEST 3: Test deadlock (https://github.com/cloudflare/lua-resty-logger-socket/pull/5)
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
                    flush_limit = 0,
                    drop_limit = 1000,
                    pool_size = 5,
                    retry_interval = 1,
                    timeout = 100,
                }
            end
            local ok, err = logger.log("")
            if not ok then
                ngx.log(ngx.ERR, err)
            end

            ngx.sleep(0.05)

            local ok, err = logger.log(ngx.var.request_uri)
            if not ok then
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
