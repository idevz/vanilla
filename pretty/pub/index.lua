function pps( ... )
    local helpers = require 'vanilla.v.libs.utils'
    return helpers.pps(...)
end

function ppz( ... )
    local helpers = require 'vanilla.v.libs.utils'
    -- helpers.pp(...)
    -- helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
    local s = helpers.pps(...)
    -- local s = pps(...)
    ngx.say(s)
end

function err_log(msg)
    ngx.log(ngx.ERR, "===zjdebug" .. msg .. "===")
end

-- ngx.header['Content_type'] = 'text/html; charset=UTF-8'
-- local r = require('vanilla.v.registry'):new('zj')
-- ngx.say('<pre />')
-- -- pp(r)
-- r:set('zhou', 'ddd')
-- ngx.say(r:get('zhou'))
-- -- pp(ngx)

local config = require('config.application')
local app = require('vanilla.v.application'):new(config)
app:bootstrap():run()