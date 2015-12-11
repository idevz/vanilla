# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (blocks() * 5);
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

=== TEST 1: flush manually
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            collectgarbage()  -- to help leak testing

            local logger = require "resty.logger.socket"
            if not logger.initted() then
                local ok, err = logger.init{
                    host = "127.0.0.1",
                    port = 29999,
                    flush_limit = 100,
                    pool_size = 5,
                    retry_interval = 1,
                    timeout = 100,
                }
            end

            local bytes, err = logger.log("abc")
            if err then
                ngx.log(ngx.ERR, err)
            end

            local bytes, err = logger.log("efg")
            if err then
                ngx.log(ngx.ERR, err)
            end

            local bytes, err = logger.flush()
            ngx.say(bytes)
        ';
    }
--- request
GET /t?a=1&b=2
--- wait: 0.1
--- tcp_listen: 29999
--- tcp_reply:
--- no_error_log
[error]
--- tcp_query: abcefg
--- tcp_query_len: 6
--- response_body
6

