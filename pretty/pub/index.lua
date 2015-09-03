function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    helpers.pp(...)
    helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
end

local template = require "resty.template"
local view = template.new "/Users/zj-git/vanilla/pretty/application/views/index/index.html"
view.message = "Hello, World!"
view:render()
-- template.render("/Users/zj-git/vanilla/pretty/application/views/index/index.html", { message = "Hello, World!" })
ngx.eof()
local config = require('config.application')
local app = require('vanilla.v.application'):new(ngx, config)
app:bootstrap():run()