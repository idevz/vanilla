function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    helpers.pp(...)
    helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
end

function err_log(msg)
    ngx.log(ngx.ERR, "===zjdebug" .. msg .. "===")
end

local config = require('config.application')
local app = require('vanilla.v.application'):new(ngx, config)
app:bootstrap():run()